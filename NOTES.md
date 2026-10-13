# PlayPickleball — Implementation Notes

## Overview

Paddle Compare is a responsive Flutter application designed to help pickleball players discover paddles, explore their specifications, and compare products side by side.

The implementation focuses on three main areas:

- **Architecture:** Clear boundaries, testable business rules, and maintainable state management.
- **User experience:** A polished, responsive interface that makes comparing equipment intuitive.
- **Reliability:** Graceful handling of incomplete data, simulated network failures, deep links, and edge cases.

Beyond the core requirements, I added several refinements to make the application feel closer to a real consumer product:

- Light and dark themes inspired by PlayPickleball's visual identity.
- Hero image transitions between product screens.
- Full-screen paddle image viewing.
- Similar paddle recommendations.
- A customizable comparison section where users can pin up to five specifications that matter most to them.

The goal was not to build the largest possible application, but to demonstrate thoughtful technical and product decisions within the scope of the exercise.

---

## 1. Getting Started

### Requirements

- Flutter SDK (current stable version)
- Dart SDK bundled with Flutter
- Chrome for web development
- An available iOS Simulator, Android emulator/device, or supported desktop target

### Installation

```bash
flutter pub get
```

### Running the App

```bash
# Web
flutter run -d chrome

# iOS Simulator
flutter run -d ios

# Android
flutter run -d android

# macOS
flutter run -d macos
```

Available devices can be checked with:

```bash
flutter devices
```

Platform-specific targets require the corresponding Flutter tooling and device configuration.

### Code Generation

This project uses Riverpod code generation.

After changing annotated providers, regenerate the files with:

```bash
dart run build_runner build --delete-conflicting-outputs
```

---

## 2. Running Tests and Static Analysis

```bash
flutter test
flutter analyze
```

At the time of preparing these notes:

- The existing automated test suite passes.
- Static analysis reports informational lint messages only.
- Main catalog, detail, and comparison flows have been manually checked on Flutter web.

The tests focus primarily on state management, business rules, data parsing, comparison behavior, and predictable failure handling.

Visual regression testing and a more comprehensive accessibility audit would be valuable next steps.

---

## 3. Architecture — Domain / Data / View

The application follows a feature-first structure, with three primary layers under `lib/features/paddles/`.

### Domain

Contains the business rules and contracts:

- `Paddle`
- `PaddleWeight`
- `ComparisonSelection`
- Repository interfaces
- Filtering, comparison, and recommendation use cases

The domain layer is independent of Flutter, Riverpod, go_router, and data-source implementations.

### Data

Responsible for retrieving, parsing, and mapping external data:

- `PaddleMockDataSource`
- `PaddleModel`
- `PaddleMapper`
- `PaddleRepositoryImpl`

The data layer converts the external dataset into domain entities and isolates data-source concerns.

### View

Contains the Flutter presentation layer:

- Screens and feature-specific widgets
- Riverpod providers
- State controllers
- Responsive UI components

Business rules are kept outside widgets wherever practical.

### Shared Architecture

| Directory | Responsibility |
|---|---|
| `lib/app/` | Application bootstrap, routing, shared shell, and themes |
| `lib/common/` | Reusable UI components, layouts, buttons, cards, inputs, and feedback |
| `lib/core/` | Shared non-visual utilities, error types, formatters, and asset references |
| `lib/features/paddles/` | Paddle-specific domain, data, and view implementations |

The distinction between `common` and feature-specific widgets is intentional.

A reusable button belongs in `common`, while a `PaddleCard` remains inside the paddles feature because it understands paddle-specific information.

This keeps shared UI components independent of business models and makes the structure easier to extend with future features.

---

## 4. Why Use Cases?

I introduced use cases to keep meaningful business operations separate from presentation and state-management code.

The main examples are:

- Retrieving paddles.
- Filtering and sorting the catalog.
- Resolving and comparing selected paddles.
- Finding similar paddles.

This provides a few benefits:

- Business rules can be tested without Flutter widgets.
- Riverpod providers remain focused on coordinating dependencies and state.
- The same logic can be reused across multiple screens.
- Future changes can be implemented without duplicating rules in the UI.

**Trade-off:** Use cases introduce additional files and indirection.

For an application this size, the architecture could be simpler. I chose these boundaries because comparison and recommendation logic contain meaningful rules that benefit from independent testing.

