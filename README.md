# Travel Super App

Travel Super App is a Flutter-first travel platform with a Node.js backend, Firebase data layer, and milestone-driven product roadmap.

## Product Direction
- Milestone plan: [docs/PRODUCT_ROADMAP.md](docs/PRODUCT_ROADMAP.md)
- Technical architecture: [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md)
- Backend API contract: [docs/API_SPEC.md](docs/API_SPEC.md)
- UI library standard: [docs/UI_COMPONENT_LIBRARY.md](docs/UI_COMPONENT_LIBRARY.md)
- Testing strategy: [docs/TESTING_STRATEGY.md](docs/TESTING_STRATEGY.md)

## Sprint Delivery Assets
- Sprint 2 execution board: [docs/sprints/SPRINT_2_EXECUTION_BOARD.md](docs/sprints/SPRINT_2_EXECUTION_BOARD.md)
- Sprint 2 backlog tickets: [docs/backlog/sprint-2](docs/backlog/sprint-2)
- OpenAPI skeleton: [docs/openapi.yaml](docs/openapi.yaml)

## Current Status
- Authentication: complete
- Flights: complete
- Hotels: complete
- Weather: complete
- Trips: in progress

## Technology Stack
- Mobile: Flutter
- State management: Riverpod
- Backend: Node.js + Express
- Database: Firebase Firestore
- Authentication: Firebase Auth
- File storage: Firebase Storage (planned)
- Push notifications: Firebase Cloud Messaging (planned)
- Payments: Stripe or equivalent (planned)
- AI: OpenAI-compatible provider with fallback mode

## Local Development
1. Install Flutter SDK and Node.js.
2. Start backend from [backend/server.js](backend/server.js).
3. Run Flutter app from [lib/main.dart](lib/main.dart).

## Delivery Model
- Two-week sprint cadence
- Milestone release gates with tests and analyzer checks
- Feature branches for all changes

## Immediate Next Milestone
Phase 2 Sprint 2: Edit Trip, Delete Trip, Duplicate Trip with tests and Firestore alignment.
