# Architecture and Foundation

## Project Structure

Flutter source is scoped under `lib/`, so the requested structure maps as:

```text
lib/
  app/
    app.dart
    router.dart
  core/
    api/
    config/
    constants/
    errors/
    extensions/
    services/
    storage/
    theme/
    utils/
    widgets/
  features/
    auth/
    home/
    flights/
    hotels/
    weather/
    trips/
    wallet/
    translator/
    payments/
    ai/
    profile/
    settings/
  shared/
```

The entrypoint remains `lib/main.dart` and should only bootstrap the app.

## Feature Structure Standard

Every feature follows this target layout:

```text
<feature>/
  data/
    models/
    repositories/
    services/
  domain/
    entities/
    repositories/
    usecases/
  presentation/
    providers/
    screens/
    widgets/
  routes.dart
```

This separation keeps UI, business logic, and data integration loosely coupled and easier to test.

## Backend Structure Standard

```text
backend/
  src/
    config/
    middleware/
    models/
    routes/
    controllers/
    services/
    repositories/
    utils/
    app.js
  server.js
  package.json
  .env
```

`backend/src/app.js` now exists as the future composition root; `backend/server.js` can be slimmed to startup wiring in a follow-up refactor.

## API Design Baseline

| Method | Endpoint | Purpose |
|---|---|---|
| GET | /api/flights/search | Search flights |
| GET | /api/hotels/search | Search hotels |
| GET | /api/weather | Weather forecast |
| GET | /api/trips | List trips |
| POST | /api/trips | Create a trip |
| PUT | /api/trips/:id | Update a trip |
| DELETE | /api/trips/:id | Delete a trip |

## State Management Baseline

Use Riverpod across all features. Each feature should expose providers that:

- Manage loading states
- Manage success and error states
- Expose immutable state to UI
- Keep business logic out of screens

## Design System Baseline

Use shared components in `lib/core/widgets/` first:

- PrimaryButton
- SecondaryButton
- AppCard
- SearchField
- LoadingIndicator
- ErrorView
- EmptyState
- RatingBadge
- PriceTag

## Testing Strategy Baseline

- Unit tests: models, repositories, usecases
- Widget tests: reusable components and screens
- Integration tests: end-to-end journeys (for example trip creation and lifecycle)

## Product Roadmap Baseline

| Version | Milestone |
|---|---|
| 1.0 | Authentication, Flights, Hotels, Weather |
| 1.1 | Trips |
| 1.2 | Saved Items and Itinerary |
| 1.3 | Maps and Attractions |
| 1.4 | Wallet |
| 1.5 | Translator |
| 2.0 | AI Travel Assistant |
| 2.1 | Booking and Payments |
| 3.0 | Public Release |

## Adoption Rule

New code should be added under the standard layout. Existing feature files can be migrated incrementally to avoid risky large rewrites.

## Structure Check Command

Run this from repository root to validate required architecture paths:

```bash
node tools/check-architecture.mjs
```
