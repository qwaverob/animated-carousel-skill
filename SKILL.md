---
name: animated-carousel
description: Plan, build and check an animated Instagram carousel made of short MP4 video slides, then walk the user through setting up ManyChat and scheduling in Buffer by hand. Asks one question at a time, offers 5 post concepts, builds one HyperFrames composition per slide (1080x1350, 30fps, 5 to 7 s), renders grade stills before the full render and runs frame QA. Never posts or schedules, never asks for API keys. Includes a daily mode ("daily carousel") with a local posts log. Use when someone wants an animated or video carousel for Instagram, a daily carousel habit, or a comment-to-DM lead magnet post.
---

# Animated carousel

Turn one idea into a 5 to 7 slide animated Instagram carousel: each slide is a short MP4 built from HTML with HyperFrames, checked frame by frame. Then walk the user through two things they do by hand, on free plans: a ManyChat comment keyword DM, and scheduling the post in Buffer. No API keys anywhere.

This file is plain markdown and works in any AI tool: Claude, ChatGPT, Codex, Grok and others. A tool that can run shell commands can do everything, including the render. A chat-only tool can still plan, write the slides and walk the user through each step, and tells the user how to run the render. All paths below are relative to this skill's folder, called `SKILL_DIR` here (the folder that contains this file).

## What is in this folder

| Path | Use |
| --- | --- |
| `references/slide-architecture.md` | Slide roles, cover rule, copy limits, safe areas |
| `references/motion-menu.md` | 18 animation techniques with GSAP snippets and the variety rules |
| `references/quality-pass.md` | Design and copy checklist to run before any render |
| `references/safety-checklist.md` | The safety rules: the user posts, no keys, right account, QA |
| `references/manychat.md` | Manual ManyChat comment to DM setup, free plan, step by step |
| `references/buffer.md` | Manual Buffer scheduling, free plan, step by step, plus the optional API upgrade |
| `references/daily-routine.md` | Daily mode and the `posts-log.md` format |
| `templates/cover-slide/` | HyperFrames project for slide 1 (hook fully visible at frame 0) |
| `templates/content-slide/` | HyperFrames project for slides 2 to N (headline, motion stage with a checklist tick by default, progress bar) |
| `scripts/new-carousel.sh` | Creates a carousel folder with N slide projects copied from the templates |
| `scripts/grade-stills.sh` | Frame 0, middle and last PNG per slide, before the full render |
| `scripts/render-slides.sh` | Renders every slide project to `renders/slide-NN.mp4` |
| `scripts/qa.sh` | Size, codec, duration, black and blank frame, file size and cover frame 0 checks on the MP4s |
| `scripts/contact-sheet.sh` | One PNG grid of every slide for a fast visual review |
| `scripts/doctor.mjs` | Setup check: Node, ffmpeg, skill files, HyperFrames and Chrome. No keys, no network |
| `examples/demo-carousel/` | A 2-slide working example with committed PNG stills |

## Prerequisites

- A computer (Mac or Windows), not a phone: rendering makes video files.
- Node.js 22 or newer (required by the HyperFrames CLI). Planning and copy need nothing installed; only building and rendering do.
- ffmpeg and ffprobe on the PATH.
- HyperFrames CLI: `npm install -g hyperframes` (or prefix every command with `npx hyperframes`). Check with `hyperframes doctor`.
- A shell that runs bash scripts (macOS, Linux, or WSL on Windows).
- For the post itself: an Instagram professional account (Business or Creator), a free ManyChat account and a free Buffer account. No API keys.

## Hard rules (read before every session)

1. Never post or schedule anything. The user schedules the carousel in Buffer and sets up the ManyChat automation themselves. You walk them through it.
2. Never ask for API keys, tokens, passwords or login codes, and never ask the user to paste one into the chat. ManyChat and Buffer are set up by hand. (The one exception is the optional Buffer upgrade in Step 8, and only if the user set it up and asks.)
3. Ask one question at a time, never a list. Wait for the answer before the next question.
4. Never ask the user to edit, rename, stop or delete an existing ManyChat automation. New ones get their own name.
5. Always confirm the Instagram account: repeat the handle and ask "Is <handle> the right account? yes/no".
6. Never invent numbers, results, testimonials, client names, prices, or quotes for slide copy. Use what the user gives you, or leave the claim out.
7. No em dashes or en dashes in any slide copy, caption, or DM text. Use commas, periods, or colons.
8. Never render the full set before the grade stills pass. Never hand over the MP4s before `scripts/qa.sh` passes.
9. On any error, give one plain-English fix. Never show a stack trace or raw error dump. If still stuck, use https://hedgestone-ai-training.vercel.app/stuck. Still stuck? Submit it here: https://hedgestone-ai-training.vercel.app/questions

## The flow

### Step 0. Run the doctor

Before asking any question, from this skill folder run:

```bash
node scripts/doctor.mjs
```

