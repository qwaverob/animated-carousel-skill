# Motion menu

Pick one **primary technique** per slide. The primary technique is the slide's main movement, the thing that carries its point. The shared headline entrance (lines rising in over 0.5 s, already in `templates/content-slide/`) and the progress bar do not count as a primary technique.

## Variety rules

1. No two adjacent slides use the same primary technique.
2. No technique is used more than twice in one carousel.
3. Slide 1 uses only techniques marked **cover-safe**, and only on decoration. The hook is fully visible at frame 0.
4. Every slide is settled (fully readable, nothing still moving that matters) by about 60 percent of its length, then holds.
5. Match the technique to the content: numbers get a counter, bars, gauge or dot grid; lists get a checklist or card stack; comparisons get a split wipe, before and after, or flip.
6. Numbers shown in any technique come from the user. Never invent a stat to give a counter something to count.

## Motion rules (all techniques)

- Ease out with exponential curves: `power3.out`, `power4.out`, `expo.out`. Use `sine.inOut` only for slow drifts. No `bounce`, no `elastic`.
- Entrances 0.4 to 0.8 s. Staggers 0.08 to 0.15 s. Nothing faster than 0.15 s except a typing step.
- Animate `x`, `y`, `xPercent`, `yPercent`, `scale`, `scaleX`, `scaleY`, `rotation`, `opacity`, colors, `clipPath` and SVG `strokeDashoffset`. Never `width`, `height`, `top`, `left`.
- Never set a CSS `transform` on an element you also move with GSAP; set the start state in `fromTo` instead.
- Deterministic only: no `Math.random()`, no `Date.now()`, no timers, no `repeat: -1`. Finite repeats are fine.
- All snippets below assume the template's single `tl` timeline and times in seconds from the slide start.

## The menu

| # | Technique | Best for | Cover-safe |
| --- | --- | --- | --- |
| 1 | Mask line reveal | A strong 2 to 4 line statement | No |
| 2 | Counter roll (odometer) | One number the user gave you | No |
| 3 | Bars growing | Comparing 2 to 5 real values | No |
| 4 | Checklist tick | Steps, requirements, a to-do list | No |
| 5 | Card stack shuffle | 3 to 4 items, one at a time | No |
| 6 | Split-screen wipe | This vs that | No |
| 7 | Kinetic word swap | One sentence with a changing word | No |
| 8 | Path draw | Arrows, underlines, a route, a simple chart line | Yes (decoration only) |
| 9 | Zoom-through | A turn in the story, "here is the real reason" | No |
| 10 | Before and after slider | A visible change | No |
| 11 | UI mockup typing | A DM, search box, or message | No |
| 12 | Marquee band | Keywords, a repeated phrase, a ticker | Yes (as a band clear of the hook) |
| 13 | Highlighter sweep | One key phrase in body copy | Yes (behind words already visible) |
| 14 | Stamp drop | A verdict: approved, avoid, done | No |
| 15 | Timeline fill | A process with stages or dates | No |
| 16 | Gauge needle | A rating or a level (low, ok, high) | No |
| 17 | Dot grid fill | "X out of 100" with a real number | No |
| 18 | Flip reveal | Myth then fact, question then answer | No |
| 0 | Cover drift | Slide 1 only: slow scale and background drift | Yes (template default) |

## Snippets

### 1. Mask line reveal

```html
<div class="mask"><span class="m-line">Most deals stall</span></div>
<div class="mask"><span class="m-line">in the first week</span></div>
```
```css
.mask { overflow: hidden; }
.m-line { display: block; }
```
```js
tl.fromTo(".m-line", { yPercent: 110 }, { yPercent: 0, duration: 0.7, ease: "power4.out", stagger: 0.12 }, 0.3);
```

### 2. Counter roll (odometer)

Each digit is a column of 0 to 9; the column slides to its digit. Pure transforms, so it seeks perfectly.

```html
<div class="odo"><span class="col" data-digit="4"></span><span class="col" data-digit="7"></span></div>
```
```css
.odo { display: flex; height: 220px; overflow: hidden; font: 400 220px/1 var(--font-display); font-variant-numeric: tabular-nums; }
.col { display: flex; flex-direction: column; }
.col span { height: 220px; }
```
```js
document.querySelectorAll(".col").forEach((col, i) => {
  for (let d = 0; d <= 9; d++) { const s = document.createElement("span"); s.textContent = d; col.appendChild(s); }
  const digit = Number(col.dataset.digit);
  tl.fromTo(col, { yPercent: 0 }, { yPercent: -10 * digit, duration: 1.2 + i * 0.2, ease: "power3.out" }, 0.5);
});
```
Building the digit spans at setup is fine (it runs once, before the timeline registers).

### 3. Bars growing

