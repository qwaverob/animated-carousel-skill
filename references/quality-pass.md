# Quality pass (run before any render)

A design and copy check on every slide, done before `scripts/grade-stills.sh` and again on the stills before `scripts/render-slides.sh`. Fix every "no" before moving on.

## 1. Type hierarchy

- [ ] Each slide has one clear first read (headline or hook), a second read (items or body), and a quiet third (handle, slide count).
- [ ] At least a 1.25x size step between levels; weight and color also separate them.
- [ ] Headlines are sentence case. No all-caps labels or eyebrows above headings.
- [ ] No single word highlighted in a different color inside a headline unless it is the one accent moment on that slide.
- [ ] Sizes meet the minimums in `slide-architecture.md`.

## 2. Contrast

- [ ] Body and list text at least 4.5:1 against its background; large headlines at least 3:1.
- [ ] Text on the accent color uses the dark ink (or light ink on a dark accent) and still passes.
- [ ] Muted text is still readable on a phone in daylight. If in doubt, make it lighter or darker, not smaller.
- [ ] `hyperframes check` reports no contrast failures (it suggests a fix color when it finds one).

## 3. Safe margins and fit

- [ ] Every text box sits 80 px or more from the left and right edges.
- [ ] Nothing important in the top 80 px or the bottom 96 px.
- [ ] No text overflows, clips, wraps into a single orphan word, or overlaps another element at any moment (check frame 0, mid, last).

## 4. Fonts

- [ ] No reflex fonts. Avoid Inter, Roboto, Arial, Open Sans and Poppins as the display face. The templates use League Gothic (display) and Outfit (body), both bundled with HyperFrames.
- [ ] At most two families. Any family outside the HyperFrames bundled set has an `@font-face` pointing at a file in the slide's `assets/fonts/` folder, with its license file next to it.

## 5. Color

- [ ] One accent color, used for small fills and emphasis only (about 10 percent of the frame or less).
- [ ] No pure black (#000) or pure white (#fff); tinted neutrals instead.
- [ ] No gradient text, no neon glows, no purple-blue gradients.
- [ ] The same tokens on every slide.

## 6. Copy

- [ ] No em dashes or en dashes (the long and medium dash characters) anywhere: slides, caption, DM text. Commas, periods, or colons instead. Plain hyphens in words like "follow-up" are fine.
- [ ] Every number, name, result and quote came from the user. Nothing invented.
- [ ] Each slide reads in about 2 seconds. Cut words until it does.
- [ ] No filler words: elevate, seamless, unleash, game-changer, next-level, delve.
- [ ] The CTA keyword on the last slide matches the ManyChat keyword exactly.

## 7. Motion

- [ ] Slide 1: the whole hook is visible at frame 0, motion is decorative only.
- [ ] Each slide has one primary technique from `motion-menu.md`; no neighbors repeat; nothing used more than twice.
- [ ] Every slide is settled by about 60 percent of its length.
- [ ] Ease-out curves, no bounce or elastic, nothing faster than 0.15 s except typing steps.

## 8. HyperFrames gate

- [ ] `hyperframes lint` shows 0 errors in every slide folder.
- [ ] `hyperframes check` passes (fix every error, read every warning).
- [ ] Root `data-duration` is 5 to 7 on every slide, `data-width="1080"`, `data-height="1350"`.

## 9. Grade stills review

After `scripts/grade-stills.sh`, open `stills/contact-sheet.png` and each slide's `frame0.png`, `mid.png`, `last.png`:

- [ ] Slide 1 `frame0.png` shows the full hook and looks like a finished cover.
- [ ] Content slides at `last.png` are fully readable and balanced.
- [ ] No slide looks empty at `mid.png`.
- [ ] The set looks like one carousel (same tokens, same margins, same handle position).

Only then run the full render.
