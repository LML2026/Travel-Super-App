# Engineering Workflow

## Goal
Run this project as a production software program with explicit delivery standards, not isolated demo work.

## Feature Lifecycle (Required)
Every feature follows the same lifecycle:
1. Requirements: define what the feature must do.
2. Architecture: design domain, data, and presentation layers.
3. Implementation: build incrementally.
4. Testing: verify business logic and UI.
5. Integration: connect with the rest of the platform.
6. Documentation: update architecture and developer notes.

No feature work should bypass this lifecycle.

## Git Branching Model

```
main
|
|-- develop
|
|-- feature/authentication
|-- feature/profile
|-- feature/currency
|-- feature/wallet
|-- feature/trips
|-- feature/bookings
|-- feature/ai
`-- feature/documents
```

## Pull Request Requirements
Every feature branch must satisfy all gates before merge into develop:
1. Build successfully.
2. Pass flutter analyze.
3. Pass all tests.
4. Be reviewed before merge.

## CI Requirements
A CI pipeline runs on every pull request with these required checks:
1. flutter pub get
2. dart format --set-exit-if-changed .
3. flutter analyze
4. flutter test

Planned CI expansion:
- Integration tests
- Code coverage reporting
- Android and iOS release builds
- Firebase App Distribution deployment

## Definition of Done
A feature is complete only when it includes:
- Clean Architecture implementation
- Unit tests for business logic
- Widget tests for critical UI
- Localised text (no hard-coded UI strings)
- Material 3 compliance
- Accessibility support
- Responsive layouts
- Error handling
- Offline behaviour where applicable
- Documentation updates

## Architecture Rule for Integrations
External providers must be replaceable through interfaces and adapters.

Examples:
- Maps provider
- Exchange-rate provider
- Payment provider
- AI provider

No feature should directly depend on vendor SDK specifics outside its data/infrastructure adapter layer.
