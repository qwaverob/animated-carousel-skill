# Carousel plan (demo)

Status: demo. Two slides only, to prove the templates and scripts work. A real carousel has 5 to 7.

- Audience: owners of small businesses who are starting to think about selling
- Topic or offer: what to prepare before talking to buyers
- Goal: saves and DMs
- Comment keyword: THIS
- DM link: <YOUR_LINK>
- Look: template tokens (ledger green ground, chalk text, lemon accent, League Gothic and Outfit)

| Slide | Role | On-screen text | Primary motion technique |
| --- | --- | --- | --- |
| 1 | Cover hook (full hook visible at frame 0) | The documents a buyer asks for before making an offer. Context: Have them ready and the first serious conversation goes a lot faster. | 0 Cover drift |
| 2 | Value point | Start with these three, every buyer asks for them: Tax returns (the last three years), Profit and loss (this year, to date), Your current lease (terms, rent and how long is left) | 5 Card stack shuffle (deal variant) |

## Caption

The documents a buyer asks for before making an offer.
Get these together early and you skip weeks of back and forth.
Comment THIS and I will DM you the full prep checklist.

## How this demo was made

```bash
bash scripts/new-carousel.sh examples/demo-carousel 2
# edited slides/slide-01/index.html (copy) and slides/slide-02/index.html (copy and stage)
bash scripts/grade-stills.sh examples/demo-carousel
bash scripts/render-slides.sh examples/demo-carousel
bash scripts/qa.sh examples/demo-carousel
bash scripts/contact-sheet.sh examples/demo-carousel
```

MP4s are not committed (they are in `.gitignore`). The stills, `qa/report.txt`, `qa/cover-frame0.png` and `qa/contact-sheet.png` are.

## Approvals

- [x] Plan approved (demo)
- [x] Grade stills reviewed
- [x] QA PASS
- [ ] Carousel approved (not applicable, demo only)
- [ ] Publish dry run approved (never, demo only)
