# animated-carousel

An AI skill that turns one idea into an animated Instagram carousel: 5 to 7 short MP4 video slides, built from HTML with [HyperFrames](https://hyperframes.heygen.com), checked frame by frame, then paired with a ManyChat comment keyword DM walkthrough and a Buffer draft after you say yes.

It is plain markdown plus a few bash scripts, so it works in Claude Code, Codex, Grok, or any AI tool that can read files and run shell commands.

## What it does

1. Runs a setup check (`node scripts/doctor.mjs`), then asks you short questions one at a time (audience, topic or offer, goal, comment keyword, look).
2. Gives you 5 different post concepts with hook, angle, format and slide count. You pick and edit until you approve.
3. Builds one HyperFrames composition per slide: 1080x1350, 30 fps, 5 to 7 s each. Slide 1 shows the whole hook from frame 0, because frame 0 is your cover.
4. Gives every slide a different animation from an 18-technique motion menu (mask reveals, counter roll, bars, checklist ticks, card stacks, split wipes, word swaps, path draws, zoom-through, before and after, typing mockups, marquee and more).
5. Runs a design quality pass, renders still frames for review, then the full MP4s, then automatic QA (size, codec, duration, black and blank frames, cover check) and a contact sheet.
6. After you approve the carousel: guides the ManyChat comment keyword DM setup and creates a Buffer draft, always with a dry run and an explicit "yes" first.
7. Optional daily mode: 5 fresh ideas a day, checked against a local `posts-log.md` so nothing repeats.

Nothing is posted or scheduled. A Buffer draft is created only after your explicit yes.

## What is inside

```
SKILL.md                     the skill: flow, rules, safety checklist
references/
  slide-architecture.md      slide roles, cover rule, copy limits, safe areas
  motion-menu.md             18 animation techniques with GSAP snippets, variety rules
  quality-pass.md            design and copy checklist before rendering
  safety-checklist.md        confirm gates, dry runs, key handling, pre-upload checks
  manychat.md                what the ManyChat API can and cannot do (checked 2026-10-28)
  buffer.md                  what Buffer can and cannot do for video carousels (checked 2026-10-28)
  daily-routine.md           daily mode and the posts-log.md format
templates/
  cover-slide/               HyperFrames project for slide 1
  content-slide/             HyperFrames project for slides 2 to N
scripts/
  new-carousel.sh            make a carousel folder with N slide projects
  grade-stills.sh            frame 0, middle and last PNG per slide, before rendering
  render-slides.sh           render every slide to MP4 (H.264, yuv420p, 30 fps)
  qa.sh                      frame QA, prints QA PASS or QA FAIL
  contact-sheet.sh           one PNG grid of the whole carousel
examples/demo-carousel/      a 2-slide demo with its stills and QA report
```

## Prerequisites

- **Node.js 22 or newer** (required by the HyperFrames CLI).
- **ffmpeg and ffprobe** on your PATH. macOS: `brew install ffmpeg`. Debian or Ubuntu: `sudo apt install ffmpeg`.
- **HyperFrames CLI**: `npm install -g hyperframes`, then `hyperframes doctor` to check Chrome and ffmpeg. Without a global install the scripts fall back to `npx hyperframes`.
- **bash** (macOS, Linux, or WSL on Windows).
- For publishing (optional): a ManyChat account connected to your Instagram, and a Buffer account with your Instagram channel connected.

## Install

Clone or download this repo first:

```bash
git clone <REPO_URL> animated-carousel-skill
```

From the skill folder, run the setup check before you start:

```bash
node scripts/doctor.mjs
```

Fix each red line before rendering. ManyChat and Buffer keys are optional until you are ready to publish.

### Claude Code

```bash
mkdir -p ~/.claude/skills
cp -R animated-carousel-skill ~/.claude/skills/animated-carousel
```

Start a new Claude Code session. The skill loads by name (`animated-carousel`); you can also just paste the kickoff prompt below.

### Codex

Recent Codex versions load skills from a skills folder:

```bash
mkdir -p ~/.codex/skills
cp -R animated-carousel-skill ~/.codex/skills/animated-carousel
```

If your Codex version does not pick up skills, add one line to the `AGENTS.md` in your project folder instead:

```
For Instagram carousel work, read and follow <path to>/animated-carousel-skill/SKILL.md.
```

### Grok

Grok's file and tool features differ between the web app, the apps, and any coding agent you run it in, so check what your setup supports:

- **Grok in a tool that can read files and run commands:** open this folder as the workspace and paste the kickoff prompt. It works like the other tools.
- **Grok chat (web or app):** attach `SKILL.md` and the files in `references/` to the conversation (or paste `SKILL.md`), then paste the kickoff prompt. Chat-only Grok can do the planning, concepts, copy and the ManyChat and Buffer walkthroughs, but it cannot run the render scripts. Run those yourself in a terminal, or use a tool that can.

### Any other AI tool

Point it at `SKILL.md` and ask it to follow the file. All paths in the skill are relative to its own folder.

## Kickoff prompt

Paste this as your first message:

```text
Load the animated-carousel skill, or read its SKILL.md, and follow it.

Before anything else, run `node scripts/doctor.mjs` from the skill folder. Explain every red line in plain English with one fix, and stop until required items are fixed. Keys are optional until publishing, but tell me what is missing.

Ask me one question at a time, never a list. Give me 5 different concepts. I pick or edit one. Build 5 to 7 slides. Slide 1 shows the full hook from frame 1. Use a different animation on each slide. Show stills before the full render, then run QA.

Publishing: never post or schedule. Show me a dry run first. Only after I say yes, create a Buffer draft. I post it myself from Buffer.

ManyChat: its API cannot create comment automations. Walk me through the in-app setup, step by step. Use THIS as the default keyword and put my link in the DM. Never edit an existing automation. Then tell me to comment with the keyword on my own post to check that the DM arrives.

On any error, give me one plain-English fix. Never show a stack trace or raw error dump. If still stuck, open the Stuck page on the Hedgestone AI Training site: https://ai-broker-training.vercel.app/stuck

Never ask me to paste keys in chat or print keys. Never invent numbers or results. No em dashes.

Daily mode: if I say "daily carousel", read posts-log.md, give me 5 fresh ideas that do not repeat past posts, then follow the same steps.

Still stuck? Submit it here: https://ai-broker-training.vercel.app/questions
```

## Run the scripts yourself

```bash
SK=~/.claude/skills/animated-carousel        # or wherever you put this folder
bash $SK/scripts/new-carousel.sh carousels/2026-01-15-my-topic 6
# edit carousels/2026-01-15-my-topic/slides/slide-NN/index.html
bash $SK/scripts/grade-stills.sh carousels/2026-01-15-my-topic   # look at stills/ first
bash $SK/scripts/render-slides.sh carousels/2026-01-15-my-topic
bash $SK/scripts/qa.sh carousels/2026-01-15-my-topic             # must print QA PASS
bash $SK/scripts/contact-sheet.sh carousels/2026-01-15-my-topic
```

Preview a slide live while editing: `cd carousels/2026-01-15-my-topic/slides/slide-02 && hyperframes preview`.

## ManyChat and Buffer, in short

Full findings, with the doc URLs read and the date checked, are in `references/manychat.md` and `references/buffer.md`.

- **ManyChat:** the public API cannot create automations, triggers, or comment keyword rules. The skill walks you through building the comment trigger in the ManyChat app and only uses the API (if you have a key) for read-only checks such as which account the key belongs to and which automations already exist. The comment trigger fires on a person's first comment on the post.
- **Buffer:** the current API is GraphQL and takes media as public HTTPS links (no file upload). The Buffer app supports Instagram carousels with videos; a video-only carousel through the API is not documented, so the skill creates a draft for you to check and post in Buffer. If your AI tool has a Buffer connector, the skill uses that connector's own tools.

## Safety

- Dry run and explicit "yes" before a Buffer draft is created. The skill never posts or schedules.
- The Instagram handle is printed and confirmed before a Buffer draft is created.
- Existing ManyChat automations are never edited; new ones get unique names.
- Keys only from environment variables (`MANYCHAT_API_KEY`, `BUFFER_API_KEY`, or `BUFFER_ACCESS_TOKEN`), never printed, never pasted in chat.
- Renders must pass `scripts/qa.sh` before a Buffer draft is created.
- No invented numbers, results, names, or quotes in your copy.

The scripts never send frames to any outside service. (HyperFrames `snapshot` can call a vision API when `GEMINI_API_KEY` is set; the scripts unset it for that call.)

## Stuck?

If a plain-English fix does not unblock you, open the Stuck page on the Hedgestone AI Training site: https://ai-broker-training.vercel.app/stuck

Still stuck? Submit it here: https://ai-broker-training.vercel.app/questions

## Credits and licenses

- This repo: MIT (see `LICENSE`).
- [HyperFrames](https://www.npmjs.com/package/hyperframes) (Apache-2.0) renders the slides.
- [GSAP](https://gsap.com) is loaded from the jsDelivr CDN at a pinned version with a subresource integrity hash; it is not bundled here. GSAP is free to use under its own [standard license](https://gsap.com/standard-license).
- Fonts: League Gothic and Outfit are part of the font set bundled with the HyperFrames CLI, so no font files are shipped here. Both are open-licensed (SIL Open Font License). If you swap in other fonts, put the files and their licenses in the slide's `assets/fonts/` folder.