```css
.bar { transform-origin: 50% 100%; } /* set the origin, never a transform value */
```
```js
tl.fromTo(".bar", { scaleY: 0 }, { scaleY: 1, duration: 0.8, ease: "power3.out", stagger: 0.12 }, 0.5);
tl.fromTo(".bar-value", { opacity: 0, y: 12 }, { opacity: 1, y: 0, duration: 0.4, ease: "power2.out", stagger: 0.12 }, 1.0);
```
Set each bar's real height in CSS from the user's numbers; the tween only grows it from zero.

### 4. Checklist tick

Already built in `templates/content-slide/`: rows slide in, each box fills with the accent, an SVG tick draws with `strokeDashoffset`, and the label brightens.

### 5. Card stack shuffle

Cards overlap on purpose while stacked, so put `data-layout-allow-overlap data-layout-allow-occlusion` on each text element inside the cards (the flags are not inherited from a wrapper), or `hyperframes check` reports `text_occluded` and `content_overlap`. Variant used in `examples/demo-carousel`: the stack deals out into a readable list instead of flying away.

```css
.card { position: absolute; inset: 0; }
```
```js
// cards in DOM order: last one is on top. Top cards leave, the last remaining card stays.
const cards = gsap.utils.toArray(".card").reverse();
cards.forEach((c, i) => tl.set(c, { rotation: (i % 2 ? 2.5 : -2.5), y: i * 10 }, 0));
cards.slice(0, -1).forEach((c, i) => {
  tl.to(c, { x: 1100, rotation: 14, duration: 0.6, ease: "power3.in" }, 1.0 + i * 0.9);
});
tl.to(cards[cards.length - 1], { rotation: 0, y: 0, duration: 0.4, ease: "power3.out" }, 1.0 + (cards.length - 1) * 0.9);
```

### 6. Split-screen wipe

```js
tl.fromTo(".right-panel", { clipPath: "inset(0% 0% 0% 100%)" }, { clipPath: "inset(0% 0% 0% 0%)", duration: 0.9, ease: "power4.out" }, 0.8);
tl.fromTo(".divider", { scaleY: 0 }, { scaleY: 1, duration: 0.6, ease: "power3.out" }, 0.6);
```
Lay the two halves out side by side with CSS grid; the right half wipes in from its edge.

### 7. Kinetic word swap

```html
<p class="sentence">Buyers pay for <span class="slot"><span class="w">growth</span><span class="w">proof</span><span class="w">systems</span></span></p>
```
```css
.slot { position: relative; display: inline-block; overflow: hidden; vertical-align: bottom; height: 1.15em; min-width: 6ch; }
.slot .w { position: absolute; left: 0; top: 0; }
```
```js
const words = gsap.utils.toArray(".slot .w");
words.forEach((w, i) => tl.set(w, { yPercent: i === 0 ? 0 : 110 }, 0));
words.slice(1).forEach((w, i) => {
  const t = 0.9 + i * 0.8;
  tl.to(words[i], { yPercent: -110, duration: 0.45, ease: "power3.in" }, t);
  tl.fromTo(w, { yPercent: 110 }, { yPercent: 0, duration: 0.5, ease: "power4.out" }, t + 0.2);
});
```
The last word is the one that stays: make it the point.

### 8. Path draw

```html
<svg viewBox="0 0 900 200"><path class="draw" pathLength="1" d="M10 180 C 300 170, 520 40, 890 20" /></svg>
```
```css
.draw { fill: none; stroke: var(--accent); stroke-width: 8; stroke-linecap: round; stroke-dasharray: 1; stroke-dashoffset: 1; }
```
```js
tl.to(".draw", { strokeDashoffset: 0, duration: 1.2, ease: "power2.inOut" }, 0.5);
```
On slide 1 use it only for an underline or arrow beneath an already visible hook.

### 9. Zoom-through

```js
// A big accent shape fills the frame, the camera passes through it, the content is behind it.
tl.fromTo(".portal", { scale: 1 }, { scale: 14, duration: 0.9, ease: "power3.in" }, 0.3);
tl.to(".portal", { opacity: 0, duration: 0.2 }, 1.1);
tl.fromTo(".behind", { scale: 1.15, opacity: 0 }, { scale: 1, opacity: 1, duration: 0.7, ease: "expo.out" }, 1.0);
```

### 10. Before and after slider

```js
// .after sits exactly on top of .before; the handle line moves with the clip edge.
tl.fromTo(".after", { clipPath: "inset(0% 100% 0% 0%)" }, { clipPath: "inset(0% 50% 0% 0%)", duration: 1.0, ease: "power3.inOut" }, 0.6);
tl.fromTo(".handle", { xPercent: 0 }, { xPercent: 50, duration: 1.0, ease: "power3.inOut" }, 0.6);
tl.to(".after", { clipPath: "inset(0% 0% 0% 0%)", duration: 0.9, ease: "power3.inOut" }, 2.0);
tl.to(".handle", { xPercent: 100, duration: 0.9, ease: "power3.inOut" }, 2.0);
```
Give `.handle` a full-width wrapper so `xPercent` maps to the frame width.

