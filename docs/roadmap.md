# ITAREVO Roadmap

## Goal

Build a production-ready ITAREVO from the ground up with professional engineering practices.

## Phase 1 - Core Platform (Weeks 1-4)

Objective: Create a stable foundation.

### Flutter Platform

- Flutter 3.x
- Material 3
- Riverpod
- GoRouter
- Firebase Authentication
- Firestore
- Firebase Storage
- Firebase Cloud Messaging

### Backend Platform

- Node.js + Express
- REST API baseline
- Environment configuration
- Logging
- Input validation
- Error handling

## Phase 2 - Core Features (Weeks 5-10)

Complete and production-harden these modules:

- Flights
- Hotels
- Weather
- Trips
- Saved Items

Every module must include:

```text
Feature
|-- Data
|-- Domain
|-- Presentation
|-- Tests
`-- Documentation
```

## Phase 3 - Premium Features

- Multi-currency wallet
- Translator
- Maps
- Restaurant recommendations
- Attractions
- Travel insurance
- Car hire
- Train tickets

## Phase 4 - AI

The AI assistant should understand user trips and provide personalised recommendations, including:

- Plan my holiday.
- Find a cheaper hotel.
- Suggest attractions nearby.
- Estimate my daily spending.
- Translate this menu.
- Remind me to check in.
- Rebook my flight if it is cancelled.

## Phase 5 - Commercial Release

Production release checklist:

- Google Play Store release
- Apple App Store release
- Analytics
- Crash reporting
- Accessibility review
- Performance optimisation
- Privacy policy
- Terms of service

## Release Progression

- Release 1.1: Trip Management
- Release 1.2: Booking Integration
- Release 1.3: Itinerary Planner
- Release 1.4: Maps and Places
- Release 1.5: Wallet
- Release 2.0: AI Travel Assistant
- Release 2.1: Booking and Payments
- Release 3.0: Production Launch

## Project Documentation

Maintain docs alongside code:

```text
docs/
|-- architecture.md
|-- api.md
|-- database.md
|-- setup.md
|-- deployment.md
|-- testing.md
|-- roadmap.md
`-- ui-guidelines.md
```

## Development Workflow

Every feature follows this cycle:

1. Design - Define UI, data model, and user flow.
2. Implement - Build Flutter feature + backend support.
3. Test - Add unit, widget, and integration tests.
4. Review - Refactor and verify structure compliance.
5. Commit - Save a stable Git checkpoint.

## Delivery Model

Build feature-by-feature with a clear deliverable per sprint:

1. Architecture: where the feature fits.
2. Backend: routes, services, and validation.
3. Flutter: models, providers, screens, and widgets.
4. Tests: unit and widget tests (plus integration when needed).
5. Git checkpoint: stable merge-ready state.
