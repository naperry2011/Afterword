# Afterword — Build Spec v1

**Working name:** Afterword
**Platform:** iOS first (Flutter), Android deferred
**Submit:** September 14 · **Target live:** September 17
**Design direction:** lo-fi night — pixel art, warm lamp on a dark room

This file is the working document. The concept brief explains *why*; this explains *what to build*. If the two disagree, this one wins.

---

## 1. The one sentence

> A person adds the book they're reading, marks it finished, answers three questions in under ninety seconds, and texts a friend a card that makes that friend want to read it.

Everything below exists to protect that sentence. When something has to go, ask whether it's in that sentence.

---

## 2. Design system

The app and the landing page share one visual language. If a screen can't be built from these tokens, the screen is wrong.

### 2.1 Colour

Dark room, single warm light source. Never pure black, never pure white.

| Token | Hex | Use |
|---|---|---|
| `bg` | `#241F33` | App background, the room |
| `surface` | `#2C2640` | Cards, sheets, raised things |
| `surfaceAlt` | `#3A3352` | Dividers, dashed rules, inactive |
| `outline` | `#141120` | Every border. 3px. Non-negotiable |
| `cream` | `#EDE3CE` | Primary text, share card background |
| `dim` | `#9C92B8` | Secondary text, captions, metadata |
| `amber` | `#D9A45E` | The lamp. Primary accent, warmth, highlights |
| `plum` | `#9179A6` | Primary buttons |
| `rose` | `#C4837A` | Prompt labels, accents |
| `sage` | `#6D8B71` | Success, finished state |
| `teal` | `#5E8785` | Accents, spine variety |

**Spine palette** (book covers on the shelf) cycles: rose, sage, amber, plum, cream, teal. Assign deterministically from the book id so a book always gets the same spine.

### 2.2 Type

- **Display / labels:** Pixelify Sans — headings, buttons, tags, counts. Rounded pixel, not crisp. Never for body copy.
- **Body:** Nunito — everything you actually read. Warm humanist, generous line height (1.6–1.72).
- Bundle both in the app. No system font fallbacks in the UI.

### 2.3 Shape and depth

- **Zero border radius.** Everywhere. This is the rule that holds the whole thing together.
- **3px outline** in `outline` on every raised element.
- **Offset shadow**, not blur: `5px 5px 0 rgba(0,0,0,.45)`. Buttons shift `3px,3px` on press and the shadow shrinks to `2px`.
- **Dashed dividers** in `surfaceAlt`, 2px, for anything that separates rather than contains.
- **Dither** for texture and empty states: 45° checkerboard, 8px cell. Never gradients for texture.

### 2.4 Motion

- Everything uses **stepped** timing (`steps(n)`), never smooth easing. Smooth motion on pixel art immediately breaks it.
- Slow. Rain 2.6s, steam 3.2s, lamp breathing 5.5s.
- All ambient motion respects reduced-motion and stops completely.
- Transitions between screens: none fancy. A cut or a fast fade.

### 2.5 What NOT to build in the app

The landing page has grain overlay, radial lamp bleed, vignette, and animated rain. **These are web-only.** In Flutter, use flat fills in the same colours and skip the atmospheric layers. Attempting them on device costs days and risks jank. The page may look richer than the app; that's acceptable. The app looking *cheaper in a different palette* is not.

---

## 3. Scope

### In v1
- Add a book via Open Library search
- Manual entry fallback (search failure must never be a dead end)
- Status: reading, finished, abandoned
- Lightweight progress logging
- **Reflection prompts on finishing** — the core of the product
- Reflection on abandoning too
- **Shelf view** — spines, in-progress and next as dithered empty slots
- Shareable recommendation card, rendered to image
- Local-only storage, no account, no server
- Onboarding, three screens maximum
- Manual JSON export/import in Settings

### Cut from v1
Quote and passage capture · Year in review · ISBN scanning · Social and discussion · Recommendation engine · Challenges and numeric goals · Film, TV, music · Accounts, sync, cloud backup · Android release

