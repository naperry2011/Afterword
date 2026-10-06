# Google Play listing

Copy for the Play Console store listing. Drafted 2026-10-05 against the app as tested on the Android emulator; every claim matches current behaviour. Limits and rules: [store listing help](https://support.google.com/googleplay/android-developer/answer/9859152), [metadata policy](https://support.google.com/googleplay/android-developer/answer/9898842). No ranking claims, promotions, Play program references, testimonials, emoji, or all caps.

## App name (26/30)

```
Afterword: Reading Journal
```

The launcher label stays plain "Afterword".

## Short description (74/80)

```
Finish a book. Answer three questions. Send a friend a card that sells it.
```

Alternative (79/80): `Finish a book, answer three questions, and send a friend a card about it.`

## Full description (1,407/4,000)

```
Afterword is a reading journal for the moment you close a book.

Add the book you're reading. When you finish it, Afterword asks three short questions:

• What stayed with you?
• Who should read this, and why them?
• What did it change? (optional)

Every question comes with an example, so you never face a blank page, and every one can be skipped. All three take under two minutes.

Your answer to the second question becomes a recommendation card: the cover, the title, and your words, ready to send. Share it with a friend through any app on your phone and give them a reason to pick it up.

Your shelf
Every book you finish becomes a spine on your shelf. The one you're reading fills up as you go, and an empty slot waits for whatever comes next.

Put it down, too
Not every book is for you. Mark one as put down and Afterword asks where you stopped and why, so you remember next time.

Private by design
• No account, no sign-in, no ads, no analytics.
• Your shelf and everything you write stay on your phone.
• Afterword only goes online to search Open Library for books and load their covers.
• Nothing else leaves your phone unless you send it.
• Export everything to a file whenever you like, and import it on a new phone.

Find your book
Search Open Library, the free, non-profit book catalogue. If a book isn't there, add it by hand in a few seconds.

Pixel art, warm colours, and a lamp left on.
```

## Other fields

| Field | Value |
|---|---|
| Category | Books & Reference |
| Privacy policy URL | `https://naperry2011.github.io/Afterword/privacy.html` (live, checked 2026-10-05) |
| Support URL | `https://naperry2011.github.io/Afterword/support.html` (live, checked 2026-10-05) |
| Contact email | To fill in |

## Assets

| Asset | File | Spec |
|---|---|---|
| App icon | `play-icon-512.png` | 512x512, 32-bit PNG |
| Feature graphic | `play-feature-graphic.png` | 1024x500, 24-bit PNG |
| Phone screenshots | `screenshots-android/1-shelf.png` to `5-onboarding.png`, in that order | 1080x1920, 24-bit PNG |

## Keep in sync

If the app's prompts, privacy behaviour, or features change, update this file and `docs/site/privacy.html` together. The Settings privacy text in `lib/screens/settings_screen.dart` says the same thing in one sentence.
