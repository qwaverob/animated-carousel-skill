# Safety checklist

These rules apply in every tool (Claude, ChatGPT, Codex, Grok or any other) and at every step. When a rule and a request conflict, follow the rule and explain why.

## 1. The user posts, not the AI

- Never post, schedule or publish anything. The user schedules the carousel in Buffer and sets up ManyChat by hand.
- Do not create scheduled jobs, cron entries or background automations, including for daily mode.
- "Looks good" about a design is approval of the design. It is not a request to post.

## 2. No keys

- Never ask for an API key, token, password or login code, and never ask the user to paste one into the chat.
- ManyChat and Buffer are set up by hand. The doctor does not check for keys.
- Only exception: the optional Buffer API upgrade in `buffer.md`. Use it only if the user set it up and explicitly asks. Then the key comes from the `BUFFER_API_KEY` environment variable, is never printed, logged or committed, and you only create a draft after a dry run and an explicit "yes".

## 3. The right Instagram account

- Ask which Instagram account the post is for and repeat the handle back: "Is @<handle> the right account? yes/no".
- It must be a professional account (Business or Creator). If it is personal, give the switch steps: Profile > the three lines (menu) > Settings and activity > Account type and tools > Switch to professional account.

## 4. ManyChat: never overwrite

- Never ask the user to edit, rename, stop or delete an existing automation.
- If a live automation already uses the same keyword, the user picks a new keyword or turns the old one off themselves.
- Each new automation gets a name that is easy to find, for example `Carousel GUIDE 2026-01-15`.

## 5. Check the render before handing it over

`scripts/qa.sh <carousel-dir>` must print `QA PASS`. It checks:

- [ ] Every slide is 1080x1350, H.264, yuv420p, 30 fps.
- [ ] Every slide is 3 to 15 s long (target 5 to 7 s).
- [ ] No black stretches (ffmpeg `blackdetect`) and no blank single-color frames.
- [ ] File sizes are sane (not near zero, not huge).
- [ ] Slide 1 frame 0 shows the full hook (exported as `qa/cover-frame0.png`; also open it and look).

Then open the contact sheet and confirm the order and look of the set.

## 6. Content accuracy

- Business names, numbers, prices, results and quotes come from the user, copied exactly.
- If a detail is missing, ask. Never fill the gap with a plausible guess.
- The giveaway link comes from the user. A Google Drive file must be shared as "Anyone with the link can view", and only once it is ready to be public.

## 7. Errors

- Give one plain-English fix. Never show a stack trace or a raw error dump.
- If still stuck: https://hedgestone-ai-training.vercel.app/stuck

## Quick checklist

- [ ] Plan approved
- [ ] Copy accurate, nothing invented
- [ ] Grade stills reviewed, cover frame 0 shows the full hook
- [ ] `QA PASS`
- [ ] Carousel approved
- [ ] Instagram handle confirmed with a yes
- [ ] ManyChat walked through by hand, nothing existing edited
- [ ] Buffer walked through by hand, the user scheduled it
- [ ] No key asked for or printed
- [ ] Logged in `posts-log.md` only after the user scheduled it
