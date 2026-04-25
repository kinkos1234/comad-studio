#!/usr/bin/env node
/**
 * comad-motion · render-video.js
 *
 * HTML animation → MP4 via Playwright recordVideo + ffmpeg.
 *
 * Pipeline:
 *   1) Warmup pass — navigate, let fonts/assets cache (no recording)
 *   2) Record pass — fresh context with recordVideo, wait for window.__ready,
 *      then capture `duration` seconds, trim the pre-ready offset
 *   3) ffmpeg convert WebM → h264 MP4, embed .no-record hide CSS via init script
 *
 * Requires:
 *   - global playwright (npm install -g playwright)  [installed]
 *   - ffmpeg on PATH                                  [installed]
 *
 * Usage:
 *   NODE_PATH=$(npm root -g) node render-video.js <html-file> \
 *     [--duration=30] [--width=1920] [--height=1080] \
 *     [--trim=<seconds>] [--fontwait=1.5] [--readytimeout=8] [--keep-chrome]
 *
 * Output: <basename>.mp4 next to the HTML file.
 */

const path = require('path');
const fs = require('fs');
const { spawnSync } = require('child_process');

function arg(name, def) {
  const p = process.argv.find((a) => a.startsWith('--' + name + '='));
  return p ? p.slice(name.length + 3) : def;
}
function hasFlag(name) {
  return process.argv.includes('--' + name);
}

const HTML_FILE = process.argv[2];
if (!HTML_FILE || HTML_FILE.startsWith('--')) {
  console.error('Usage: node render-video.js <html-file> [options]');
  process.exit(1);
}
const abs = path.resolve(HTML_FILE);
if (!fs.existsSync(abs)) {
  console.error(`Not found: ${abs}`);
  process.exit(1);
}

const DURATION = parseFloat(arg('duration', '10'));
const WIDTH = parseInt(arg('width', '1920'), 10);
const HEIGHT = parseInt(arg('height', '1080'), 10);
const FONT_WAIT = parseFloat(arg('fontwait', '1.5'));
const READY_TIMEOUT = parseFloat(arg('readytimeout', '8'));
const TRIM_OVERRIDE = arg('trim', null);
const KEEP_CHROME = hasFlag('keep-chrome');

const basename = path.basename(abs, path.extname(abs));
const outDir = path.dirname(abs);
const outMp4 = path.join(outDir, `${basename}.mp4`);
const tmpDir = fs.mkdtempSync(path.join(require('os').tmpdir(), 'comad-motion-'));

(async () => {
  const { chromium } = require('playwright');

  // ---- Warmup pass ----
  {
    const browser = await chromium.launch();
    const ctx = await browser.newContext({ viewport: { width: WIDTH, height: HEIGHT } });
    const page = await ctx.newPage();
    await page.goto(`file://${abs}`);
    await page.waitForTimeout(FONT_WAIT * 1000);
    await ctx.close();
    await browser.close();
  }

  // ---- Record pass ----
  const recStart = Date.now();
  const browser = await chromium.launch();
  const ctx = await browser.newContext({
    viewport: { width: WIDTH, height: HEIGHT },
    recordVideo: { dir: tmpDir, size: { width: WIDTH, height: HEIGHT } },
  });

  if (!KEEP_CHROME) {
    await ctx.addInitScript(() => {
      const css = '.no-record,.chrome,.masthead,.footer-chrome,.progress-bar,.replay-btn{display:none!important}';
      const style = document.createElement('style');
      style.textContent = css;
      (document.head || document.documentElement).appendChild(style);
    });
  }

  const page = await ctx.newPage();
  page.on('pageerror', (e) => console.error('[pageerror]', e.message));
  page.on('console', (m) => {
    if (m.type() === 'error') console.error('[console.error]', m.text());
  });

  await page.goto(`file://${abs}`);

  // Wait for __ready flag (set by engine/animations.js Stage)
  let readyT0 = null;
  try {
    await page.waitForFunction(() => window.__ready === true, { timeout: READY_TIMEOUT * 1000 });
    readyT0 = (Date.now() - recStart) / 1000;
  } catch (e) {
    console.warn(`window.__ready not set within ${READY_TIMEOUT}s — using --fontwait=${FONT_WAIT}s offset`);
    readyT0 = FONT_WAIT;
  }

  const trimSec = TRIM_OVERRIDE != null ? parseFloat(TRIM_OVERRIDE) : readyT0;

  // Capture duration seconds of animation
  await page.waitForTimeout(DURATION * 1000);

  // Close context so video is finalized
  const video = page.video();
  await ctx.close();
  await browser.close();

  if (!video) {
    console.error('No video recording — ensure recordVideo is set.');
    process.exit(2);
  }
  const webmPath = await video.path();

  // ffmpeg: WebM → h264 MP4, trim head
  const ffArgs = [
    '-y',
    '-ss',
    String(trimSec),
    '-i',
    webmPath,
    '-t',
    String(DURATION),
    '-c:v',
    'libx264',
    '-crf',
    '18',
    '-preset',
    'medium',
    '-pix_fmt',
    'yuv420p',
    '-movflags',
    '+faststart',
    outMp4,
  ];
  const r = spawnSync('ffmpeg', ffArgs, { stdio: 'inherit' });
  if (r.status !== 0) {
    console.error('ffmpeg failed');
    process.exit(3);
  }

  try {
    fs.rmSync(tmpDir, { recursive: true, force: true });
  } catch {}
  console.log(`✅ wrote ${outMp4}  (trim=${trimSec.toFixed(2)}s · duration=${DURATION}s · ${WIDTH}x${HEIGHT})`);
})().catch((e) => {
  console.error(e);
  process.exit(1);
});