### ⚠ Scope debt to settle before Sept 3
The **shelf view was added by the design direction** and was not in the locked scope. It's roughly a day of Flutter work. It's also the App Store screenshot and the retention story, so it should stay. Pay for it by cutting **progress logging** down to a single "how far in are you" slider rather than a log with history, or drop progress entirely. Decide this on Sept 1, not Sept 9.

### Not in the app, on the site only
Apple rejects apps advertising unreleased features in the UI. Everything in the "What's coming" list lives on the landing page behind the email signup. **No coming-soon labels, no greyed tabs, no placeholder screens in the binary.**

---

## 4. Screens

Four surfaces. Every extra tab is a screenshot to design, a state to test, and a decision the user makes before getting value.

```
Shelf          The home screen. Spines, then empty slots.
  └ Book       Cover, status, progress, past reflections
      └ Reflect     The finishing flow. Prompted, sequential, skippable
          └ Card    Rendered image → system share sheet
Add            Open Library search + manual fallback
Settings       Export, import, about, privacy
```

### 4.1 Shelf (home)
Horizontal row of spines on a dark ground with the amber lamp warmth at one edge. Spine height and width vary deterministically by book. Finished books are solid; the book in progress is outlined and partially filled to its progress; the next slot is dithered and empty. A count line beneath in Pixelify: `NINE FINISHED · ONE IN PROGRESS · ONE WAITING`.

**The empty slot is the most important pixel on the screen.** It's the pull. Never hide it, never fill it with a CTA.

### 4.2 Reflect — the flow that decides whether this app deserves to exist
- Triggered automatically on marking finished or abandoned. **Not a button the user has to find.**
- One prompt per screen, sequential, large type, cream on dark.
- Every prompt has a one-line example underneath in `dim` so the field is never a blank page.
- **Skip is always visible and never discouraged.** No guilt copy.
- Prompts stored by **key**, not by index or by wording, so copy can change in an update without touching stored answers.

Prompts:
1. `stayed` — **What stayed with you?** · *Not a summary. The image or line still sitting there a day later.*
2. `who` — **Who should read this, and why them?** · *Naming one person turns a review into a recommendation.*
3. `changed` — **What did it change?** *(optional, visually lighter)* · *Often the honest answer is nothing.*

Abandon variant swaps prompt 1 for `stopped` — **Where did you stop, and why?**

### 4.3 Card
Renders the answer to `who` over the cover and title. Fixed output dimensions independent of device. Cream card, 3px outline, amber offset shadow, Pixelify sig line. Straight to the system share sheet.

---

## 5. Data model

Model reflection as a first-class record on a **reading session**, not as columns on the book. Someone can read a book twice and think something different the second time.

| Entity | Fields | Why separate |
|---|---|---|
| `Book` | id, title, author, coverRef, openLibraryKey, year, source | Immutable reference data, cacheable |
| `ReadingSession` | id, bookId, status, started, ended, progress, abandonReason | One book, many sessions |
| `Reflection` | id, sessionId, promptKey, response, created | One row per prompt. New prompts = data, not migration |
| `Card` | sessionId, theme, reflectionIds, generatedAt | Sharing is a view over reflections, never a copy |

Rules:
- Embedded DB with a **versioned migration path from the first commit**. Not shared prefs, not loose JSON.
- Covers cached to disk with a **designed typographic fallback**. It'll be used more than expected and cannot look broken.
- Everything except search works offline. Search fails with a message and a manual-entry button, never an infinite spinner.
- Spine colour derived from book id, so it's stable forever.

---

## 6. Schedule

