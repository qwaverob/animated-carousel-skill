---
name: animated-carousel
description: Plan, build, check and (only after explicit approval) publish an animated Instagram carousel made of short MP4 video slides. Asks 3 to 5 mapping questions, offers 5 post concepts, builds one HyperFrames composition per slide (1080x1350, 30fps, 5 to 7 s), renders grade stills before the full render, runs frame QA, then guides a ManyChat comment-keyword DM automation and Buffer scheduling with dry runs and a hard "yes" gate. Includes a daily routine mode with a local posts log. Use when someone wants an animated or video carousel for Instagram, a daily carousel habit, or a comment-to-DM lead magnet post.
---

# Animated carousel

Turn one idea into a 5 to 7 slide animated Instagram carousel: each slide is a short MP4 built from HTML with HyperFrames, checked frame by frame, then (only when the user says yes) wired to a comment keyword DM in ManyChat and scheduled in Buffer.

This file is plain markdown and works in any AI coding tool that can read files and run shell commands (Claude Code, Codex, Grok and others). All paths below are relative to this skill's folder, called `SKILL_DIR` here (the folder that contains this file).

## What is in this folder

| Path | Use |
| --- | --- |
| `references/slide-architecture.md` | Slide roles, cover rule, copy limits, safe areas |
| `references/motion-menu.md` | 18 animation techniques with GSAP snippets and the variety rules |
| `references/quality-pass.md` | Design and copy checklist to run before any render |
| `references/safety-checklist.md` | Every confirm gate, dry run and pre-upload check |
| `references/manychat.md` | What the ManyChat API can and cannot do, plus in-app setup steps |
| `references/buffer.md` | What Buffer can and cannot do for video carousels, plus publish steps |
| `references/daily-routine.md` | Daily mode and the `posts-log.md` format |
| `templates/cover-slide/` | HyperFrames project for slide 1 (hook fully visible at frame 0) |
| `templates/content-slide/` | HyperFrames project for slides 2 to N (headline plus motion stage) |
| `scripts/new-carousel.sh` | Creates a carousel folder with N slide projects copied from the templates |
| `scripts/grade-stills.sh` | Frame 0, middle and last PNG per slide, before the full render |
| `scripts/render-slides.sh` | Renders every slide project to `renders/slide-NN.mp4` |
| `scripts/qa.sh` | Size, codec, duration, black frame and file size checks on the MP4s |
| `scripts/contact-sheet.sh` | One PNG grid of every slide for a fast visual review |
| `examples/demo-carousel/` | A 2-slide working example with committed PNG stills |

## Prerequisites

- Node.js 22 or newer (the HyperFrames CLI asks for 22+; Node 18 and 20 may work for planning but not for rendering).
- ffmpeg and ffprobe on the PATH.
- HyperFrames CLI: `npm install -g hyperframes` (or prefix every command with `npx hyperframes`). Check with `hyperframes doctor`.
- A shell that runs bash scripts (macOS, Linux, or WSL on Windows).

## Hard rules (read before every session)

1. Never post, schedule, upload, or create an automation without the user typing an explicit "yes" to a dry run that shows exactly what will happen. "Looks good" about the design is not a yes to publish.
2. Never print, log, or echo an API key or token. Read keys only from environment variables, and mask them in any output (`sk_live...` becomes `****1a2b`).
3. Never edit, rename, or delete an existing ManyChat flow or automation. List what exists, then create a new one with a unique name.
4. Always confirm the Instagram account: print the handle you are about to use and ask "Is <handle> the right account? yes/no".
5. Never invent numbers, results, testimonials, client names, prices, or quotes for slide copy. Use what the user gives you, or leave the claim out.
6. No em dashes or en dashes in any slide copy, caption, or DM text. Use commas, periods, or colons.
7. Never render the full set before the grade stills pass. Never upload before `scripts/qa.sh` passes.
8. Do not invent API endpoints. `references/manychat.md` and `references/buffer.md` list what was verified in the official docs and when. If something there says "not supported", walk the user through the manual steps instead.

## The flow

### Step 1. Map the idea

Ask 3 to 5 short questions, all in one message, numbered so the user can answer fast:

1. Who is this for? (one sentence: who they are and what they want)
2. What is the topic or offer this post is about?
3. What should the post do? (saves, shares, follows, or DMs for a lead magnet)
4. What comment keyword should trigger the DM, and what link should the DM send? (default keyword: THIS)
5. What should it look like? (brand colors, fonts, an account they like, or "keep it clean")

If the user already answered some of these, skip them. Then return **5 post concepts**. Each concept has:

- **Hook**: the exact slide 1 text (under 12 words, a promise or an open loop).
- **Angle**: one sentence on why this works for that audience.
- **Format**: listicle, myth vs fact, before and after, framework, checklist, mistakes, or story.
- **Slides**: the recommended count and a one-line role for each slide.

