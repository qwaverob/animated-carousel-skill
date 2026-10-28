# animated-carousel

An AI skill that turns one idea into an animated Instagram carousel: 5 to 7 short MP4 video slides, built from HTML with [HyperFrames](https://hyperframes.heygen.com) and checked frame by frame. Then it walks you through two things you do by hand, on free plans: a ManyChat comment to DM, and scheduling the post in Buffer.

No API keys. The AI never posts or schedules anything. You do.

It is plain markdown plus a few scripts, so it works with Claude, ChatGPT, Codex, Grok or any AI tool that can read files. You need a computer (Mac or Windows), not a phone, because the render makes video files.

## What it does

1. Runs a setup check (`node scripts/doctor.mjs`), then asks you short questions, one at a time (audience, topic, goal, comment keyword, look).
2. Gives you 5 different post concepts with hook, angle, format and slide count. You pick and edit until you approve.
3. Builds one HyperFrames composition per slide: 1080x1350, 30 fps, 5 to 7 s each. Slide 1 shows the whole hook from frame 0, because frame 0 is your cover.
4. Gives every slide a different animation from an 18-technique motion menu (mask reveals, counter roll, bars, checklist ticks, card stacks, split wipes, word swaps, path draws, zoom-through, before and after, typing mockups, marquee and more).
5. Runs a design quality pass, shows you still frames before the full render, then renders the MP4s and runs automatic QA (size, codec, duration, black and blank frames, cover check) and a contact sheet.
6. Walks you through ManyChat and Buffer, one step at a time. You do the clicks.
7. Daily mode: say "daily carousel" and it gives you 5 fresh ideas, checked against a local `posts-log.md` so nothing repeats.

## What you need

- A computer (Mac or Windows) with an AI tool: Claude, ChatGPT, Codex or Grok.
- An Instagram professional account (Business or Creator). To switch: Profile > the three lines (menu) > Settings and activity > Account type and tools > Switch to professional account. It's instant and free, and nothing changes for your followers.
- A free ManyChat account and a free Buffer account. No API keys.
- For the render: **Node.js 22 or newer**, **ffmpeg and ffprobe** (macOS: `brew install ffmpeg`, Debian or Ubuntu: `sudo apt install ffmpeg`), the **HyperFrames CLI** (`npm install -g hyperframes`, then `hyperframes doctor` to check Chrome and ffmpeg) and **bash** (macOS, Linux, or WSL on Windows).

## Install

The easiest way, in any tool: paste the kickoff prompt below as your first message. It tells the AI where this repo is and what to do.

To install it yourself, clone the repo, then run the setup check from its folder:

```bash
git clone https://github.com/qwaverob/animated-carousel-skill
cd animated-carousel-skill
node scripts/doctor.mjs
```

The doctor checks Node, ffmpeg, the skill files, HyperFrames and Chrome. Fix each red line before rendering. It never checks for keys.

### Claude Code

```bash
mkdir -p ~/.claude/skills
cp -R animated-carousel-skill ~/.claude/skills/animated-carousel
```

Start a new Claude Code session. The skill loads by name (`animated-carousel`), or just paste the kickoff prompt.

### Codex

```bash
mkdir -p ~/.codex/skills
cp -R animated-carousel-skill ~/.codex/skills/animated-carousel
```

If your Codex version does not pick up skills, add one line to the `AGENTS.md` in your project folder instead:

```
For Instagram carousel work, read and follow <path to>/animated-carousel-skill/SKILL.md.
```

### ChatGPT

Paste the kickoff prompt as your first message. If ChatGPT can't clone the repo, it reads the files from the GitHub link instead. In a chat-only setup it plans the post, writes the slides and walks you through every step, and tells you how to run the render on your computer.

### Grok or any other AI tool

Paste the kickoff prompt, or point the tool at `SKILL.md` and ask it to follow the file. All paths in the skill are relative to its own folder.

## Kickoff prompt

Paste this as your first message:

```text
Make me an animated Instagram carousel with the animated-carousel skill: https://github.com/qwaverob/animated-carousel-skill

Get the skill first. Use that link, don't search for it. If the skill is already installed, load it. If you can run commands, run git clone https://github.com/qwaverob/animated-carousel-skill then read SKILL.md in that folder and run node scripts/doctor.mjs from it. Explain any red line in plain English with one fix. If you can't run commands, open the link, read SKILL.md and the files it points to, and follow them as closely as you can.

Ask me one question at a time, never a list. Give me 5 different concepts. I pick or edit one. Build 5 to 7 slides. Slide 1 shows the full hook from frame 1. Use a different animation on each slide. Show me stills before the full render, then run QA.

Never post or schedule anything yourself, and never ask me for API keys. When the MP4s are ready, walk me through the manual steps one at a time: the ManyChat comment to DM automation (free plan), then scheduling the post in Buffer myself.

On any error, give me one plain-English fix. Never show a stack trace or raw error dump. Never invent numbers or results. No em dashes.

Daily mode: if I say "daily carousel", read posts-log.md, give me 5 fresh ideas that do not repeat past posts, then follow the same steps.

Stuck? https://hedgestone-ai-training.vercel.app/stuck
Questions? https://hedgestone-ai-training.vercel.app/questions
```

## ManyChat, by hand (free plan)

Full steps: `references/manychat.md`.

1. Sign up free at manychat.com and connect your Instagram professional account.
2. Automation > New Automation > the template "Auto-DM links from comments".
3. Set the keyword (for example GUIDE), write the opening DM, and optionally ask for a follow first (a follow only, no email).
4. Add the link (a Google Drive file shared as "Anyone with the link can view"), a follow-up DM for people who don't click, then Go Live.

On the free plan "Any post or reel" is locked, so post first, then set the automation on that post right away. Test it by commenting the keyword from a friend's or a second account. You don't need ManyChat's API.

## Buffer, by hand (free plan)

Full steps: `references/buffer.md`.

Connect Instagram, then New > Post. Set the type to Post (not Reel), drag in the slide MP4s in order, paste the caption, add a first comment, set the date and time, and Schedule. Check it in the Publish calendar view. Try 9 AM, 12 PM or 5 PM, 2 to 3 posts a day. After it posts, add a trending audio in the Instagram app (Edit > Music). Metricool, Hootsuite or Instagram's own scheduler work the same way.

**Optional, later:** a Buffer API key (about $6 per channel per month, check current pricing) lets the AI set up the post in Buffer as a draft for you. You don't need it to start. See the end of `references/buffer.md`.

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

Test the setup check: `node --test scripts/test/*.test.mjs`.

## What is inside

```
SKILL.md                     the skill: flow, rules, safety checklist
references/
  slide-architecture.md      slide roles, cover rule, copy limits, safe areas
  motion-menu.md             18 animation techniques with GSAP snippets, variety rules
  quality-pass.md            design and copy checklist before rendering
  safety-checklist.md        you post, no keys, right account, QA
  manychat.md                ManyChat comment to DM by hand, free plan
  buffer.md                  Buffer scheduling by hand, free plan, optional API upgrade
  daily-routine.md           daily mode and the posts-log.md format
templates/
  cover-slide/               HyperFrames project for slide 1
  content-slide/             HyperFrames project for slides 2 to N
scripts/
  doctor.mjs                 setup check: Node, ffmpeg, files, HyperFrames, Chrome
  new-carousel.sh            make a carousel folder with N slide projects
  grade-stills.sh            frame 0, middle and last PNG per slide, before rendering
  render-slides.sh           render every slide to MP4 (H.264, yuv420p, 30 fps)
  qa.sh                      frame QA, prints QA PASS or QA FAIL
  contact-sheet.sh           one PNG grid of the whole carousel
  test/                      tests for the setup check
examples/demo-carousel/      a 2-slide demo with its stills and QA report
```

## Safety

- The AI never posts or schedules. You schedule the post in Buffer and set up ManyChat yourself.
- The AI never asks for API keys, passwords or login codes.
- The Instagram handle is repeated back and confirmed with a yes.
- Existing ManyChat automations are never edited.
- Renders must pass `scripts/qa.sh` before you get the MP4s.
- No invented numbers, results, names, or quotes in your copy.

The scripts never send frames to any outside service. (HyperFrames `snapshot` can call a vision API when `GEMINI_API_KEY` is set; the scripts unset it for that call.)

## Stuck?

Quick fixes: https://hedgestone-ai-training.vercel.app/stuck

Still stuck? Submit it here: https://hedgestone-ai-training.vercel.app/questions

## Credits and licenses

- This repo: MIT (see `LICENSE`).
- [HyperFrames](https://www.npmjs.com/package/hyperframes) (Apache-2.0) renders the slides.
- [GSAP](https://gsap.com) is loaded from the jsDelivr CDN at a pinned version with a subresource integrity hash; it is not bundled here. GSAP is free to use under its own [standard license](https://gsap.com/standard-license).
- Fonts: League Gothic and Outfit are part of the font set bundled with the HyperFrames CLI, so no font files are shipped here. Both are open-licensed (SIL Open Font License). If you swap in other fonts, put the files and their licenses in the slide's `assets/fonts/` folder.