I avoided introducing additional layers solely for architectural complexity.

---

## 5. Mock Data Source and API Simulation

`PaddleMockDataSource` loads the provided dataset from:

`assets/data/paddles.json`

Although the source is a local asset, the data layer treats it as a simulated remote API.

The implementation includes:

- Approximately 500ms of configurable latency.
- Simulated failures, approximately 12% by default.
- A typed `DataLoadFailure`.
- Loading, error, and retry states.
- Deterministic test configuration.

Tests can inject `Duration.zero` and a controlled `shouldFail` behavior.

This allows the application to demonstrate realistic asynchronous UI states without requiring a backend.

The repository contract isolates data retrieval from the rest of the application. A future HTTP implementation could replace the mock source without requiring changes to the domain entities or presentation architecture.

### Handling Imperfect Data

The provided JSON intentionally contains inconsistencies.

The parsing and mapping layers handle cases such as:

- Missing prices.
- Missing or unusable images.
- Optional fields that are absent.
- Different weight units.
- Unexpected or incomplete specification values.

Missing values are represented explicitly rather than silently converted to zero.

---

## 6. Riverpod State Management

Riverpod is responsible for dependency injection, asynchronous loading, presentation state, and derived data.

### Main Providers

| Provider | Responsibility |
|---|---|
| Repository and use-case providers | Dependency injection, using `keepAlive` |
| `paddlesProvider` | Session-cached asynchronous dataset loading |
| `CatalogController` | Mutable search, filter, and sorting state |
| `filteredPaddlesProvider` | Derived catalog results |
| `comparisonResultProvider(selection)` | Derived comparison data |
| `similarPaddlesProvider(id)` | Derived recommendations |

The underlying dataset is shared between the catalog, detail, and comparison experiences.

Filtering or sorting does not require fetching the dataset again.

### State Ownership

I separated state according to its purpose:

- **Remote-style data:** Managed through asynchronous Riverpod providers.
- **Catalog UI state:** Managed through the catalog controller.
- **Comparison selection:** Represented by the URL.
- **Highlight differences:** Kept local to the comparison screen.

This avoids unnecessary global state and reduces the risk of multiple sources of truth.

Riverpod's automatic retry behavior is disabled in this implementation so simulated failures remain visible and can be retried explicitly through the UI.

---

## 7. Routing and Shareable Comparison State

The application uses `go_router`.

Comparison selection is represented by the `ids` query parameter.

Example routes:

```text
/paddles?ids=a,b
/paddles/:id?ids=a,b
/compare?ids=a,b
```

### Why URL-Driven State?

Shareable comparisons and direct navigation are core requirements.

Rather than maintaining a separate global list of selected IDs that must be synchronized with navigation, the URL serves as the authoritative representation.

`ComparisonRouteCodec` handles parsing and serialization.

The domain-level `ComparisonSelection` enforces:

- Maximum of three paddles.
- Selection order.
- Duplicate prevention.
- Valid selection operations.

Selection changes use route replacement, while screen changes use normal navigation.

This keeps browser history meaningful and supports deep linking.

Screens derive the current selection from `GoRouterState` through `selectionFromContext`.

Riverpod then resolves those IDs into the appropriate domain data.

### Trade-off

URL-driven selection requires explicit parsing and navigation helpers.

However, it simplifies direct links, browser refreshes, and consistent selection behavior across screens without maintaining a second authoritative list.

---

## 8. Comparison Experience — Product and UX Decisions

The comparison screen received particular attention because it represents the central user journey.

### Amazon-Inspired Comparison Matrix

I used the familiar product-comparison pattern found in marketplaces such as Amazon:

- Products displayed in columns.
- Specifications aligned horizontally.
- Consistent values and units.
- Visually highlighted differences.
- Product images and essential information kept easy to identify.

The goal is to let users compare attributes directly rather than forcing them to remember information while switching between product pages.

### Responsive Behavior

**Desktop (900px and above)**

- Fixed specification-label column.
- Equally sized product columns.
- Constrained content width.
- Side-by-side comparison of two or three paddles.

**Mobile (including 375px)**

- Fixed specification-label column, approximately 104px.
- Horizontally scrollable product columns.
- Synchronized header and body scrolling.
- Snapping behavior.
- A visual hint when additional products are offscreen.

