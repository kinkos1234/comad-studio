#!/usr/bin/env node
// image2pptx.js — Image-first PPTX 생성기
//
// Usage:
//   node image2pptx.js <spec.json> <output.pptx>
//
// Expected spec.json:
//   { "deck": { ... }, "slides": [ { "id": "slide-1", "image": "slide-1.png", "overlays": [...] }, ... ] }
//
// Each slide: addImage(full-slide) + optional text overlays.
// Output: LAYOUT_WIDE (13.333 × 7.5 inch = 1280×720 px @ 96dpi).

const path = require('path');
const fs = require('fs');

async function main() {
  const [specPath, outPath] = process.argv.slice(2);
  if (!specPath || !outPath) {
    console.error('Usage: node image2pptx.js <spec.json> <output.pptx>');
    process.exit(1);
  }
  const absSpec = path.resolve(specPath);
  const absOut = path.resolve(outPath);
  if (!fs.existsSync(absSpec)) {
    console.error(`Spec not found: ${specPath}`);
    process.exit(1);
  }

  let pptxgen;
  try {
    pptxgen = require('pptxgenjs');
  } catch {
    console.error('Missing dep: pptxgenjs. Install: npm install -g pptxgenjs');
    process.exit(2);
  }

  const spec = JSON.parse(fs.readFileSync(absSpec, 'utf8'));
  const specDir = path.dirname(absSpec);

  const pres = new pptxgen();
  pres.layout = 'LAYOUT_WIDE';

  for (const s of (spec.slides || [])) {
    const slide = pres.addSlide();
    // Full-slide image
    if (s.image) {
      const imgPath = path.isAbsolute(s.image) ? s.image : path.resolve(specDir, s.image);
      if (!fs.existsSync(imgPath)) {
        console.error(`⚠ slide ${s.id}: image not found ${imgPath}`);
        continue;
      }
      slide.addImage({
        path: imgPath,
        x: 0, y: 0, w: 13.333, h: 7.5,
      });
    }
    // Optional text overlays (editable in PPT)
    for (const o of (s.overlays || [])) {
      slide.addText(o.text, {
        x: o.x_in || 0, y: o.y_in || 0,
        w: o.w_in || 6, h: o.h_in || 1,
        fontSize: o.font_size || 18,
        fontFace: o.font || 'Apple SD Gothic Neo',
        bold: !!o.bold,
        color: o.color || '111111',
        align: o.align || 'left',
        valign: o.valign || 'top',
        transparency: o.hidden ? 100 : 0, // fully transparent = invisible overlay for accessibility
        isTextBox: true,
      });
    }
  }

  await pres.writeFile({ fileName: absOut });
  const stat = fs.statSync(absOut);
  console.log(`✅ ${absOut} (${spec.slides.length} slides, ${(stat.size / 1024).toFixed(1)} KB)`);
}

main().catch((err) => { console.error(err); process.exit(99); });
