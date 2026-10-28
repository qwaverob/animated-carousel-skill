# Daily routine mode

For users who want one carousel a day without repeating themselves.

## Each day

1. **Read the log.** Open `posts-log.md` in the user's working folder (create it from the format below if it does not exist). Note the last 14 entries: hooks, topics, formats, keywords.
2. **Offer 5 fresh ideas.** Each with hook, angle, format, and slide count. Rules:
   - No hook or topic that is already in the log (reword is not enough; it must be a different point).
   - Not the same format as yesterday.
   - At least 3 different formats across the 5 ideas.
   - Rotate the goal (saves, shares, follows, DMs) across the week if the user has no preference.
3. **User picks one.** Edits loop until they approve. Write `plan.md`.
4. **Build.** Follow SKILL.md Steps 4 to 7: cover rule, motion plan, build, quality pass, grade stills, render, `QA PASS`, carousel approval.
5. **Publish only after an explicit yes.** Dry run, account check, ManyChat (new automation, unique name), Buffer. See `safety-checklist.md`.
6. **Log it.** Append the entry to `posts-log.md`, with status `drafted`, `scheduled` or `posted`, and update it if the status changes.

Each day's post needs its own yes. A yes yesterday is not a yes today.

Do not create cron jobs, scheduled tasks, or background automations to run this routine unless the user asks for one separately and approves a dry run of exactly what it will do. The default is that the user starts each day's session.

## posts-log.md format

```markdown
# Posts log

| Date | Hook | Topic | Format | Slides | Techniques | Keyword | Status | Link |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| 2026-01-14 | 5 documents a buyer asks for first | Sale prep | Checklist | 6 | 0,1,5,6,4,11 | THIS | scheduled 2026-01-15 09:00 | <post link when live> |
```

- One row per carousel, newest at the bottom.
- `Techniques` lists the primary technique numbers from `motion-menu.md`, so the next day can vary them.
- `Status` is one of: `planned`, `drafted`, `scheduled <date time>`, `posted`, `cancelled`.
- Never store API keys, private customer data, or DM contents in the log.

## Idea sources that stay fresh

- Questions the user's clients ask most.
- Mistakes the user sees often in their field.
- A myth in their industry and the fact behind it.
- A short process the user runs every week, as a checklist.
- A before and after from the user's real work (only with their real details and permission).

Ask the user for raw material (a voice note transcript, a list of client questions) once a week; it makes the 5 ideas far better than generic topics.
