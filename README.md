# PlayPickleball

Discover, explore, and compare pickleball paddles. Built with Flutter, Riverpod (code generation), and go_router.

<img width="357" height="734" alt="image" src="https://github.com/user-attachments/assets/472a2cc4-39f0-4e19-ae34-babc194c7436" />
<img width="363" height="735" alt="image" src="https://github.com/user-attachments/assets/ff6e67ca-186f-4712-a50d-85905aad599a" />


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
