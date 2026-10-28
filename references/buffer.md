# Buffer: create an Instagram video carousel draft

Checked: 2026-10-28

## Sources read

- https://developers.buffer.com (landing page)
- https://developers.buffer.com/llms.txt
- https://developers.buffer.com/guides/getting-started.html
- https://developers.buffer.com/guides/introduction.html
- https://developers.buffer.com/guides/authentication.html
- https://developers.buffer.com/guides/agent-setup.md
- https://developers.buffer.com/guides/posts-and-scheduling.html
- https://developers.buffer.com/guides/hosting-media.html
- https://developers.buffer.com/guides/api-limits.html
- https://developers.buffer.com/guides/rest-migration.md
- https://developers.buffer.com/reference.html (full GraphQL reference)
- https://developers.buffer.com/changelog.md (searched for carousel and Instagram changes)
- https://developers.buffer.com/examples/create-video-post.md
- https://developers.buffer.com/examples/create-instagram-post-with-user-tags.md
- https://developers.buffer.com/guides/integrations/mcp.md
- https://developers.buffer.com/guides/integrations/claude.md, chatgpt.md, grok.md (same folder)
- https://support.buffer.com/articles/using-buffers-api-GtIYIQilz5
- https://support.buffer.com/en-us/articles/using-instagram-with-buffer-YSjg2dXFV8
- https://support.buffer.com/articles/scheduling-instagram-posts-reels-stories-and-notifications-3XA98S9Q5p
- Redirected: https://buffer.com/developers/legacy-api now redirects (301) to the REST migration guide.
- Failed to load: https://support.buffer.com/search?query=instagram%20carousel (404).

## Summary

- Buffer's current API is GraphQL at `https://api.buffer.com` (one endpoint, always POST), with a Bearer API key from Settings > API. It is on every plan, including Free. The old REST API (`api.bufferapp.com/1/`) is called legacy and has a migration guide. Do not use it.
- The API can create Instagram posts with image or video assets, including drafts. This skill only creates drafts. Media must be a public HTTPS URL. There is no upload endpoint.
- The Buffer app supports Instagram carousels of up to 20 images and videos, mixed allowed. The API takes an ordered `assets` list, but Buffer has no Instagram carousel example and does not say that video carousels work through the API. Not verified: test as a draft first.
- Buffer runs an official MCP server (`https://mcp.buffer.com/mcp`) and has OAuth connectors for Claude and Claude Code, ChatGPT and Codex, Grok, Cursor and others. These need no API key.
- Automatic publishing to Instagram needs a Business or Creator account. Otherwise the post goes out as a phone notification that the user finishes by hand.

## What the API can do

- Auth: header `Authorization: Bearer <key>`. Use `BUFFER_API_KEY` or `BUFFER_ACCESS_TOKEN`. The key covers every organization and channel in the account.
- Find the account: `account { organizations { id name } }`.
- Find the Instagram channel: `channels(input: { organizationId })`. Useful fields: `name`, `displayName`, `service` (`instagram`), `type`, `externalLink`, `isDisconnected`, `isLocked`, `isQueuePaused`, `timezone`. Buffer can report a Business or Creator type when it has that information.
- Create a post: `createPost(input: ...)` with `channelId`, `text`, `assets`, `schedulingType`, `mode`, `dueAt`, `saveToDraft`, `metadata`, `tagIds`.
- `schedulingType` and `mode` are required by `createPost`, even with `saveToDraft: true`. Use `automatic` and `addToQueue` for the draft request.
- `saveToDraft: true` saves a draft. It will not be published until explicitly scheduled. This skill does not schedule it.
- Assets: each entry is exactly one of `image`, `video`, or `document`. A video is `{ url, metadata: { thumbnailOffset } }`, where `thumbnailOffset` picks a frame in milliseconds. Do not set `thumbnailUrl` on a video, the API rejects it.
- Instagram metadata: `metadata.instagram` needs `type` and `shouldShareToFeed`. Optional: `firstComment`, `geolocation`, `link`, `isAiGenerated`. Buffer describes Instagram types as post, story, reel. The `PostType` enum also contains `carousel`.
- Also: `editPost`, `deletePost`, `posts` (filter by status: draft, needs_approval, scheduled, sending, sent, error).
- If a channel requires approval, API posts are saved as drafts awaiting approval.
- Rate limits are shared by all keys and MCP connections. Free: 150 per 15 min, 600 per 24 h, 1,000 per channel per 30 days (up to 3,000). Essentials: 450, 1,800, 3,000 per channel (up to 30,000). Team: 1,500, 6,000, 10,000 per channel (up to 100,000). Each response carries `RateLimit` headers.

## What it cannot do, or is unclear

