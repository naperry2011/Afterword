# Afterword

A private, reflection-first reading journal with shareable recommendation cards. iOS first, built in Flutter. No account, no server, nothing leaves the device unless you send it.

Add the book you're reading, mark it finished, answer three questions in under ninety seconds, and text a friend a card that makes them want to read it.

## Run

```bash
flutter pub get
flutter run -d "iPhone 17 Pro"
```

## Develop

- `CLAUDE.md` has the stack, commands, layout, and the standing design rules.
- `docs/afterword-build-spec.md` is the working spec.
- `docs/decisions.md` is the decision log.
- After changing `lib/data/database.dart`, run `dart run build_runner build --delete-conflicting-outputs` and commit the generated file.

## Type and data credits

Pixelify Sans and Nunito, bundled under the SIL Open Font License (see `assets/fonts/`). Book metadata and covers from [Open Library](https://openlibrary.org).