I preferred horizontal scrolling over compressing three complete product columns into a narrow phone screen.

This preserves readability and makes the comparison usable on smaller devices.

### Highlighting Differences

Users can highlight specifications that differ between selected paddles.

Values are normalized before comparison where appropriate.

Missing values are displayed as **Not available**, rather than treated as zero.

Differences are highlighted using subtle theme-aware colors.

I deliberately avoided labeling higher or lower performance values as universally better. Different paddles suit different playing styles and personal preferences.

### Customizable Comparison — Pinned Specifications

One additional feature I particularly enjoyed designing is the ability to **pin up to five specifications** in a dedicated comparison section.

The idea came from considering how players actually compare equipment.

A player might care mainly about weight, price, control, shape, and power. Another player might prioritize entirely different specifications.

Rather than forcing both users to repeatedly scan the entire table, the feature lets them concentrate on the attributes most relevant to their decision.

This provides a more personalized comparison experience without introducing complicated recommendation algorithms or additional backend requirements.

It is a relatively small feature, but one that I believe adds meaningful usability.

### Comparison Edge Cases

The implementation also accounts for:

- Attempting to add a fourth paddle.
- Unknown or unavailable paddle IDs.
- Duplicate selections.
- Missing specifications.
- Different weight units.
- Empty or incomplete comparison selections.

The current maximum remains three paddles, as requested in the assignment.

---

## 9. Specification and Unit Normalization

Paddle weights are normalized internally to ounces.

Conversion:

```text
ounces = grams / 28.3495
```

The UI generally displays ounces, with original gram measurements available as secondary information where appropriate.

Comparison equality uses display-oriented precision to avoid treating small formatting differences as meaningful specification differences.

Examples:

- Price: cents.
- Weight: 0.05 oz.
- Dimensions: 0.01 in.

Unknown values remain unknown.

This distinction matters because inaccurate normalization could mislead users when comparing equipment.

---

## 10. Similar Paddle Recommendations

I implemented a lightweight recommendation feature on the paddle detail screen.

`FindSimilarPaddlesUseCase` ranks products using deterministic rules based on available attributes.

The current scoring approach includes:

| Attribute | Maximum contribution |
|---|---:|
| Same shape | 4 |
| Price proximity (within approximately $80) | 2 |
| Weight proximity (within 1 oz) | 2 |
| Core thickness match | 1 |
| Each supported rating-proximity criterion | 1 |

The algorithm excludes the currently viewed paddle and returns up to six recommendations.

Ties are resolved by paddle ID to keep results deterministic.

I deliberately avoided displaying an artificial similarity percentage, since the heuristic is intended for product discovery rather than as a scientifically validated measure of paddle similarity.

### Carousel UX

Recommendations are displayed in a horizontally scrollable card carousel.

This reuses the same visual language as the catalog and supports navigation directly to another paddle's detail page.

The feature encourages discovery without requiring users to return to the catalog.

---

## 11. Visual Design and Animations

### Branding and Themes

The application includes light and dark themes inspired by PlayPickleball's purple-based visual identity.

The theme system uses centralized Material 3 color definitions and shared UI components.

The intention was to make the application feel connected to the PlayPickleball ecosystem without sacrificing readability or using excessive brand colors.

### Hero Transitions

Hero animations provide visual continuity when navigating from product cards to paddle details.

Implementation decisions include:

- Namespaced tags such as `catalog:{id}`, `similar:{id}`, and `compare:{id}`.
- Navigation metadata through `PaddleHeroExtra`.
- Normal rendering for direct links without a valid Hero source.
- No Hero wrappers on comparison-tray thumbnails.
- Respect for `MediaQuery.disableAnimations`.
- A shared navigator structure that supports compatible Hero transitions.

The namespacing prevents duplicate Hero-tag conflicts when the same paddle appears in multiple components.

### Full-Screen Product Images

The detail page also allows users to view paddle illustrations in full screen.

This gives users a closer look at the equipment without overloading the main detail layout.

These refinements are intentionally lightweight and complement the primary product experience rather than replacing it.

---

## 12. Important Technical Trade-offs