Make the 5 concepts genuinely different (different formats and different hooks), not five wordings of one idea.

### Step 2. Pick and approve

The user picks one concept. They can ask for edits (new hook, different angle, more or fewer slides). Loop until they say it is approved. Then write the plan to `<carousel-dir>/plan.md`: hook, every slide's on-screen text, the motion technique per slide, the caption, the keyword, and the DM link. Show the plan and get a yes before building.

### Step 3. Slide count

- Default: **5 to 7 slides**. That is enough for a hook, 3 to 5 value slides, and a CTA slide.
- Some creators run 11 to 14 slides for deep lists or step-by-step guides; only do that if the content really has that many distinct points.
- Instagram has raised the carousel limit to 20 items on newer accounts, but the limit differs by account and app version, so **check the current limit in the app** before planning more than 10. Do not promise a number.
- This skill targets 5 to 7 s per video slide and its QA fails anything outside 3 to 15 s. Instagram's own video length limits for carousel items change over time, so check them in the app if you need longer slides.

### Step 4. Slide 1 is the cover

Frame 0 of slide 1 is what people see in the feed and on the profile grid. So:

- The full hook (headline plus any context line) is **readable at frame 0**. No fade in, no typewriter, no mask reveal on the hook.
- Motion on slide 1 is subtle and decorative only: a slow scale drift, an accent bar easing a few pixels, a swipe cue arriving at 1.5 s. Nothing ever covers or hides the hook.
- `templates/cover-slide/` already follows this rule. Keep it.

Full slide roles and copy limits: `references/slide-architecture.md`.

### Step 5. Choose the motion

Open `references/motion-menu.md`. Give every slide one **primary technique** from the menu that fits its content (numbers get a counter roll or bars, a list gets a checklist tick, a comparison gets a split wipe or a before and after slider). Rules:

- No two adjacent slides use the same primary technique.
- No technique is used more than twice in one carousel.
- Slide 1 uses only the cover-safe techniques marked in the menu.
- Every slide reaches its settled, fully readable state by about 60 percent of its length and holds it to the end, so a viewer who swipes early still gets the point.

Write the chosen technique next to each slide in `plan.md`.

### Step 6. Build the slides

1. Create the carousel folder (use a dated slug, outside this skill folder):
   ```bash
   bash SKILL_DIR/scripts/new-carousel.sh carousels/2026-01-15-my-topic 6
   ```
   This makes `slides/slide-01/` from the cover template and `slides/slide-02/` to `slides/slide-06/` from the content template, plus `plan.md` if missing.
2. Edit each `slides/slide-NN/index.html`:
   - Copy goes in the marked text elements. Design tokens (colors, fonts, spacing) are CSS variables at the top of the style block; change them once per carousel for the user's brand, the same values on every slide.
   - Build the slide's motion inside the single paused GSAP timeline, using the snippet from `references/motion-menu.md`.
   - Keep the HyperFrames contract: one paused timeline registered on `window.__timelines`, no `Math.random()` without a seed, no `Date.now()`, no timers, no network calls, animate `x`, `y`, `scale`, `rotation` and `opacity` (never `width`, `height`, `top`, `left`).
3. Spec for every slide: **1080x1350, 30 fps, 5 to 7 s** (set `data-duration` on the root), H.264 yuv420p output.
4. After editing, run the HyperFrames gate in each slide folder and fix every error:
   ```bash
   cd carousels/2026-01-15-my-topic/slides/slide-02 && hyperframes lint && hyperframes check
   ```

### Step 7. Quality pass, then grade stills, then the full render

1. Run the checklist in `references/quality-pass.md` against every slide (type hierarchy, contrast, 80 px safe margins, no text overflow, no reflex fonts, no em dashes, one accent color, copy readable in 2 seconds).
2. Render grade stills only (fast, no MP4 yet):
   ```bash
   bash SKILL_DIR/scripts/grade-stills.sh carousels/2026-01-15-my-topic
   ```
   This writes `stills/slide-NN/frame0.png`, `mid.png`, `last.png` and a `stills/contact-sheet.png`.
3. **Look at the stills.** Open the PNGs (or describe them if your tool can view images). Check slide 1 `frame0.png` shows the whole hook. Check nothing is clipped, overlapping, or unreadable. Fix and repeat until clean.
4. Full render:
   ```bash
   bash SKILL_DIR/scripts/render-slides.sh carousels/2026-01-15-my-topic
   ```
   Use `--quality draft` while iterating; the default is `delivery`.
