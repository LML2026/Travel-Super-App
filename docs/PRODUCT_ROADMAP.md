# Travel Super App Product Roadmap

## Vision
Build a production-grade travel super app, not a collection of demos.

Every feature must satisfy four criteria:
- Useful: solves a real traveller problem.
- Scalable: supports growth without major redesign.
- Testable: includes automated tests where appropriate.
- Replaceable: external services can be swapped without changing the rest of the app.

## Release 1.0 Goal
A traveller should be able to:
- Create an account.
- Plan a trip.
- Manage a multi-currency wallet.
- Convert currencies.
- Track expenses.
- Stay within budget.
- Store travel documents securely.
- Access everything offline.
- Sync across devices.

Everything in active development should contribute to this goal.

## Product Platform Structure
Travel Super App
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

## First Three Real Milestones

### Milestone 1 - Core Platform
Deliverables:
- Stable project structure
- Authentication
- User profile
- Settings
- Design system
- Navigation
- Localisation
- Offline storage

Outcome:
- A polished application shell.

### Milestone 2 - Finance
Deliverables:
- ISO currency catalogue
- Exchange-rate service
- Multi-currency wallet
- Converter
- Transaction history
- Budgets
- Expenses

Outcome:
- A traveller can manage money anywhere in the world.

### Milestone 3 - Travel
Deliverables:
- Trips
- Itineraries
- Bookings
- Documents
- Packing lists
- Maps
- Notifications

Outcome:
- The app becomes a complete travel companion.

## Project Board (Current)
- Core Platform: In progress
- Authentication: Ready
- User Profile: Ready
- Currency Engine: Ready
- Wallet: Started
- Budget: Planned
- Expenses: Planned
- Trips: Foundation complete
- Documents: Planned
- Bookings: Planned
- AI Assistant: Planned

## Product Roadmap (12 Epics)

### Epic 1 - Core Platform
- App bootstrap
- Dependency injection
- GoRouter navigation
- Design system
- Logging
- Configuration
- Localisation
- Offline storage

### Epic 2 - Identity
- Firebase Authentication
- User profiles
- Settings
- Preferences
- Biometric authentication

### Epic 3 - Finance
- Currency engine
- Multi-currency wallet
- Exchange rates
- Converter
- Transactions

### Epic 4 - Trips
- Trip planner
- Itinerary
- Notes
- Packing lists
- Calendar integration

### Epic 5 - Budgets
- Trip budgets
- Expense tracker
- Spending analytics
- Receipt storage

### Epic 6 - Bookings
- Flights
- Hotels
- Car hire
- Rail
- Activities

### Epic 7 - Documents
- Passport vault
- Visa storage
- Insurance
- Boarding passes
- Secure encrypted storage

### Epic 8 - AI
- Trip planner
- Packing assistant
- Budget adviser
- Currency assistant
- Translation helper

### Epic 9 - Social
- Shared trips
- Group expenses
- Trip invitations
- Live location (optional)

### Epic 10 - Marketplace
- Insurance
- eSIM
- Airport lounges
- Transfers
- Local experiences

### Epic 11 - Notifications
- Flight reminders
- Budget alerts
- Exchange-rate alerts
- Check-in reminders

### Epic 12 - Production
- Analytics
- Crash reporting
- Performance
- Accessibility
- CI/CD
- Store publishing

## Current Highest-Priority Sequence
1. Firebase Authentication (replace demo user assumptions).
2. User Profile with preferences (language, home currency, home country).
3. Currency Engine (all ISO 4217 currencies, favourites, search, exchange rates).
4. Wallet UI powered by the currency engine.

This sequence establishes a stable identity layer and reusable financial foundation for later epics.
