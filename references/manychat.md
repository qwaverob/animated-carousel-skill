# ManyChat: comment keyword to DM link

Checked: 2026-10-28

## Sources read

- https://api.manychat.com/swagger (page shell only, it loads the two specs below)
- https://api.manychat.com/swagger/compileJson?type=Page_API (OpenAPI spec, read in full)
- https://api.manychat.com/swagger/compileJson?type=Profile_API (OpenAPI spec, read in full)
- https://help.manychat.com/hc/en-us/articles/14959510331420-How-to-generate-a-token-for-the-Manychat-API-and-where-to-get-parameters
- https://help.manychat.com/hc/en-us/articles/14281252007580-Dev-Tools-Basics
- https://help.manychat.com/hc/en-us/articles/14281316989724-Instagram-Post-and-Reel-Comments-trigger
- https://help.manychat.com/hc/en-us/articles/16654065283100-Quick-Automation-Auto-DM-links-from-comments
- https://help.manychat.com/hc/en-us/articles/26673580447900-Response-Reference-for-Instagram-WhatsApp-and-Telegram-Automation
- Note: help.manychat.com article pages returned 403 to automated fetches. The articles above were read through the Help Center's public article JSON (`help.manychat.com/api/v2/help_center/en-us/articles/<id>.json`), which serves the same article body.
- Failed to load: https://manychat.com/pricing (403). Plan details below come from the help articles only.

## Summary

- The ManyChat public API is a contact and messaging API. It cannot create automations, triggers, keyword rules, or Instagram comment automations. ManyChat's own docs say: "If you cannot see a method you are looking for, then there isn't a method like that."
- The comment keyword to DM automation must be built by the user in the ManyChat app (web or mobile). The agent guides, step by step.
- The API is still useful for read only checks: confirm the key works and the right account is connected (`GET /fb/page/getInfo`), and list existing automations by name (`GET /fb/page/getFlows`).
- API access is on paid plans only ("isn't accessible on accounts with a free subscription"). Auth is a Bearer token generated in Settings > API.
- Instagram limit: the comment trigger only fires on a user's first comment under a post. The same user commenting again will not trigger it again.

## What the API can do

Base URL: `https://api.manychat.com`. The spec version is labeled "beta". Every request sends `Authorization: Bearer <API key>`.

Documented Page API endpoints (all of them):

- Page reads: `GET /fb/page/getInfo`, `/fb/page/getFlows`, `/fb/page/getTags`, `/fb/page/getWidgets`, `/fb/page/getGrowthTools`, `/fb/page/getCustomFields`, `/fb/page/getOtnTopics`, `/fb/page/getBotFields`
- Page writes: `POST /fb/page/createTag`, `/fb/page/removeTag`, `/fb/page/removeTagByName`, `/fb/page/createCustomField`, `/fb/page/createBotField`, `/fb/page/setBotField`, `/fb/page/setBotFieldByName`, `/fb/page/setBotFields`
- Sending: `POST /fb/sending/sendContent`, `/fb/sending/sendContentByUserRef`, `/fb/sending/sendFlow`
- Subscriber reads: `GET /fb/subscriber/getInfo`, `/fb/subscriber/findByName`, `/fb/subscriber/getInfoByUserRef`, `/fb/subscriber/findByCustomField`, `/fb/subscriber/findBySystemField`
- Subscriber writes: `POST /fb/subscriber/addTag`, `/addTagByName`, `/removeTag`, `/removeTagByName`, `/setCustomField`, `/setCustomFields`, `/setCustomFieldByName`, `/verifyBySignedRequest`, `/createSubscriber`, `/updateSubscriber`
- Profile API (uses a different key from the profile dashboard): `POST /user/template/generateSingleUseLink`

Useful details:

- `getInfo` returns `id`, `name`, `username`, `category`, `timezone`, `is_pro` and more.
- `getFlows` returns `flows` (each with `ns` "unique Automation ID", `name`, `folder_id`) and `folders`. It does not return triggers, keywords, or which post an automation is attached to.
- `sendFlow` sends an existing automation to one existing contact (`subscriber_id`, `flow_ns`). It cannot reply to a comment.

Rate limits (help article): 100 requests per second for `getInfo`, `getTags`, `getGrowthTools`, `getCustomFields`, `getOtnTopics`, `getBotFields`, `findBySystemField`. 10 per second for `getFlows` and the other subscriber and write methods. 25 per second for sending (the spec lists `sendFlow` at 20 per second and 100 per subscriber per hour). "When you reach the limits, Manychat may stop processing requests for 24 hours."

Channels: every path starts with `/fb/`, and the `getInfo` id is described as "Facebook Page ID". Subscriber records include `ig_username`, `ig_id`, and WhatsApp fields, and the Instagram response reference lists `instagram` as a content type for the Dynamic Block format that `sendContent` accepts. The docs do not state that every endpoint works for an Instagram only account. Not verified: run the read only check below on your own account.

## What it cannot do