It checks only this computer: Node 22+, ffmpeg and ffprobe, the skill files, HyperFrames and Chrome. No keys and no network. Explain every red line in plain English with one fix, and stop until required items are fixed. It ends with one info line, "ManyChat and Buffer are set up by hand, no keys needed." That line is not a problem.

If you cannot run commands, skip this step, say so, and tell the user they will need Node, ffmpeg and HyperFrames on their computer for the render.

### Step 1. Map the idea

Ask one short question at a time, never a list. Start with the first missing answer below. After the user answers, ask the next missing question.

1. Who is this for? (one sentence: who they are and what they want)
2. What is the topic or offer this post is about?
3. What should the post do? (saves, shares, follows, or DMs for a lead magnet)
4. What comment keyword should trigger the DM, and what link should the DM send? (for example GUIDE or CHECKLIST; a Google Drive file shared as "Anyone with the link can view" works well)
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

### Step 8. Walk the user through ManyChat and Buffer (after the carousel is approved)

Follow `references/safety-checklist.md`. You never post or schedule, and you never ask for keys. The user does the clicks. Give **one step at a time**, wait until the user says it is done, then give the next.

1. Confirm the Instagram account (repeat the handle, ask yes/no). It must be a professional account (Business or Creator).
2. **ManyChat**, from `references/manychat.md`: the free plan steps (sign up, connect Instagram, the "Auto-DM links from comments" template, keyword, opening DM, optional follow-first DM, link, follow-up DM, Go Live). On the free plan "Any post or reel" is locked, so the automation is attached to the specific post right after it goes live. Do the account steps now and the automation steps once the post is live.
3. **Buffer**, from `references/buffer.md`: connect Instagram, New > Post, type Post (not Reel), drag in the MP4s in order, paste the caption, date and time, Schedule, check the Publish calendar. Give the user the MP4 paths (`renders/slide-01.mp4` first) and the caption to copy. The free plan holds up to 10 scheduled posts per channel at a time. A scheduled first comment is optional and needs Buffer's Essentials plan; on Free, the user posts the first comment right after the post goes live.
4. After the post is live: the ManyChat automation on that post, then a test comment from a friend's or a second account (not their own).
5. Once the user says it is scheduled, add it to `posts-log.md`.

If the user's tool can connect Google Drive, you may offer to make the giveaway guide or checklist as a Google Doc. Remind them to share it as "Anyone with the link can view". This is optional.

**Optional and secondary: the Buffer API upgrade.** Only if the user has set up the optional Buffer API key (every Buffer plan has API access, Free includes 1 key; see the end of `references/buffer.md`) **and** explicitly asks you to use it, you may create a Buffer **draft** after showing the dry run in that file and getting an explicit "yes". The user still schedules it in Buffer. Never suggest this as a required step.

### Step 9. Daily routine mode

When the user says "daily carousel", follow `references/daily-routine.md`:

1. Read `posts-log.md` (create it if missing) so you never repeat a past hook, topic, or format two days in a row.
2. Offer 5 fresh ideas (hook, angle, format, slide count).
3. Build the one they pick with Steps 4 to 7.
4. Walk the user through scheduling it in Buffer and the ManyChat automation, as in Step 8. Log it once they say it is scheduled.

Do not set up scheduled jobs or background automations for the daily routine.

## Safety checklist (run at every step)

- [ ] One question at a time; plan approved by the user before building (Step 2).
- [ ] No invented numbers, names, results, or quotes in the copy.
- [ ] Grade stills reviewed before the full render; slide 1 frame 0 shows the full hook.
- [ ] `qa.sh` prints `QA PASS` (1080x1350, 3 to 15 s each, no black frames, sane sizes).
- [ ] Carousel approved by the user (Step 7).
- [ ] Instagram handle confirmed with a yes.
- [ ] ManyChat walked through by hand, one step at a time; nothing existing edited.
- [ ] Buffer walked through by hand; the user scheduled it, not you.
- [ ] No key asked for, pasted or printed.
- [ ] Logged in `posts-log.md` only after the user scheduled it.

The long version, with the reasons for each check, is `references/safety-checklist.md`.

## Troubleshooting

| Problem | Fix |
| --- | --- |
| `hyperframes` not found | `npm install -g hyperframes`, or use `npx hyperframes` |
| Render fails to launch Chrome | `hyperframes browser ensure`, then `hyperframes doctor` |
| Text clipped or overflowing | Shorten the copy first; then reduce the font size token; never shrink below the minimums in `references/slide-architecture.md` |
| `qa.sh` reports black frames | A slide is empty at some moment (usually the start of a content slide before the entrance). Make the background and headline visible from frame 0 and only animate the motion stage |
| Wrong duration | Set `data-duration` on the root element of that slide's `index.html` |
| ManyChat says upgrade for API | Not needed. Skip it and use the manual steps in `references/manychat.md` |
| "Any post or reel" is locked in ManyChat | That is the free plan. Post first, then set the automation on that specific post |
| The user is on a phone | They need a computer (Mac or Windows) to render the videos |
| Still stuck | Go to https://hedgestone-ai-training.vercel.app/stuck |
