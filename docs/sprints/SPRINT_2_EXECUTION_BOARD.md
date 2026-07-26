# Sprint 2 Execution Board

## Sprint Window
- Duration: 2 weeks (10 working days)
- Milestone: Phase 2, Sprint 2
- Theme: Trip lifecycle completeness

## Sprint Objective
Deliver complete lifecycle operations for trips with production-ready UX and quality:
- Edit Trip
- Delete Trip
- Duplicate Trip

## Scope
### In Scope
- Edit existing trip fields: destination, departureDate, returnDate, budget, currency, travellers, notes
- Delete trip with confirmation and user feedback
- Duplicate trip from list and details views
- Add or update widget tests for all new user flows
- Ensure Firestore persistence consistency in users/{uid}/trips

### Out of Scope
- Attach flight/hotel workflows (Sprint 3)
- Document upload workflows (Sprint 3)
- Timeline reorder support (Phase 3)

## Work Items and Estimates
| ID | Work Item | Owner | Estimate | Status |
|---|---|---|---|---|
| TSAPP-TRIP-201 | Edit Trip flow and validation | TBD | 3 pts | Todo |
| TSAPP-TRIP-202 | Delete Trip flow and confirmations | TBD | 2 pts | Todo |
| TSAPP-TRIP-203 | Duplicate Trip flow and defaults | TBD | 3 pts | Todo |
| TSAPP-TRIP-204 | Trip widget and provider tests | TBD | 3 pts | Todo |
| TSAPP-TRIP-205 | QA checklist and release notes | TBD | 2 pts | Todo |

## Delivery Plan
### Week 1
- Day 1-2: Edit Trip implementation
- Day 3: Delete Trip implementation
- Day 4-5: Duplicate Trip implementation

### Week 2
- Day 1-2: Tests and edge cases
- Day 3: QA pass and bug fixes
- Day 4: Release prep and docs updates
- Day 5: Milestone demo and merge

## Acceptance Criteria
### Edit Trip
- User can open Edit from Trip List and Trip Details
- Existing values are pre-filled
- Validation rules match Create Trip
- Save updates current trip document and returns user to previous screen

### Delete Trip
- Confirmation dialog appears before destructive action
- Deleted trip is removed from UI without manual refresh
- Success and failure toast/snackbar states are visible

### Duplicate Trip
- User can duplicate from card menu or details menu
- New document ID is generated
- createdAt and updatedAt are reset server-side
- Duplicated trip opens in Edit/Create page for optional adjustment before final save

## Risks and Mitigations
- Risk: legacy trip module overlap
  - Mitigation: route all trip changes through lib/features/trips only
- Risk: regressions in existing details navigation
  - Mitigation: add regression widget tests for list to details flow
- Risk: inconsistent date handling
  - Mitigation: centralize date validation and add boundary tests

## Quality Gates
- Zero analyzer errors in changed files
- Tests added for all new behaviors
- Manual smoke checks:
  - Create -> List -> Details
  - Edit -> Persist -> Reload
  - Delete -> Removed from list
  - Duplicate -> New record appears

## Definition of Done
- Code complete and reviewed
- Tests passing locally and in CI
- Docs updated in roadmap and release notes
- Merged via feature branch workflow