| Decision | Rationale / Trade-off |
|---|---|
| Domain / Data / View separation | More structure than strictly necessary, but clearer responsibilities and easier testing |
| Dedicated use cases | Additional files in exchange for testable business rules |
| URL-driven comparison state | More explicit routing logic, but no duplicated authoritative selection |
| Session-cached paddle loading | Avoids repeated simulated API requests while navigating |
| Riverpod 3 automatic retry disabled | Keeps mock failures visible and makes explicit UI retry behavior meaningful |
| Shared UI components | Improves consistency without mixing paddle-specific logic into generic widgets |
| Local highlight-differences state | Avoids global state for a screen-specific preference |
| Deterministic similar-paddle scoring | Simple, explainable recommendations without external services |
| Material 3 theme tokens | Consistent styling without introducing an external design-system dependency |
| In-memory repository overrides in widget tests | Predictable tests without depending on asset loading in every widget test |

I favored straightforward solutions over more elaborate infrastructure where the extra complexity would not provide clear value.

---

## 13. Testing and Validation

The test suite focuses on the application's most important logic and state-management behaviors.

Areas covered include:

- Repository and data-source behavior.
- Parsing and mapping.
- Selection limits and duplicate prevention.
- Filtering and sorting.
- Comparison logic.
- Weight normalization.
- Similar-paddle ranking.
- Riverpod behavior with controlled dependencies.

Widget tests use in-memory repository overrides to avoid unnecessary dependency on asset-backed loading.

### Validation Performed

- `flutter test` — existing tests passing.
- `flutter analyze` — informational lint messages only.
- Manual Flutter web checks for catalog, detail, and comparison workflows.

### Known Testing Limitation

I encountered issues involving `rootBundle` loading across sequential widget tests when the real asset-backed repository was used.

The current tests isolate that dependency through in-memory repository overrides.

This approach improves test predictability, but I would investigate the underlying test-binding behavior further before treating it as fully resolved.

---

## 14. AI-Assisted Development

AI tools were used throughout the exercise, as explicitly permitted by the assignment.

They assisted with:

- Initial scaffolding and boilerplate.
- Architecture exploration.
- Riverpod implementation patterns and code generation.
- UI implementation and refinement.
- Testing and debugging.

My focus was on defining the intended behavior, selecting architectural boundaries, reviewing the resulting implementation, and refining the user experience.

In particular, the following decisions were important to the final solution:

- Keeping comparison selection URL-driven.
- Preserving clear Domain/Data/View boundaries.
- Handling inconsistent dataset values.
- Choosing the mobile comparison interaction.
- Introducing customizable pinned specifications.
- Designing responsive layouts and theme behavior.
- Handling Hero transitions and navigation edge cases.

AI was useful for accelerating implementation and exploring unfamiliar API details, particularly with Riverpod.

I treated generated code as implementation assistance rather than as a substitute for understanding the application's behavior.

The final solution remains something I am responsible for explaining, maintaining, and extending.

---

## 15. What I Would Improve With Another Day

Given an additional development day, I would prioritize refinements to the existing experience rather than immediately expanding the feature set.

### Accessibility

- Review semantic labels across interactive components.
- Improve keyboard navigation and focus order.
- Validate screen-reader behavior in the comparison matrix.
- Check contrast and touch-target consistency.

### Visual and Responsive Refinements

- Improve catalog empty states and filter interactions.
- Refine sticky comparison controls.
- Validate more intermediate screen widths.
- Add golden tests for the comparison view at approximately 375px.

### Reliability and Testing

- Add additional widget and navigation tests.
- Improve test coverage for deep-link edge cases.
- Investigate the asset-loading test-binding issue.
- Review error recovery and retry behavior.

### Theme Preferences

Persist the selected theme mode across application restarts.

These changes would strengthen the existing product without introducing unnecessary scope.

---

## 16. If This Became a Production Product

For a real production application, I would consider several additional improvements beyond the take-home requirements.

These are **future architectural and product ideas**, not missing functionality in the current exercise.

### 16.1 Shared HTTP Client and Network Infrastructure

The current mock data source is intentionally self-contained.

If the application were connected to real backend services, I would introduce a shared, configured HTTP client using Dio.

I would place this infrastructure under something like:

```text
lib/core/network/
├── dio_provider.dart
├── api_client.dart
├── interceptors/
└── network_failure_mapper.dart
```

