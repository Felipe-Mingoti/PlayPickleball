# PlayPickleball

Discover, explore, and compare pickleball paddles. Built with Flutter, Riverpod (code generation), and go_router.

## Run

```bash
flutter pub get
flutter run -d chrome   # web
flutter run -d macos    # desktop
flutter run             # connected device / simulator
```

After editing `@riverpod` annotations:

```bash
dart run build_runner build
```

## Test

```bash
flutter test
flutter analyze
```

## Architecture

See [NOTES.md](NOTES.md) for Domain → Data → View decisions, URL-driven comparison selection, similarity scoring, Hero strategy, and trade-offs.