5. QA and contact sheet:
   ```bash
   bash SKILL_DIR/scripts/qa.sh carousels/2026-01-15-my-topic
   bash SKILL_DIR/scripts/contact-sheet.sh carousels/2026-01-15-my-topic
   ```
   `qa.sh` must print `QA PASS`. It checks 1080x1350, H.264, yuv420p, 30 fps, 3 to 15 s per slide, no black or blank stretches (ffmpeg blackdetect), sane file sizes, and exports `qa/cover-frame0.png`.
6. Show the user: the contact sheet, `qa/cover-frame0.png`, the list of MP4 paths with durations and sizes, and the caption. Ask for approval of the carousel itself. Edits loop back to Step 6.

### Step 8. Automation and publishing (only after the carousel is approved)

Follow `references/safety-checklist.md` for every action in this step.

**ManyChat (comment keyword to DM with link).** Read `references/manychat.md` first. Summary of what it says: the public ManyChat API does not create automations, triggers, or comment keyword rules, so the comment trigger is set up **in the ManyChat app**, step by step, with the user clicking. Use the API only for the read-only checks the reference lists (for example confirming which page or account the API key belongs to), and only with `MANYCHAT_API_KEY` from the environment. Never edit an existing automation; create a new one named like `carousel-<date>-<keyword>`.

The comment trigger usually needs the post to exist (a specific post or reel), so the normal order is: publish or schedule the post, then attach the ManyChat trigger to that post, then test it with a comment from a second account. If the user's ManyChat plan supports a "next post" option, the reference explains it.

**Buffer (schedule or post).** Read `references/buffer.md` first. It records what Buffer currently supports for Instagram carousels made of videos and what it does not. Then:

- If the user's AI tool has a Buffer connector, use that connector's own tools. List the connected channels, print the Instagram channel name and handle, and ask the user to confirm it.
- If they use the Buffer API, read the token from an environment variable named in `references/buffer.md`, never from the chat.
- If neither path supports a video carousel, give the user the manual steps in the Buffer app (or the Instagram app) and the exact files and caption to use.

**Dry run before anything is sent.** Print a block like this and wait:

```
DRY RUN (nothing has been sent)
Account:   @<YOUR_IG_HANDLE> (Instagram, via Buffer)
Action:    schedule carousel, 6 video slides
When:      2026-01-16 09:00 America/New_York
Files:     renders/slide-01.mp4 (6.0 s, 2.1 MB) ... renders/slide-06.mp4
Caption:   <first 2 lines of caption>...
ManyChat:  new automation "carousel-2026-01-16-THIS", keyword THIS, DM link <YOUR_LINK>
Type yes to do exactly this, or tell me what to change.
```

Only an explicit "yes" (or "yes, post it") proceeds. Anything else is a no. After acting, report what was done with any IDs or links returned, and append the post to `posts-log.md`.

### Step 9. Daily routine mode

When the user asks for a daily carousel habit, follow `references/daily-routine.md`:

1. Read `posts-log.md` (create it if missing) so you never repeat a past hook, topic, or format two days in a row.
2. Offer 5 fresh ideas (hook, angle, format, slide count).
3. Build the one they pick with Steps 4 to 7.
4. Publish only after the dry run and an explicit yes, then log it.

Do not set up scheduled jobs or background automations for the daily routine unless the user asks for that separately and confirms it.

## Safety checklist (run at every step)

- [ ] Plan approved by the user before building (Step 2).
- [ ] No invented numbers, names, results, or quotes in the copy.
- [ ] Grade stills reviewed before the full render; slide 1 frame 0 shows the full hook.
- [ ] `qa.sh` prints `QA PASS` (1080x1350, 3 to 15 s each, no black frames, sane sizes).
- [ ] Carousel approved by the user (Step 7).
- [ ] Instagram handle printed and confirmed with a yes.
- [ ] ManyChat: existing automations listed or checked in the app, new one has a unique name, nothing existing was edited.
- [ ] Dry run shown with account, action, time, files, caption, keyword and link.
- [ ] Explicit "yes" received for this exact dry run.
- [ ] No key or token printed anywhere; keys come only from environment variables.
- [ ] Post logged in `posts-log.md`.

The long version, with the reasons for each check, is `references/safety-checklist.md`.

## Troubleshooting

| Problem | Fix |
| --- | --- |
| `hyperframes` not found | `npm install -g hyperframes`, or use `npx hyperframes` |
| Render fails to launch Chrome | `hyperframes browser ensure`, then `hyperframes doctor` |
| Text clipped or overflowing | Shorten the copy first; then reduce the font size token; never shrink below the minimums in `references/slide-architecture.md` |
| `qa.sh` reports black frames | A slide is empty at some moment (usually the start of a content slide before the entrance). Make the background and headline visible from frame 0 and only animate the motion stage |
| Wrong duration | Set `data-duration` on the root element of that slide's `index.html` |
| Buffer or ManyChat says unsupported | Use the manual steps in the matching reference file; do not look for workarounds that bypass the confirm gates |
