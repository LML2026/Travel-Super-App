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

## Product Platform Modules
The app is one platform composed of modules, not independent mini-apps.

Platform layout:
- Core Platform
- Identity
- Finance
  - Currency
  - Wallet
  - Exchange
  - Budget
  - Expenses
- Travel
  - Trips
  - Documents
  - Maps
  - Translator
  - Checklists
- Marketplace
- AI

Release 1.0 architecture priority:
- Identity and profile persistence first
- Finance foundation second
- Travel companion breadth third

## Mobile Layering
Current preferred feature structure:
- models
- services
- repositories
- providers
- screens
- widgets

Cross-cutting folders:
- lib/core/analytics
- lib/core/authentication
- lib/core/configuration
- lib/core/constants
- lib/core/design_system
- lib/core/error
- lib/core/localization
- lib/core/logging
- lib/core/navigation
- lib/core/networking
- lib/core/notifications
- lib/core/offline
- lib/core/security
- lib/core/storage
- lib/core/theme
- lib/core/utilities
- lib/core/widgets

Feature modules are expected to expose production surfaces through the same layered contract:
- domain/entities
- domain/repositories
- data/repositories
- presentation/providers
- presentation/screens
- routes.dart

## Core Platform Bootstrap
The app entrypoint now resolves configuration before rendering the UI.

Core files:
- `lib/main.dart`: initializes Firebase, environment config, and the root provider override.
- `lib/core/configuration/app_bootstrap.dart`: one-stop app startup sequence.
- `lib/core/configuration/app_config.dart`: immutable app config exposed through Riverpod.
- `lib/core/configuration/app_environment.dart`: development, staging, and production environment values.
- `lib/core/design_system/design_system.dart`: single import for shared theme tokens and widgets.

Rules:
- Keep startup side effects in `AppBootstrap` rather than scattering them through `main.dart`.
- Import the design system barrel when a screen needs shared theme tokens or base widgets.
- Keep future cross-cutting services behind interfaces so the implementation can be swapped later.

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
- Documents: secure vault and metadata for passports, visas, tickets, and confirmations
- AI: prompt assembly + backend orchestration

## Phase 0 Foundation Baseline
Target module roots for product-scale development:
- app
- core
- features
- shared

Canonical feature roots for planned product streams:
- authentication
- profile
- trips
- finance
- travel
- ai
- bookings
- documents
- translator
- settings

Migration guidance:
- Existing modules (`auth`, `flights`, `hotels`, `wallet`) remain active until moved.
- New sprint work should prefer canonical roots when creating new capability slices.
- Preserve backward-compatible route names and provider contracts while migrating.

Design-system baseline primitives:
- Buttons: Primary, Secondary, Danger, icon actions
- Cards: Wallet, Trip, Booking, Budget, Expense
- Inputs: Search, currency and country pickers, date, amount, phone
- States: Loading, Error, Empty, Offline, Permission
- Navigation: bottom navigation, drawer support, FAB, modal sheet helper

Sprint order baseline:
1. Authentication and Profile
2. Currency Engine
3. Multi-Currency Wallet
4. Trip Management
5. Budget and Expenses
6. Bookings
7. AI Assistant

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