| Date | Milestone | Done means |
|---|---|---|
| **Aug 30** | Apple enrollment started | Payment submitted. Blocks Sept 13. Nothing else matters if this slips |
| **Sept 1** | Scope locked + shelf debt settled | Feature list closed. Progress-logging decision made in writing |
| **Sept 3** | Screens, nav, data model, **design tokens** | Four surfaces navigable with dummy data. Tokens file committed. Fonts bundled. Migration-capable schema |
| **Sept 6** | Core working on iPhone | Add book, set status, shelf renders real spines. On a real device. Android sim still building clean |
| **Sept 8** | Storage stable + **assets started** | Persistence across cold starts and upgrades. Export/import works. Reflect flow complete end to end. Icon direction chosen |
| **Sept 10** | Polish pass | No placeholders, no default icon, no broken empty states. **Every empty state designed** — a new user sees nothing else |
| **Sept 11** | QA, blockers closed | Real device, airplane mode, small screen, largest dynamic type, fresh install, upgrade over previous build |
| **Sept 12** | Store metadata ready | Icon, screenshots, privacy URL live, support URL live, description, keywords, App Privacy questionnaire |
| **Sept 13** | Signed release build | Archived, uploaded, processed. Installed via TestFlight on a device that never had a debug build |
| **Sept 14** | Submit | Submitted for review |
| **Sept 15–16** | Review response | Rejections answered same day. Blocking fixes only. No opportunistic changes |
| **Sept 17** | Approved | Live, or approved and held |

### Store assets — start Sept 8, not Sept 12
Roughly two days of work that never gets budgeted, and it doesn't depend on QA passing. Run it in parallel.

- **Icon:** the lamp, or a single spine, on `bg`. Must read at 60px. Pixel art at icon scale needs deliberate pixel sizing — don't downscale the nook.
- **Screenshot 1:** the shelf. Non-negotiable, it's the whole pitch in one image.
- **Screenshot 2:** the reflect flow mid-answer.
- **Screenshot 3:** the share card.
- **Privacy policy + support pages must be live and loading.** Apple checks.

### Android
Deferred. Before rescheduling, confirm the Play Console account type: personal accounts created after **13 Nov 2023** need 12+ testers opted in continuously for 14 days before production access, per app. Start closed testing on the **first installable build**, not the finished one — the clock runs on a testable build and can overlap polish. Recruit 15 to absorb drop-outs.

---

## 7. Risks and the cut order

| Risk | Response |
|---|---|
| **Reflection feels like a chore** | Test on three real people before Sept 10 with a book they actually finished. If they skip all three, the prompts are wrong, not the users. Rewrite rather than ship |
| **Apple enrollment late** | Unrecoverable. Started Aug 30, checked daily |
| **Scope creep** | One in, one out. Any addition needs a written cut of equal size same day |
| **Open Library gaps or downtime** | Manual entry is in scope for exactly this reason |
| **Pixel art eats the schedule** | Timebox it. Shelf spines are procedural, not hand-drawn. The nook scene is a **web asset only** — do not port it into the app |
| **Store assets underestimated** | Started Sept 8 in parallel |
| **Rejection for unreleased-feature promotion** | Verified during the Sept 10 pass, not after submitting |

### Cut order, decided now
If Sept 10 arrives and it isn't polish-ready, cut in this order without reopening the debate:

1. Auth / remote storage (should already be gone)
2. Progress logging → single slider, or nothing
3. Card theming → one well-made theme
4. Abandon status → keep reading and finished
5. Manual entry → only if Open Library coverage tested well

**Never cut:** the reflection prompts, the share card, the shelf. Those three are the product.

---

## 8. Standing rules

- Reflection is the **path of least resistance**, never a secondary action.
- Skip is always available and never guilted.
- Zero border radius. 3px outlines. Offset shadows.
- Stepped motion or no motion.
- No blank text fields — every prompt carries an example.
- No feature in the binary that isn't shipped.
- Nothing leaves the device.

---

## 9. Decisions since v1 (2026-09-08)

- Scope debt from §3 settled: **progress logging is a single "how far in are you" slider** per session, no history. The shelf view stays.
- Bundle id `com.nickperry.afterword`. Apple enrollment active.
- Package choices and other build-level decisions are in `docs/decisions.md`.
