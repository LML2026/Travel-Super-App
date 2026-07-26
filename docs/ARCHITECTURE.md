# Architecture

This file is the architecture source of truth and fulfills the requested `docs/architecture.md` entry on case-insensitive file systems.

## System Overview
- Mobile app: Flutter
- State management: Riverpod
- Routing: GoRouter
- Backend: Node.js + Express
- Database: Firebase Firestore
- Auth: Firebase Auth
- File storage: Firebase Storage (planned for trip documents)
- Push: Firebase Cloud Messaging (planned)

## Mobile Layering
Current preferred feature structure:
- models
- services
- repositories
- providers
- screens
- widgets

Cross-cutting folders:
- lib/core/theme
- lib/core/widgets
- lib/core/api
- lib/core/utils

## Navigation Standard (Riverpod + GoRouter)
Navigation is standardized on Riverpod + GoRouter across the app.

Core files:
- `lib/app/app_routes.dart`: typed route enum and navigation helper extensions.
- `lib/app/providers.dart`: `appRouterProvider` as the single router provider.
- `lib/app/router.dart`: router composition root.
- `lib/app/route_groups/`: feature-level route registration modules.

Route groups currently split by feature area:
- `core_routes.dart`
- `auth_routes.dart`
- `flight_routes.dart`
- `hotel_routes.dart`
- `trip_routes.dart`

Implementation rules:
- Use `BuildContext` helpers from `app_routes.dart` for navigation intent (for example pushTripDetails, pushHotels).
- Prefer named GoRouter routes and typed `extra` payloads for detail pages.
- Validate route payload types in route builders and render a safe error page for invalid payloads.
- Do not introduce new `Navigator.push` or `MaterialPageRoute` usage in feature screens.

Deep link readiness:
- Every production screen should have a stable named route and path.
- New feature routes must be added through a route group and composed in `lib/app/router.dart`.

## Data Flow Pattern
1. Screen dispatches action to provider.
2. Provider calls repository.
3. Repository calls service/API or Firestore.
4. Service maps response to models.
5. Provider emits state for UI render.

## Backend Architecture
- Express routes under backend/server.js
- Layered source under backend/src: config, middleware, validators, routes, controllers, services, repositories, models, utils.
- External providers:
  - Duffel for flights
  - Open-Meteo for weather
  - Open Exchange rates source for currency
  - OpenAI-compatible endpoint for AI planner
- Route-level validation and centralized error fallback

## Firestore Data Model (current and near-term)
- users/{uid}/trips/{tripId}
  - destination
  - departureDate
  - returnDate
  - budget
  - currency
  - travellers
  - notes
  - createdAt
  - updatedAt
- users/{uid}/savedFlights/{flightId}
- users/{uid}/savedHotels/{hotelId}

Planned additions:
- users/{uid}/trips/{tripId}/itinerary/{itemId}
- users/{uid}/trips/{tripId}/documents/{docId}
- users/{uid}/wallet/{currencyCode}
- users/{uid}/expenses/{expenseId}

## Module Boundaries
- Flights: search, save, detail
- Hotels: search, save, detail
- Weather: city forecast retrieval and display
- Trips: orchestration layer combining travel entities
- AI: prompt assembly + backend orchestration

## Architecture Decisions
- Keep backend stateless; treat Firestore as source of truth.
- Favor additive schema evolution with backward compatibility.
- Keep UI components in core when reused by 2+ features.
- Isolate provider state per feature to reduce cross-feature coupling.

## Risks and Mitigations
- Risk: legacy duplicate modules (trip_planner and trips) causing drift.
  - Mitigation: deprecate old module and route all trip work to trips feature.
- Risk: thin API schema validation.
  - Mitigation: add request/response schema checks and contract tests.
- Risk: feature acceleration without quality gates.
  - Mitigation: enforce test and analyzer checks in CI.

## Non-Functional Targets
- App startup under 3 seconds on modern device
- Crash-free sessions > 99.5 percent
- P95 API latency < 1 second for internal endpoints
- Offline-tolerant read paths for key screens
