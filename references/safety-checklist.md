# Safety checklist

These rules apply in every tool (Claude Code, Codex, Grok or any other) and at every step. When a rule and a request conflict, follow the rule and explain why.

## 1. Confirm before acting

- Anything that leaves the user's computer (posting, scheduling, uploading media, creating a ManyChat automation, calling any write API) needs an explicit "yes" from the user to a dry run of that exact action.
- "Looks good", "nice", "ok" about a design is approval of the design, not permission to publish. Ask separately.
- A yes covers one dry run. If anything changes (time, account, files, caption, keyword), show a new dry run and ask again.
- Read-only checks (listing channels, reading page info) can run without a yes, but say what you are about to check first.

## 2. Dry run first

Show exactly what will happen, then stop and wait:

```
DRY RUN (nothing has been sent)
Account:   @<YOUR_IG_HANDLE> (Instagram, via <Buffer connector | Buffer API | Buffer app>)
Action:    <create draft | schedule | post now> carousel, <N> video slides
When:      <date time timezone>
Files:     <path or public URL, duration, size> for every slide, in order
Caption:   <full caption>
ManyChat:  <new automation name>, keyword <KEYWORD>, DM link <YOUR_LINK>
Type yes to do exactly this, or tell me what to change.
```

Prefer creating a **draft** first, then scheduling after the user checks it in Buffer. Never use "post now" unless the user asks for it by name.

## 3. Verify the account

- List the connected accounts or channels and print the Instagram handle you plan to use.
- Ask: "Is @<handle> the right account? yes/no". Wait for yes.
- If several Instagram channels are connected, never pick one yourself.
- For ManyChat, the read-only `getInfo` call (see `manychat.md`) shows which account the key belongs to. It must match the same Instagram account.

## 4. Never post without an explicit yes

- No auto-posting, no "I went ahead and scheduled it".
- Daily routine mode does not change this: each day's post needs its own yes.
- Do not create scheduled jobs, cron entries, or background automations unless the user asks for one separately and approves a dry run of it.

## 5. ManyChat: never overwrite

- First list what exists (Automations tab in the app, or the read-only `getFlows` call).
- Point out any live comment automation that targets all posts or uses the same keyword; ask the user how to handle it before continuing.
- Always create a **new** automation with a unique name, for example `carousel-<YYYY-MM-DD>-<KEYWORD>`.
- Never edit, rename, stop, or delete an existing automation, and never regenerate or delete the API key.

## 6. Keys and tokens

- Keys come only from environment variables (`MANYCHAT_API_KEY`, `BUFFER_API_KEY`). Never ask the user to paste a key into the chat.
- Never print, echo, or log a key. Check presence with `[ -n "$MANYCHAT_API_KEY" ] && echo set`.
- Mask in any output: show at most the last 4 characters, like `****1a2b`.
- Do not run shell tracing (`set -x`) in a session that uses keys.
- Never write keys into files that could be committed. `.env*` is in `.gitignore`.

## 7. Check the render before upload

`scripts/qa.sh <carousel-dir>` must print `QA PASS`. It checks:

- [ ] Every slide is 1080x1350, H.264, yuv420p, 30 fps.
- [ ] Every slide is 3 to 15 s long (target 5 to 7 s).
- [ ] No black stretches (ffmpeg `blackdetect`) and no blank single-color frames.
- [ ] File sizes are sane (not near zero, not huge).
- [ ] Slide 1 frame 0 shows the full hook (exported as `qa/cover-frame0.png`; also open it and look).

Then open `qa/contact-sheet.png` and confirm the order and look of the set.

## 8. Content accuracy

- Business names, numbers, prices, results and quotes come from the user, copied exactly.
- If a detail is missing, ask. Never fill the gap with a plausible guess.

## 9. Public media links

Buffer's API and connector need each MP4 at a public HTTPS link. Anyone with the link can open it. Only host files that are approved and ready to be public, and tell the user where they are hosted.

## Quick checklist

- [ ] Plan approved
- [ ] Copy accurate, nothing invented
- [ ] Grade stills reviewed, cover frame 0 shows the full hook
- [ ] `QA PASS`
- [ ] Carousel approved
- [ ] Instagram handle confirmed with a yes
- [ ] ManyChat: existing automations checked, new unique name, nothing edited
- [ ] Dry run shown
- [ ] Explicit yes for this dry run
- [ ] No key printed
- [ ] Post logged in `posts-log.md`