- Create, edit, publish, stop, or delete automations (flows).
- Create triggers, keyword rules, Instagram comment triggers, or public comment replies.
- List Instagram posts or attach an automation to a post.
- Read an automation's trigger or keyword settings.
- Message people who only commented. Sending works on existing contacts, and normal messaging rules (24 hour window, message tags) apply.
- Not verified: whether Quick Automations (like "Auto-DM links from comments") show up in `getFlows`.

## Recommended path for this skill

1. Optional: if the user has a key, run the read only check below to confirm the account and see existing automation names.
2. The user builds the automation in the ManyChat app while the agent walks them through it.
3. Timing with Buffer. "Specific post or reel" needs the carousel to be live already. Pick one:
   - Post first, then set up the automation on that specific post right away.
   - Before the post goes live, choose "Next post or reel". ManyChat says you can run only one next post or reel automation at a time. Make sure nothing else publishes first, including other posts in the Buffer queue.
4. Default keyword: THIS. Test from a second Instagram account before announcing.

## Step-by-step (in the ManyChat app)

Option A, Quick Automation (simplest, built for this use case):

1. Open your workspace, click the Automations tab, select My Automations, click +New Automation.
2. Pick "Auto-DM links from comments" (or + Start From Scratch, then Post or Reel Comment).
3. Choose which post: "A specific post or reel", "Any post or reel", or "Next post or reel". Pick the carousel, or Next post or reel.
4. Set the words a comment must include: THIS. Do not allow any comment.
5. Optional public reply under the comment: up to three custom messages that ManyChat shuffles.
6. Opening DM (optional toggle): a first message with a button. Tapping it opts the user in.
7. Optional extras: ask them to follow you first, ask for an email. Leave off for the simple version.
8. Main DM: a message with up to three links. Add <YOUR_LINK>.
9. Optional follow-up DM if the link is not clicked.
10. Click Go Live in the top right corner. Edit later with Edit, then Update. Stop with Stop.

Option B, Flow Builder:

1. Automation tab > + New Automation > + Start From Scratch > Start with a blank.
2. Click +New Trigger, open the Instagram tab, select "User comments on your Post or Reel".
3. Choose Specific post or reel, All post or reels, or Next post or reel. Click Continue.
4. Keywords: "Include certain words", add THIS. Click Continue.
5. Optional public replies (several variations, rotated randomly). Click Save.
6. Add an Instagram Send Message node and select "Send as a Private Reply". Add a button with <YOUR_LINK>.
7. First private reply limits: one content block (text or image with buttons or Quick Replies), no User input, no Next Steps in that node.
8. Click Preview (in ManyChat or on Instagram), then Set Live.

Name it uniquely, for example "Carousel THIS <YYYY-MM-DD>". Where to rename may differ slightly in your account.

Good to know (from the help articles):

- A button set to "Open website" does not opt the user in or open the 24 hour window. Fine for one link. Use a Quick Reply or the Opening DM if you want them as contacts.
- To avoid spam flags, vary reply wording and avoid very short or emoji only replies.
- With several comment automations: if more than one is set to all posts with no keywords, the oldest runs. With keywords, each keyword runs its own automation.
- Collab posts work when the original poster's account is connected. Boosted posts work if the post is on your grid.
- Not verified: keyword matching rules (case, punctuation, partial words). Test "THIS", "this", and "this!".
- Not verified: carousels are not named explicitly in the docs ("post or reel"). A carousel is a feed post. Test before launch.

## Safety rules

- List existing automations first (Automations tab, or `getFlows`). Note any live comment automation set to any post or using THIS, and ask the user before going ahead.
- Always create a new automation with a unique name. Never edit, overwrite, stop, or delete existing automations unless the user explicitly asks.
- Keep the API key only in the env var `MANYCHAT_API_KEY`. Never ask the user to paste it in chat. Never print, echo, log, or commit it. Mask it as `****` in any output. Do not run shell tracing (`set -x`).
- Do not regenerate or delete the key in Settings > API. ManyChat warns: "Refreshing and deleting your token will disable all connected API methods."
- The agent makes GET requests only. No POST call (send, tag, field, subscriber) without an explicit yes from the user.
- Keep calls to a handful. Hitting limits can block requests for 24 hours.

## Read-only verification example

```bash
# Confirm the key is set without printing it
[ -n "$MANYCHAT_API_KEY" ] && echo "MANYCHAT_API_KEY is set" || echo "MANYCHAT_API_KEY is not set"

# 1. Which account is this key for? (name, username, is_pro, timezone)
curl -s "https://api.manychat.com/fb/page/getInfo" \
  -H "Authorization: Bearer $MANYCHAT_API_KEY" \
  -H "Accept: application/json"

# 2. List existing automations (flows[].ns, name, folder_id) before building
curl -s "https://api.manychat.com/fb/page/getFlows" \
  -H "Authorization: Bearer $MANYCHAT_API_KEY" \
  -H "Accept: application/json"
```

A good response starts with `{"status":"success","data":...}`. Check that `data.name` or `data.username` matches <YOUR_IG_HANDLE> or the expected account, and that `data.is_pro` is true. After the user builds the automation, run `getFlows` again to look for the new name (not verified for Quick Automations).