The goal would be to reuse an application-scoped Dio instance rather than creating separate HTTP clients throughout different data sources.

Centralized configuration would allow consistent handling of:

- Base URLs and environment configuration.
- Connection and response timeouts.
- Authentication headers.
- Request/response interceptors.
- Error normalization.
- Network diagnostics and structured logging.
- Controlled retries where appropriate.

Each feature would still own its own data sources and repository implementations.

The shared network layer would provide infrastructure, not contain feature-specific API logic.

**Reasoning:** This becomes especially valuable when an application grows to include multiple backend-driven features.

### 16.2 Internationalization and Localization

If PlayPickleball expanded into additional international markets, I would introduce Flutter localization resources.

A possible structure:

```text
lib/l10n/
├── app_en.arb
├── app_pt.arb
└── ...
```

This would allow the application to support multiple languages without hardcoded UI strings.

Beyond translation, localization should consider:

- Currency formatting.
- Measurement preferences.
- Number formatting.
- Regional terminology.
- Accessibility and text expansion.

For a paddle-comparison application, measurement preferences are particularly relevant because players may expect different units depending on their region.

### 16.3 E-Commerce and Shopping Cart

If the product eventually evolved into an equipment marketplace, a shopping cart could be introduced as an independent feature.

Conceptually:

```text
features/
├── paddles/
└── cart/
    ├── domain/
    ├── data/
    └── view/
```

Potential capabilities:

- Add/remove products.
- Manage quantities.
- Persist cart state.
- Review product totals.
- Integrate checkout and payment flows.

A real commerce implementation would also require backend-authoritative pricing, product availability, order validation, and secure payment processing.

I would not introduce these concerns into the current exercise because purchasing is outside its scope.

### 16.4 More Flexible Brand Assets

The current logo integration uses a background container to maintain contrast across light and dark themes.

For production, I would improve this by using theme-appropriate logo variants, ideally provided as official brand assets.

For example:

- Full-color logo for light surfaces.
- Light or monochrome logo for dark surfaces.
- SVG or appropriately optimized scalable assets.

This would produce a cleaner result than adapting the logo through an additional background container.

It would also improve consistency across navigation, loading screens, and other branded elements.

### 16.5 Repository and Branching Workflow

For this small take-home assignment, I worked directly on the `main` branch to keep the delivery workflow simple.

In a collaborative production environment, I would adopt a more structured Git workflow:

- Short-lived feature branches.
- Pull requests.
- Peer reviews.
- Automated analysis and tests.
- Branch protection for the main branch.
- Clear release and deployment practices.

I would prefer a lightweight workflow that supports collaboration without adding unnecessary process.

### 16.6 Richer Catalog Discovery

The current catalog presents all available paddles with search, filtering, and sorting.

For a larger production catalog, I would introduce additional discovery sections.

Potential examples:

- Featured paddles.
- Recently added products.
- Browse by shape.
- Browse by price range.
- Recommended alternatives.
- Popular products, if reliable popularity data becomes available.

These sections could help users discover equipment before knowing exactly what they want to search for.

I would ensure that labels such as "Popular" or "Best Sellers" are supported by actual product data rather than fabricated rankings.

### 16.7 Expanded Comparison on Large Screens

The current exercise explicitly limits comparison to three paddles.

I respected this requirement.

For a production product, I would explore whether allowing a fourth paddle on larger screens improves the user experience.

A four-product comparison could use desktop space more effectively for certain users, but it would also introduce trade-offs:

- Narrower product columns.
- More information density.
- Increased cognitive load.
- Additional responsive layout considerations.

I would treat this as a product decision requiring UX validation rather than automatically increasing the limit.

On smaller screens, the horizontally scrollable comparison model could continue supporting the experience.

The underlying selection rules would need to be adapted deliberately if product requirements changed.

---

## 17. Final Thoughts

My main objective was to deliver a small application that demonstrates both engineering discipline and attention to the end-user experience.

The architecture was designed to make future changes understandable and testable.

The UI was designed to make product information approachable rather than overwhelming.

And the additional features — particularly similar paddle discovery, Hero transitions, and customizable pinned specifications — reflect my interest in thinking beyond individual requirements and considering how people actually use a product.

I enjoyed working on the exercise and would be happy to discuss the technical decisions, limitations, and possible improvements during the follow-up session.