# Project Board

This board tracks release-oriented execution for Travel Super App.

## Release 1.0 Objective
A traveller can:
- Create an account
- Plan a trip
- Manage a multi-currency wallet
- Convert currencies
- Track expenses
- Stay within budget
- Store travel documents securely
- Work offline
- Sync across devices

## Epic Status
| Epic | Status | Notes |
|---|---|---|
| Core Platform | In progress | Platform shell and standards in place, hardening continues |
| Authentication | In review | TSAPP-ID-102 delivered on feature/authentication/tsapp-id-102-auth-module |
| User Profile | In progress | TSAPP-ID-103 active on feature/profile/tsapp-id-103-user-profile-module |
| Currency Engine | Ready | ISO catalog, search, favourites, rates |
| Wallet | Started | Running in app, align with full finance model |
| Budget | Planned | Awaiting finance milestone execution |
| Expenses | Planned | Awaiting finance milestone execution |
| Trips | Foundation complete | Build toward full travel milestone scope |
| Documents | Planned | Secure and sync-capable vault model |
| Bookings | Planned | Flights/hotels/cars/rail/activities |
| AI Assistant | Planned | Depends on identity and finance context |

## Active Milestones

### Milestone 1 - Core Platform
Status: In progress

Scope:
- Stable project structure
- Authentication
- User profile
- Settings
- Design system
- Navigation
- Localisation
- Offline storage

### Milestone 2 - Finance
Status: Planned

Scope:
- ISO currency catalogue
- Exchange-rate service
- Multi-currency wallet
- Converter
- Transaction history
- Budgets
- Expenses

### Milestone 3 - Travel
Status: Planned

Scope:
- Trips
- Itineraries
- Bookings
- Documents
- Packing lists
- Maps
- Notifications

## Immediate Next Task
Authentication and user profiles:
1. User profile module
2. Persistence and synchronisation
3. Auth PR review and merge

This unlocks every cloud-connected module for Release 1.0.
