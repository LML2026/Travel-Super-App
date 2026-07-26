# Sprint 1 Execution Board

## Sprint Window
- Duration: 2 weeks (10 working days)
- Milestone: Release 1.1, Sprint 1
- Theme: Trip management foundation

## Sprint Objective
Deliver complete core trip CRUD and data persistence quality baseline:
- Create Trip
- Trip List
- Trip Details
- Edit Trip
- Delete Trip
- Firestore integration hardening
- Unit tests

## Scope
### In Scope
- Build and validate trip creation flow with required fields
- Display trip list with refresh and empty states
- Render trip detail view with complete field display
- Support edit flow with prefilled values and save updates
- Support delete flow with confirmation and success/error feedback
- Verify Firestore write/read consistency for users/{uid}/trips
- Add unit and widget coverage for trip provider and key screens

### Out of Scope
- Attach flight and hotel workflows (Sprint 2)
- Weather snapshot enrichment (Sprint 2)
- Budget analytics and wallet integration (Release 1.3)

## Work Items and Estimates
| ID | Work Item | Owner | Estimate | Target Date | Status |
|---|---|---|---|---|---|
| TSAPP-TRIP-101 | Create Trip flow and validation | FE-TRIPS-1 | 3 pts | 2026-07-28 | In Review |
| TSAPP-TRIP-102 | Trip List states and refresh | FE-TRIPS-2 | 2 pts | 2026-07-29 | In Review |
| TSAPP-TRIP-103 | Trip Details rendering and actions | FE-TRIPS-2 | 2 pts | 2026-07-30 | In Review |
| TSAPP-TRIP-104 | Edit Trip flow and persistence | FE-TRIPS-1 | 3 pts | 2026-07-31 | In Review |
| TSAPP-TRIP-105 | Delete Trip flow and confirmations | FE-TRIPS-1 | 2 pts | 2026-08-01 | In Review |
| TSAPP-TRIP-106 | Firestore integration hardening | BE-TRIPS-1 | 3 pts | 2026-08-04 | In Review |
| TSAPP-TRIP-107 | Unit and widget tests for Sprint 1 | QA-TRIPS-1 | 3 pts | 2026-08-05 | In Progress |

## Delivery Plan
### Week 1
- Day 1-2: Create Trip + List
- Day 3: Trip Details
- Day 4-5: Edit + Delete

### Week 2
- Day 1-2: Firestore hardening and edge cases
- Day 3: Unit/widget tests
- Day 4: QA pass and docs updates
- Day 5: Sprint demo and merge prep

## Acceptance Criteria
### Create Trip
- Required fields validated before submission
- Successful creation persists a trip under users/{uid}/trips/{tripId}
- User receives clear success feedback

### Trip List
- List shows current user trips
- Empty state displays guidance CTA
- Refresh/load states are clearly visible

### Trip Details
- Full trip fields are rendered reliably
- Navigation back behavior is consistent
- Edit and delete actions are reachable from details

### Edit and Delete
- Edit opens with prefilled values and saves updates
- Delete requires confirmation and updates list without manual restart

### Tests and Quality
- Unit tests cover trip provider key branches
- Widget tests cover create/list/details/edit/delete happy paths
- Analyzer and CI checks pass for changed scope

## Risks and Mitigations
- Risk: legacy route re-exports mask regressions
  - Mitigation: assert navigation coverage in widget tests
- Risk: Firestore schema drift between app and docs
  - Mitigation: update database.md and ticket notes with each model change
- Risk: asynchronous state race conditions in list refresh
  - Mitigation: explicit loading state assertions in provider tests

## Definition of Done
- Code complete and peer-reviewed
- Tests passing locally and in CI
- Documentation updated in roadmap and sprint artifacts
- Merged into develop via feature branch workflow
