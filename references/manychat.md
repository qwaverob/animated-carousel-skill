# ManyChat: comment keyword to DM, by hand

Checked: 2026-10-28

When someone comments the keyword on the post, ManyChat sends them the link by DM. The user sets this up in the ManyChat app on the free plan. There are no API calls and no keys.

Why not the API: ManyChat's API needs the Pro plan, and it cannot create automations, triggers or comment keyword rules anyway. So skip it. If ManyChat shows "upgrade for API", the user does not need it.

## How to guide the user

- Walk through the steps below one at a time. Give one step, wait until the user says it is done (or asks a question), then give the next.
- Use plain words and the exact button names below. Never ask for a key, a password or a login code.
- The user does the clicks. You never log in, post or change anything for them.

## The steps (free plan)

1. **Sign up free.** Go to manychat.com and click Get started.
2. **Connect Instagram.** Follow ManyChat's steps and log in with the Instagram professional account (Business or Creator). A personal account will not connect.
3. **Start from the template.** Automation > New Automation > the template "Auto-DM links from comments". It is also on the Home page under Start here.
4. **Set the keyword.** Pick the post, then type the word people will comment, for example GUIDE or CHECKLIST. It must match the keyword on the last slide and in the caption exactly.
5. **Write the opening DM.** The first message they get. Short and friendly.
6. **Optional: ask for a follow first.** A short DM asking them to follow before they get the link. Recommend a follow only, no email: less friction, more people finish.
7. **Add the link.** Usually a Google Drive file (the guide or checklist). Its sharing must be "Anyone with the link can view", or people cannot open it.
8. **Add a follow-up DM** for people who do not click. An open question works well, for example "Did you see it?"
9. **Go Live.** Top right.

Name the automation so it is easy to find later, for example "Carousel GUIDE 2026-01-15".

## Free plan notes

- **"Any post or reel" needs Pro.** So the order is: the user posts first (scheduled in Buffer, see `buffer.md`), then right after it goes live, sets the automation on that specific post. The ManyChat phone app works well for this.
- **Only a couple of comment automations** are allowed on the free plan. Pro is about $29 a month (tell the user to check current pricing on manychat.com).
- **One ManyChat account per Instagram account.** To work on another Instagram account, switch from the account dropdown.
- **Test it from another account.** The user comments the keyword from a friend's or a second account, not their own, and checks that the DM arrives.
- Instagram only triggers on a person's first comment under a post. The same person commenting again will not get a second DM.

## Rules

- Never edit, rename, stop or delete an existing automation. If one already uses the same keyword, ask the user to pick a new keyword or turn the old one off themselves.
- Never ask for or use a ManyChat API key.
- Never invent the link. Use the link the user gives you.

## Google Drive (optional)

If the user's AI tool has a Google Drive connector, you can make the giveaway guide or checklist as a Google Doc for them. Remind them to set sharing to "Anyone with the link can view" (Share > General access > Anyone with the link, as Viewer). They can also make the doc themselves.

## Source

- ManyChat Help, "Quick Automation: Auto-DM links from comments": https://help.manychat.com/hc/en-us/articles/16654065283100-Quick-Automation-Auto-DM-links-from-comments
- ManyChat Help, "Instagram Post and Reel Comments trigger": https://help.manychat.com/hc/en-us/articles/14281316989724-Instagram-Post-and-Reel-Comments-trigger