### 11. UI mockup typing

```js
// Wrap each character in a span at setup, then reveal one per step.
const field = document.querySelector(".typed");
const text = field.textContent; field.textContent = "";
[...text].forEach((ch) => { const s = document.createElement("span"); s.textContent = ch; s.style.opacity = 0; field.appendChild(s); });
tl.to(".typed span", { opacity: 1, duration: 0.01, stagger: 0.045 }, 0.6);
tl.fromTo(".caret", { opacity: 1 }, { opacity: 0, duration: 0.3, repeat: 7, yoyo: true, ease: "steps(1)" }, 0.6);
tl.fromTo(".send", { scale: 0.9, opacity: 0 }, { scale: 1, opacity: 1, duration: 0.4, ease: "power3.out" }, 0.6 + text.length * 0.045);
```
Keep typed text short (under 40 characters) so it finishes before 60 percent of the slide.

### 12. Marquee band

```js
// .band holds the phrase repeated enough times to be twice the frame width.
tl.fromTo(".band", { xPercent: 0 }, { xPercent: -50, duration: 6, ease: "none" }, 0);
```
Linear and slow. On slide 1 the band sits above or below the hook, never over it.

### 13. Highlighter sweep

```css
/* <span class="hl"><span class="hl-mark"></span>key phrase</span>; tween a real span, not ::before */
.hl { position: relative; z-index: 0; }
.hl-mark { position: absolute; inset: 8% -4% 4% -4%; background: var(--accent); z-index: -1; transform-origin: 0% 50%; }
```
```js
tl.fromTo(".hl-mark", { scaleX: 0 }, { scaleX: 1, duration: 0.55, ease: "power3.out" }, 0.8);
```
Text on the mark must still pass contrast (dark text on a light accent, or the reverse).

### 14. Stamp drop

```js
tl.fromTo(".stamp", { scale: 1.6, rotation: -14, opacity: 0 }, { scale: 1, rotation: -6, opacity: 1, duration: 0.35, ease: "power4.out" }, 1.4);
tl.fromTo(".stamp-shadow", { opacity: 0 }, { opacity: 0.35, duration: 0.2 }, 1.6);
```
Short and firm. No bounce.

### 15. Timeline fill

```js
tl.fromTo(".track-fill", { scaleX: 0 }, { scaleX: 1, duration: 1.8, ease: "power2.inOut" }, 0.5); // transform-origin: 0% 50%
gsap.utils.toArray(".node").forEach((n, i, all) => {
  const t = 0.5 + (1.8 * i) / (all.length - 1);
  tl.fromTo(n, { scale: 0.6, opacity: 0.4 }, { scale: 1, opacity: 1, duration: 0.3, ease: "power3.out" }, t);
});
```

### 16. Gauge needle

```css
.needle { transform-origin: 50% 100%; }
```
```js
tl.fromTo(".needle", { rotation: -90 }, { rotation: 38, duration: 1.4, ease: "power3.out" }, 0.6);
```
Angle maps the user's level onto the arc (-90 is empty, 90 is full).

### 17. Dot grid fill

```js
// 100 dots in a 10x10 grid, each <div class="dot"><div class="dot-fill"></div></div>.
// .dot-fill has the accent background and starts at opacity 0. Fill the first N in
// reading order. N comes from the user.
const N = 23;
const fills = gsap.utils.toArray(".dot-fill").slice(0, N);
tl.fromTo(fills, { opacity: 0, scale: 0.4 }, { opacity: 1, scale: 1, duration: 0.2, ease: "power2.out", stagger: 0.02 }, 0.6);
```

### 18. Flip reveal

```css
.flip { perspective: 1600px; }
.flip-inner { transform-style: preserve-3d; position: relative; }
.face { position: absolute; inset: 0; backface-visibility: hidden; }
.face.back { transform: rotateY(180deg); } /* static, never tweened */
```
```js
tl.fromTo(".flip-inner", { rotationY: 0 }, { rotationY: 180, duration: 0.8, ease: "power3.inOut" }, 1.6);
```
Show the myth long enough to read (about 1.5 s) before the flip.

### 0. Cover drift (slide 1)

Already built in `templates/cover-slide/`: ledger lines drift one line height, the hook block scales from 1 to 1.02, the swipe cue nudges twice. Frame 0 is the finished cover.

## Example plan for a 6-slide carousel

| Slide | Content | Primary technique |
| --- | --- | --- |
| 1 | Hook | 0 Cover drift (plus 8 Path draw underline) |
| 2 | The problem in one statement | 1 Mask line reveal |
| 3 | Three documents to prepare | 5 Card stack shuffle |
| 4 | Old way vs better way | 6 Split-screen wipe |
| 5 | The prep steps | 4 Checklist tick |
| 6 | Comment THIS for the full list | 11 UI mockup typing (the comment being typed) |

No neighbors repeat, nothing appears more than twice.
