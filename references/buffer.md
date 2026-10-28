# Buffer: schedule the carousel by hand

Checked: 2026-10-28

The user schedules the post themselves in the Buffer app on the free plan. You never post or schedule. There are no keys in this flow.

## How to guide the user

- Walk through the steps below one at a time. Give one step, wait until the user says it is done, then give the next.
- Before step 4, tell the user where the finished MP4s are (the `renders/` folder of the carousel, `slide-01.mp4` first) and paste the caption so they can copy it.
- Never ask for a key, a password or a login code. The user does the clicks.

## The steps (free plan)

1. **Connect Instagram** (once). In Buffer: Channels > Connect Channel > Instagram. Under "Professional", choose Connect to Instagram, log in, keep all permissions selected, and click Allow. The account must be a professional account (Business or Creator).
2. **New > Post.** The New button is at the top left.
3. **Set the type to Post, not Reel.** A carousel is a Post.
4. **Drag in the slide MP4s, in order.** Slide 1 first, it is the cover.
5. **Paste the caption.** Check the keyword matches the ManyChat keyword exactly.
6. **Add a first comment.** A good place to repeat the keyword.
7. **Set the date and time.**
8. **Schedule.**
9. **Check it in the Publish calendar view.** The post sits on the day and time they picked.

Then, right after it goes live, the user sets the ManyChat automation on that post (see `manychat.md`).

## Tips to share

- Suggested times: 9 AM, 12 PM, 5 PM. 2 to 3 posts a day works.
- After it posts, add a trending audio in the Instagram app: Edit > Music.
- Metricool, Hootsuite or Instagram's own scheduler work the same way, if the user prefers one of those.
- All slides 1080x1350 (4:5). The first item sets the shape for the whole carousel. Export MP4 with H.264 (the render scripts already do).

## Rules

- Never post or schedule. The user does it in Buffer.
- Never ask for or use a Buffer key unless the user has set up the optional upgrade below and asks you to use it.
- Never edit, move or delete posts already in the user's queue.
- Log the post in `posts-log.md` only after the user says it is scheduled or live.

## Optional later upgrade: Buffer API key

This is optional and not needed to start. It is labelled optional everywhere in this skill.

- What it is: a Buffer API key, a paid upgrade, about $6 per channel per month (tell the user to check current pricing). With it, the AI can set up the post in Buffer for the user.
- What it changes: only if the user has set it up and explicitly asks, you may create a Buffer **draft** for them, after a dry run and an explicit "yes". The user still checks the draft and schedules it in Buffer. You never schedule or post.
- Where the key lives: the user makes it in Buffer (Settings > API) and saves it on their own computer as an environment variable named `BUFFER_API_KEY`. Never ask them to paste it into the chat. Never print, log or commit it.

How it works, briefly (from developers.buffer.com, checked 2026-10-28):

- One GraphQL endpoint, `https://api.buffer.com`, always POST, header `Authorization: Bearer <key>`.
- List organizations (`account { organizations { id name } }`), then channels (`channels(input: { organizationId })`). Show the Instagram channel name and ask "Is @<handle> the right account? yes/no".
- `createPost` with `saveToDraft: true`, `schedulingType: automatic`, `mode: addToQueue`, `metadata: { instagram: { type: post, shouldShareToFeed: true } }`, and `assets` as an ordered list of `{ video: { url } }`.
- There is no file upload. Each MP4 must be at a public HTTPS link (Drive or Dropbox share links do not work). A video-only carousel through the API is not documented, so always make a draft and let the user check it.

Dry run to show before the one write call:

```
DRY RUN (nothing has been sent)
Account:   @<YOUR_IG_HANDLE> (Instagram, via Buffer)
Action:    create a Buffer draft, <N> video slides (you schedule it in Buffer)
Files:     <public URL, duration> for every slide, in order
Caption:   <full caption>
Type yes to do exactly this, or tell me what to change.
```

## Source

- Buffer Help Center, "Connecting your Instagram account to Buffer": https://support.buffer.com/en-us/articles/connecting-your-instagram-account-to-buffer-n9Ad6veXsu
- Buffer API docs (optional upgrade only): https://developers.buffer.com
