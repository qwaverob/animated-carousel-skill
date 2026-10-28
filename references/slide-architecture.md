# Slide architecture

## Format

- Canvas 1080x1350 (4:5 portrait), 30 fps, 5 to 7 s per slide, H.264 yuv420p MP4.
- One HyperFrames project per slide: `slides/slide-01/`, `slides/slide-02/`, and so on.
- Same design tokens (colors, fonts, margins) on every slide. Change them once at the top of each `index.html`.

## Slide roles

| Slide | Role | Notes |
| --- | --- | --- |
| 1 | Cover hook | The promise or open loop, plus one context line. Fully visible at frame 0. Swipe cue. |
| 2 | Strongest point | Swipe-through drops on every slide, so the best value goes early. |
| 3 to N-1 | One point per slide | Each slide stands alone and reads in about 2 seconds. |
| N | Payoff and CTA | One-line recap worth saving, then one ask: "Comment THIS and I will DM you the link." |

Default 5 to 7 slides. A 5-slide spine: hook, point, point, point, CTA. A 7-slide spine adds two points. Deep lists can run 11 to 14 slides, but only when every slide earns its place, and check the account's current carousel limit in the app before planning more than 10.

## The cover rule (slide 1)

Frame 0 of slide 1 is the Instagram cover in the feed and on the profile grid.

- The whole hook and its context line are on screen and readable at frame 0.
- No entrance animation on the hook: no fade, no typing, no mask, no word swap.
- Motion on slide 1 is decorative and subtle: background drift, a 1 to 2 percent scale breathe, an underline or arrow drawing beneath visible text, a swipe cue nudge.
- `scripts/qa.sh` compares frame 0 with the settled cover and fails if frame 0 shows much less.

## Copy limits

| Element | Limit |
| --- | --- |
| Hook (slide 1) | Under 12 words, at most 4 lines |
| Context line (slide 1) | One sentence, at most 2 lines |
| Content headline | Under 10 words, 2 lines (3 at most) |
| List items | 3 to 5 items, each under 6 words |
| Body sentence | One per slide, at most 2 lines |
| CTA slide | The keyword in large type, one line on what they get |

If copy does not fit, cut words. Do not shrink type below the minimums.

## Type sizes at 1080 px wide

| Role | Template size | Minimum |
| --- | --- | --- |
| Cover hook | 156 px | 110 px |
| Content headline | 124 px | 88 px |
| List item or body | 46 px | 36 px |
| Context line | 42 px | 34 px |
| Handle, slide count | 30 px | 26 px |

Phones show the slide at about a third of this size, so 36 px here is roughly 12 px on screen. Nothing smaller.

## Safe areas

- Side margins at least 80 px (templates use 88 px). The profile grid and some feed layouts crop the edges a little.
- Keep text at least 80 px from the top and 96 px from the bottom.
- Do not put anything important in the bottom 160 px of slide 1 except the swipe cue; Instagram can overlay UI there.
- Text never overflows its box, never touches another element, never runs under the progress bar.

## Layout patterns that fit 4:5

- **Left-aligned stack** (templates): top row, headline, stage, progress bar. Reliable and readable.
- **Big number left, label right**: only when the number is the user's real figure.
- **Split halves**: this vs that, 50/50 with a divider.
- **Full-bleed statement**: a single sentence at headline size, used once per carousel for emphasis.

## CTA slide pattern

- Large keyword set in the display face (for example `THIS`), inside the accent color block or with an accent underline.
- One line: what they receive in the DM ("the full checklist", "the template", "the calculator").
- Optional small line: "Comment below, I will send it to your DMs."
- The keyword must match the ManyChat trigger exactly. Test it before announcing.

## Caption pattern

1. First line restates the hook (it shows above the "more" fold).
2. Two or three short lines of context, no filler.
3. The ask: "Comment THIS and I will DM you <what they get>."
4. 3 to 5 relevant hashtags if the user wants them.

No em dashes or en dashes in the caption, slides, or DM text.