- No file upload. Each MP4 must sit at a public, direct, HTTPS URL that stays live until the post publishes. Drive or Dropbox share links do not work. Signed or expiring links can "fail silently".
- No custom cover image for videos. Pick a frame with `thumbnailOffset`, or put the cover in the video's first frame.
- Not verified: the right payload for an Instagram carousel through the API (multiple assets with `type: post`, or `type: carousel`). No official example exists.
- Not verified: a carousel made only of videos through the API. The app documents mixed carousels, not API behavior.
- Not documented: per item video length, size, or bitrate for carousel items. Buffer lists for Instagram: videos 300 MB or smaller. Reels: 3 seconds to 15 minutes, 25 Mbps video bitrate max, 128 kbps audio max. Stories: 23 to 60 fps. Staying inside the reel limits is a safe target.
- No reading or replying to comments. The comment keyword DM needs ManyChat (see manychat.md).
- Analytics through the API are experimental only.
- Personal Instagram accounts cannot publish automatically.
- This skill does not schedule drafts. The user checks and posts the approved draft from Buffer.

## Recommended path for this skill

1. Best: the user's own Buffer connector or MCP in their AI tool (OAuth, no key handling).
2. Next: the Buffer API with `BUFFER_API_KEY` or `BUFFER_ACCESS_TOKEN`.
3. Fallback that always works: the Buffer app (it documents mixed and video carousels).

Flow for 1 and 2: host the 5 to 7 MP4s publicly > list organizations > list channels > user confirms <YOUR_IG_HANDLE> > dry run > explicit yes > create a draft > user checks and posts it in Buffer.

## Step-by-step

Connector or MCP:

1. Use only the tools your connector lists. Buffer's MCP docs name tools such as `get_account`, `list_channels`, `get_channel`, `list_posts`, `create_post`, and `edit_post`, but your AI tool may show different names. Do not guess.
2. Get the account. If there is more than one organization, ask the user which one.
3. List channels, show every Instagram channel (name and link), and have the user confirm <YOUR_IG_HANDLE>.
4. Dry run: show the channel, caption, ordered video URLs, and the draft action. Do not call any write tool yet.
5. Only after an explicit "yes": create the post with `saveToDraft: true`. Then send the user to Buffer to check and post it.

API: same steps using the read only calls below, then the write template (only after an explicit yes).

Manual, in the Buffer app:

1. Select your Instagram account on the left of the dashboard and open the composer at the top of the queue.
2. Choose Post. Upload the slides in order. Select the Instagram channel first (drafts without a channel are limited to 10 items).
3. Add the caption and save a draft. The user posts it themselves from Buffer.
4. Optional: click Edit Thumbnail and drag the slider to pick a frame.
5. All slides 1080x1350 (4:5) fits Instagram's 3:4 to 1.91:1 range. The first item sets the aspect ratio for the whole carousel. Export MP4 with H.264, not HEVC or MOV.

## Safety rules

- Keep the key only in `BUFFER_API_KEY` or `BUFFER_ACCESS_TOKEN`. Never ask for it in chat. Never print, echo, log, or commit it, and mask it as `****` in output.
- Stay read only until the user says yes. Use `createPost` once to create the draft. Do not edit or delete posts.
- Always list channels and confirm the Instagram handle. Never guess a channel id.
- Never schedule or post. Always use `saveToDraft: true`.
- Never edit, move, or delete posts already in the queue.
- Public media links can be opened by anyone who has them. Only host content that is ready to go public.
- Do not use the legacy REST API.

## Read-only verification example

```bash
if [ -n "$BUFFER_API_KEY" ] || [ -n "$BUFFER_ACCESS_TOKEN" ]; then
  echo "Buffer token is set"
else
  echo "Buffer token is not set"
fi
BUFFER_TOKEN="${BUFFER_API_KEY:-$BUFFER_ACCESS_TOKEN}"

# 1. List organizations
curl -s -X POST "https://api.buffer.com" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $BUFFER_TOKEN" \
  -d '{"query":"query { account { organizations { id name } } }"}'

# 2. List channels for the chosen organization
curl -s -X POST "https://api.buffer.com" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $BUFFER_TOKEN" \
  -d '{"query":"query GetChannels($organizationId: OrganizationId!) { channels(input: { organizationId: $organizationId }) { name displayName service type externalLink isDisconnected isLocked isQueuePaused timezone } }","variables":{"organizationId":"<ORG_ID>"}}'
```

Write template (creates a draft, run only after an explicit yes; carousel shape not verified):

```graphql
mutation {
  createPost(input: {
    channelId: "<IG_CHANNEL_ID>"
    text: "<CAPTION> Comment THIS and I'll DM you the link."
    schedulingType: automatic
    mode: addToQueue
    saveToDraft: true
    assets: [
      { video: { url: "<PUBLIC_MP4_URL_1>", metadata: { thumbnailOffset: 0 } } }
      { video: { url: "<PUBLIC_MP4_URL_2>" } }
    ]
    metadata: { instagram: { type: post, shouldShareToFeed: true } }
  }) {
    ... on PostActionSuccess { post { id status dueAt assets { id mimeType } } }
    ... on MutationError { message }
  }
}
```
