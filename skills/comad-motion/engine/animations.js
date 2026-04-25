/**
 * comad-motion · Stage + Sprite animation engine
 *
 * Usage (via CDN + Babel in HTML):
 *   <script crossorigin src="https://unpkg.com/react@18/umd/react.production.min.js"></script>
 *   <script crossorigin src="https://unpkg.com/react-dom@18/umd/react-dom.production.min.js"></script>
 *   <script src="./engine/animations.js"></script>
 *   <script type="text/babel">
 *     const { Stage, Sprite, useTime, useSprite, interpolate, Easing } = window.comadAnim;
 *     // ... components
 *   </script>
 *
 * Exports on window.comadAnim:
 *   Stage, Sprite, useTime, useSprite, interpolate, Easing
 *
 * See references/animations.md for API spec and design rationale.
 */

(function () {
  if (typeof window === 'undefined' || !window.React) {
    throw new Error('comad-motion/animations.js: window.React must be loaded first');
  }
  const React = window.React;
  const { createContext, useContext, useEffect, useRef, useState } = React;

  // ---------- Easing presets ----------
  const Easing = {
    linear: (t) => t,
    easeIn: (t) => t * t,
    easeOut: (t) => 1 - (1 - t) * (1 - t),
    easeInOut: (t) => (t < 0.5 ? 2 * t * t : 1 - Math.pow(-2 * t + 2, 2) / 2),
    // expoOut — Anthropic-grade default. cubic-bezier(0.16, 1, 0.3, 1) equivalent.
    expoOut: (t) => (t === 1 ? 1 : 1 - Math.pow(2, -10 * t)),
    // overshoot — elastic pop. cubic-bezier(0.34, 1.56, 0.64, 1) equivalent.
    overshoot: (t) => {
      const c1 = 1.70158;
      const c3 = c1 + 1;
      return 1 + c3 * Math.pow(t - 1, 3) + c1 * Math.pow(t - 1, 2);
    },
    spring: (t) => {
      if (t === 0) return 0;
      if (t === 1) return 1;
      const c = (2 * Math.PI) / 3;
      return Math.pow(2, -10 * t) * Math.sin((t * 10 - 0.75) * c) + 1;
    },
    anticipation: (t) => {
      if (t < 0.2) {
        const k = t / 0.2;
        return -0.3 * k * k;
      }
      const k = (t - 0.2) / 0.8;
      return -0.012 + 1.012 * k * k * (3 - 2 * k);
    },
  };

  // ---------- interpolate ----------
  function interpolate(t, input, output, easing) {
    const [inStart, inEnd] = input;
    const [outStart, outEnd] = output;
    if (t <= inStart) return outStart;
    if (t >= inEnd) return outEnd;
    let p = (t - inStart) / (inEnd - inStart);
    if (typeof easing === 'function') p = easing(p);
    return outStart + (outEnd - outStart) * p;
  }

  // ---------- Contexts ----------
  const TimeContext = createContext({ time: 0, duration: 0, playing: false });
  const SpriteContext = createContext(null);

  function useTime() {
    return useContext(TimeContext).time;
  }

  function useSprite() {
    const s = useContext(SpriteContext);
    if (!s) return { t: 0, elapsed: 0, duration: 0 };
    return s;
  }

  // ---------- Stage ----------
  function Stage(props) {
    const duration = Number(props.duration) || 10;
    const [time, setTime] = useState(0);
    const [playing, setPlaying] = useState(true);
    const startRef = useRef(null);
    const rafRef = useRef(null);

    // __ready signal for recorder
    useEffect(() => {
      if (typeof document !== 'undefined' && document.fonts && document.fonts.ready) {
        document.fonts.ready.then(() => {
          requestAnimationFrame(() => {
            window.__ready = true;
          });
        });
      } else {
        requestAnimationFrame(() => {
          window.__ready = true;
        });
      }
    }, []);

    // Inject .no-record style once
    useEffect(() => {
      if (typeof document === 'undefined') return;
      if (document.getElementById('comad-motion-no-record-style')) return;
      const style = document.createElement('style');
      style.id = 'comad-motion-no-record-style';
      style.textContent = '.no-record { display: none !important; }';
      document.head.appendChild(style);
    }, []);

    // rAF loop
    useEffect(() => {
      if (!playing) return;
      function tick(now) {
        if (startRef.current == null) startRef.current = now;
        const elapsed = (now - startRef.current) / 1000;
        if (elapsed >= duration) {
          setTime(duration);
          setPlaying(false);
          return;
        }
        setTime(elapsed);
        rafRef.current = requestAnimationFrame(tick);
      }
      rafRef.current = requestAnimationFrame(tick);
      return () => rafRef.current && cancelAnimationFrame(rafRef.current);
    }, [playing, duration]);

    // Seek / replay helpers (debug)
    useEffect(() => {
      if (typeof window === 'undefined') return;
      window.__seek = (t) => {
        setTime(Math.max(0, Math.min(duration, Number(t) || 0)));
        setPlaying(false);
        startRef.current = null;
      };
      window.__replay = () => {
        setTime(0);
        startRef.current = null;
        setPlaying(true);
      };
      function onKey(e) {
        if (e.key === 'r') window.__replay();
        else if (e.key === ' ') {
          e.preventDefault();
          setPlaying((p) => !p);
        } else if (e.key === 'ArrowRight') window.__seek((time + 0.1).toFixed(2));
        else if (e.key === 'ArrowLeft') window.__seek((time - 0.1).toFixed(2));
      }
      window.addEventListener('keydown', onKey);
      return () => window.removeEventListener('keydown', onKey);
    }, [time, duration]);

    return React.createElement(
      TimeContext.Provider,
      { value: { time, duration, playing } },
      React.createElement(
        'div',
        {
          style: Object.assign(
            { position: 'relative', width: '100%', height: '100%', overflow: 'hidden' },
            props.style || {}
          ),
          className: props.className,
        },
        props.children
      )
    );
  }

  // ---------- Sprite ----------
  function Sprite(props) {
    const { start, end, children } = props;
    const { time } = useContext(TimeContext);
    if (time < start || time > end) return null;
    const elapsed = time - start;
    const duration = end - start;
    const t = duration > 0 ? Math.max(0, Math.min(1, elapsed / duration)) : 0;
    return React.createElement(
      SpriteContext.Provider,
      { value: { t, elapsed, duration } },
      children
    );
  }

  // ---------- Export ----------
  window.comadAnim = {
    Stage,
    Sprite,
    useTime,
    useSprite,
    interpolate,
    Easing,
    version: '0.1.0',
  };
})();
