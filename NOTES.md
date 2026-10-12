# PlayPickleball — Implementation Notes

## 1. How to run (Flutter web and mobile)

```bash
flutter pub get

# Web
flutter run -d chrome

# iOS Simulator / macOS / Android
flutter run -d ios
flutter run -d macos
flutter run -d android
```

Dependencies use Riverpod code generation. After changing annotated providers:

```bash
dart run build_runner build
```

## 2. How to run tests

```bash
flutter test
flutter analyze
```

## 3. Domain / Data / View architecture

Feature-first layout under `lib/features/paddles/` with three layers:

- **Domain** — `Paddle`, `PaddleWeight`, `ComparisonSelection`, repository contract, use cases. No Flutter, Riverpod, or go_router.
- **Data** — `PaddleMockDataSource`, JSON `PaddleModel`, `PaddleMapper`, `PaddleRepositoryImpl`.
- **View** — Riverpod providers/controllers, screens, paddle-specific widgets.

Cross-cutting folders:

- `lib/app/` — bootstrap, theme, router, shell.
- `lib/common/` — reusable UI (buttons, cards, inputs, feedback, layouts). Does not import paddle domain or providers.
- `lib/core/` — non-visual helpers (`DataLoadFailure`, formatters, asset paths).

## 4. Why use cases were introduced

Use cases keep filtering, comparison assembly, and similarity ranking out of widgets and Riverpod notifiers. That makes the rules easy to unit-test and to reuse from catalog, detail, and compare without duplicating business logic.

## 5. Mock data source as an API

`PaddleMockDataSource` loads `assets/data/paddles.json` through `rootBundle`, waits ~500ms (configurable), and can throw `DataLoadFailure` (~12% by default). Tests inject `Duration.zero` and `shouldFail` so behavior is deterministic. Swapping to HTTP later only requires a new data source behind `PaddleRepository`.

## 6. Riverpod provider structure

- DI: repository and use-case providers (`keepAlive`).
- `paddlesProvider` — session-cached async load (`keepAlive`, automatic retry disabled so the UI retry button stays meaningful).
- `CatalogController` — mutable search/filter/sort only.
- `filteredPaddlesProvider` — derived list.
- `comparisonResultProvider(selection)` — derived from URL-parsed `ComparisonSelection`.
- `similarPaddlesProvider(id)` — derived recommendations.

Highlight-differences is local screen state, not a global provider.

## 7. go_router and URL-driven comparison

Canonical selection lives in the `ids` query parameter:

- `/paddles?ids=a,b`
- `/paddles/:id?ids=a,b`
- `/compare?ids=a,b`

`ComparisonRouteCodec` parses/serializes IDs. Domain `ComparisonSelection` enforces max 3, order, and dedupe. Selection edits use `replace` on the current path; screen changes use `go` so browser history works. Screens read selection with `selectionFromContext` from `GoRouterState` — there is no second authoritative ID list in Riverpod.

## 8. Responsive comparison

- **Desktop (≥900px):** label column + equal product columns, constrained content width.
- **Mobile (including 375px):** fixed label column (~104px), horizontally snapped product columns, synced header/body scroll controllers, swipe hint when more paddles are off-screen.

## 9. Specification and unit normalization

- Weight canonical unit is ounces (`g / 28.3495`). Display prefers oz; original grams may appear as a secondary label.
- Missing values render as **Not available** — never coerced to zero.
- Comparison equality uses display-oriented precision (price cents, weight 0.05 oz, dimensions 0.01 in, etc.).

## 10. Similar paddles

`FindSimilarPaddlesUseCase` scores candidates deterministically:

- Same shape: 4
- Price proximity (within ~$80): up to 2
- Weight proximity (within 1 oz): up to 2
- Core thickness match: 1
- Rating proximity: up to 1 each

Excludes the selected paddle, returns up to 6, tie-breaks by id. No similarity percentage is shown.

## 11. Hero animation decisions

- Tags are namespaced: `catalog:{id}`, `similar:{id}`, `compare:{id}` to avoid duplicate-tag crashes when the same paddle appears in multiple places.
- Detail adopts a Hero only when navigation `extra` carries `PaddleHeroExtra`.
- Direct links / refresh render without a Hero.
- Comparison tray thumbnails never use Hero.
- `MediaQuery.disableAnimations` skips Hero wrappers.
- ShellRoute keeps catalog/detail/compare under one navigator so Hero flights can work.

## 12. Important trade-offs

- **URL as source of truth** for selection adds codec/navigation helpers but avoids state drift.
- **Use cases** add a few files; they pay for clearer pair-programming boundaries.
- **Riverpod 3 auto-retry** is disabled globally so intentional mock failures remain visible and recoverable via UI.
- **Widget tests** override the repository with in-memory fakes; asset-backed loading is covered in data tests (sequential widget tests that reload assets can hang under the test binding).
- Theme tokens are hand-rolled Material 3 schemes; no external design-system package was provided in the starter.

## 13. AI tools used and validation

AI assisted scaffolding, layering, and boilerplate. Human review focused on:

- Dataset edge cases (null price/image, gram weights, missing keys).
- URL selection semantics and fourth-paddle messaging.
- Mobile comparison scroll behavior.
- Hero tag namespacing.
- Test reliability with Riverpod 3 retry and asset loading.

Validation performed: `flutter analyze` (info-only lints), `flutter test` (all passing), and manual Flutter web checks for catalog/detail/compare flows.

## 14. What would improve with another day

- Persist theme mode.
- Stronger catalog empty/filter chrome and sticky compare bar polish.
- Accessibility pass (semantics labels, focus order).
- Golden tests for comparison at 375px.
- Real HTTP data source behind the same repository contract.
- Investigate/isolate rootBundle hangs across sequential widget tests when not overriding the repository.

## Incomplete / out of scope (P3)

- Extra animation systems beyond Hero.
- Similarity score explanations in the UI.
- Advanced theme customization beyond light/dark tokens.
