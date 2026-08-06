# Project Board

This board tracks release-oriented execution for Travel Super App.

## Company-Mode Execution (3.0)
Status: In progress

Primary outcome:
- Operate as a platform company with measurable reliability, retention, and monetization, not only feature throughput.

Execution artifacts:
1. docs/COMPANY_MODE_EXECUTION_3_0.md
2. docs/API_PLATFORM_CONTRACTS_AND_VERSIONING.md
3. docs/BETA_PROGRAM_OPERATIONS_PLAYBOOK.md

Operating gates before major feature expansion:
1. Stable API contract layer and versioning control.
2. CI/CD quality gates and contract tests enforced.
3. Active beta program with weekly evidence-to-roadmap loop.

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

## Phase 3 - Production and Launch
Status: In progress

Primary outcome:
- Move from feature delivery to trust, reliability, and launch readiness.

Tracks:
1. Security
- Firebase App Check enforcement
- Secure API key management and secret rotation
- Encrypted local storage for sensitive records
- Hardened Firestore Security Rules
- Backend rate limiting and abuse protection
- GDPR compliance path: consent, export, delete account/data

2. Performance
- Lazy-load non-critical feature modules
- Cache maps, images, and high-value API responses
- Firestore query/index optimisation
- Image compression and payload sizing
- Offline-first synchronisation behaviour

3. Quality
- Unit, widget, and integration test baselines per feature
- Crashlytics wiring and triage workflow
- Analytics events for core user journeys

4. CI/CD
- GitHub Actions for analyzer, tests, and backend checks
- Automated Android/iOS/Web build workflows
- Release versioning and staged beta lanes

Release gates:
- Gate A (Security): App Check, secrets, rules, rate limiting, GDPR endpoints validated
- Gate B (Reliability): crash reporting active, analytics event map shipped, offline sync checks pass
- Gate C (Delivery): CI green on all required workflows, signed beta builds distributed

## Epic Status
| Epic | Status | Notes |
|---|---|---|
| Core Platform | Foundation complete | Entered production hardening and launch track |
| Authentication | In progress | Focus shifts to App Check + deletion/export compliance |
| User Profile | In progress | Prepare privacy controls and consent management |
| Currency Engine | Ready | ISO catalog, search, favourites, rates |
| Wallet | In progress | Expand for multi-currency operations and shared-travel readiness |
| Budget | Planned | Awaiting finance milestone execution |
| Expenses | Planned | Awaiting finance milestone execution |
| Trips | Foundation complete | Add offline resilience and timeline orchestration hooks |
| Documents | Planned | Secure and sync-capable vault model |
| Bookings | In progress | Evolving toward multi-provider marketplace comparisons |
| AI Assistant | In progress | Context-aware concierge and dynamic recommendation engine |
| Production Readiness | In progress | Security, performance, quality, CI/CD launch tracks |

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

### Milestone 4 - Product Hardening and Launch
Status: In progress

Scope:
- Security hardening end-to-end
- Performance optimisation and offline-first behavior
- Test depth and observability
- CI/CD release automation
- Private beta programme (20-50 testers)

## MVP vs Version 1.0

MVP target:
- Authentication
- Trips
- Maps
- Flights
- Hotels
- Taxi (initial provider integration)
- Wallet (expenses and currencies)
- Documents
- AI assistant
- Notifications

Version 1.0 expansion:
- Group trips
- Shared expenses
- Deeper offline mode
- Loyalty cards
- Attraction tickets
- Restaurant reservations
- Safety center
- Translation upgrades

## Discovery and Validation Loop
1. Invite 20-50 beta testers.
2. Observe real trip-planning and travel-day behavior.
3. Prioritise UX and reliability fixes before net-new modules.
4. Ship improvements based on measured usage and friction.

## Phase 4 - Commercial Roadmap

Primary direction:
- Build Travel Super App 2.0 as an ecosystem with measurable monetization and retention.

Priority modules after launch hardening:
1. Visa and entry requirements
2. eSIM marketplace
3. Travel insurance
4. Attractions and experiences
5. Restaurant reservations
6. Group trips

Execution rule:
- Expand modules only when beta evidence shows user pull and willingness to pay.

Reference:
- docs/COMMERCIAL_ROADMAP_2_0.md

## Immediate Next Task
Product-owner execution mode is active.

Reference plan:
1. docs/releases/BETA_2_PRODUCT_OWNER_EXECUTION_PLAN.md
2. docs/releases/VERSION_1_0_COMPLETION_PLAYBOOK.md
3. docs/releases/VERSION_1_0_BRANCHING_MODEL.md
4. docs/releases/VERSION_1_0_RELEASE_GATE_CHECKLIST.md

Execution priorities now:
1. Run a 2-4 week Beta 2 stabilization sprint with no major new features.
2. Fix only tester-reported bugs, improve performance, onboarding, loading states, and error clarity.
3. Freeze Version 1.0 scope on release/1.0 and route post-launch features to develop.
4. Complete Phase A through Phase H in the Version 1.0 completion playbook before public launch.
5. Hold gates at crash-free sessions above 99% and zero open critical bugs.
6. Replace remaining mock/demo data with real providers in priority order: Flights, Hotels, Taxi, Maps, Weather, Currency.
7. Start iOS TestFlight path only after Android stability gates are met.
8. Prepare launch website, pricing packaging, partnership pipeline, and marketing assets before public release.
9. Follow staged rollout ladder: internal beta -> 100 -> 500 -> 2000 -> public.

This unlocks Version 1.0 readiness with reliability-first execution.

## Phase 6 - Launch and Growth
Status: In progress

Primary outcome:
- Run Travel Super App as a measurable product business with strong activation, reliability, and support loops.

Execution reference:
1. docs/PHASE_6_LAUNCH_AND_GROWTH.md

Phase 6 workstreams:
1. Public Website
- Product overview, feature highlights, screenshots, pricing path, store links, FAQ, contact, privacy, terms.

2. Onboarding
- Welcome -> language -> account -> currency -> notifications -> location -> first trip -> done.
- Track step-level drop-off and completion.

3. Analytics
- Sign-up completion, first trip, search, taxi, wallet, AI, booking completion.
- Weekly KPI scorecard and alerting for conversion drops.

4. Customer Support
- In-app help center, FAQ, support contact, bug reports, feature requests.
- Weekly feedback triage into roadmap.

5. Release Strategy
- Internal testing -> closed beta -> open beta -> 1.0.
- Explicit exit criteria for each stage.

6. App Store Readiness
- Icons, splash, screenshots, feature graphics, promo text, privacy labels, age rating, support/privacy URLs.

7. Performance Targets
- Launch <2s target profile, smooth scrolling, fast search responses, reliable offline behavior, minimal crashes.

8. User Feedback Loop
- Report problem, suggest feature, rate experience.
- Weekly prioritization cadence.

Phase 6 launch metrics:
1. First-trip creation rate
2. Booking completion rate
3. 30-day retention
4. Crash-free sessions
5. Satisfaction trend
