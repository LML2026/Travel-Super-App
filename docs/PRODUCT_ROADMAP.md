# Travel Super App Product Roadmap

## Objective
Move from feature-by-feature implementation to milestone-based product delivery with clear acceptance criteria, release goals, and quality gates.

## Current Baseline (Phase 1)
- Authentication: Complete
- Flights: Complete
- Hotels: Complete
- Weather: Complete
- Trips: In progress

## Phase 2: Trip Management

### Sprint 1 (done)
- Create Trip
- Trip List
- Trip Details

### Sprint 2 (next)
- Edit Trip
- Delete Trip
- Duplicate Trip

Acceptance criteria:
- User can edit existing trip destination, dates, budget, currency, travellers, and notes.
- User can delete trip with confirmation and optimistic UI refresh.
- User can duplicate a trip and optionally adjust dates before save.
- All actions update Firestore under users/{uid}/trips.

### Sprint 3
- Attach Flight
- Attach Hotel
- Add rich Notes
- Upload Documents (tickets, visas, insurance)

Acceptance criteria:
- Flight and hotel linking persisted by ID on trip.
- Notes support multi-line text and display on details page.
- Documents stored in Firebase Storage with metadata in Firestore.

## Phase 3: Travel Planner
- Itinerary timeline per trip
- Add itinerary item (flight, hotel, activity, dining, transport, note)
- Reorder items with drag-and-drop

Acceptance criteria:
- Stable ordering field (sortIndex) persisted in Firestore.
- Reordering reflected across app reload.
- Timeline supports same-day multiple events.

## Phase 4: Smart Dashboard
- Next trip card
- Countdown
- Weather snapshot
- Quick actions

Acceptance criteria:
- Dashboard loads in < 2 seconds on warm start.
- Handles no-trip state and offline state gracefully.

## Phase 5: Wallet
- Multi-currency balances
- Live exchange rates
- Spending tracker
- Budget progress

Acceptance criteria:
- Budget summary computed from expenses and trip budget.
- Currency conversion uses latest available rates with timestamp.

## Phase 6: Translator
- Text translation
- Voice conversation support
- Camera translation hooks
- Offline language pack strategy

Acceptance criteria:
- Translation feature available in degraded mode when network unavailable.

## Phase 7: AI Travel Assistant
- Itinerary generation
- Travel recommendations
- Budget estimate
- Destination Q and A

Acceptance criteria:
- Every assistant response includes source mode: llm or fallback.
- Prompt and context boundaries documented and tested.

## Phase 8: Notifications
- Flight delay alerts
- Check-in reminders
- Weather alerts
- Passport expiry reminders
- Currency rate alerts

Acceptance criteria:
- User-level notification preferences and opt-out controls.

## Phase 9: Booking and Payments
- Payment provider integration
- Booking history
- Receipt download

Acceptance criteria:
- PCI-safe architecture with no card data stored in app backend.
- Signed receipt URLs and audit trails.

## Version Roadmap
- v1.0: Authentication, Flights, Hotels, Weather
- v1.1: Trip Management
- v1.2: Saved Items and Itinerary
- v1.3: Maps and Attractions
- v1.4: Wallet and Budget
- v1.5: Translator
- v2.0: AI Travel Assistant
- v2.1: Payments and Booking
- v3.0: App Store and Play Store release

## Delivery Cadence
- Sprint length: 2 weeks
- Definition of done:
  - Feature acceptance criteria met
  - Unit and widget tests added/updated
  - API contract documented
  - No analyzer errors in touched modules
  - Release notes updated
