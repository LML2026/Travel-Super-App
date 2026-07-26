# TSAPP-TRIP-104: Edit Trip Flow and Persistence

## Type
Feature

## Goal
Allow users to edit existing trips with prefilled values and reliable updates.

## Scope
- Entry points from list/details
- Prefill existing values in edit form
- Save updates to users/{uid}/trips/{tripId}

## Acceptance Criteria
1. Edit screen opens with current values.
2. Validation mirrors Create Trip rules.
3. Successful save updates details and list views.

## Technical Notes
- Primary files:
  - lib/features/trips/presentation/screens/create_trip_page.dart
  - lib/features/trips/presentation/screens/trip_list_page.dart
  - lib/features/trips/presentation/screens/trip_details_page.dart
  - lib/features/trips/presentation/providers/trip_provider.dart

## Test Plan
- Widget test: prefilled form state
- Widget test: successful update feedback
- Provider test: updateTrip state path

## Estimate
3 story points

## Dependencies
TSAPP-TRIP-101

## Ownership and Schedule
- Owner: FE-TRIPS-1
- Target date: 2026-07-31

## Git Workflow
- Branch: feature/trips/tsapp-trip-104-edit-trip
- PR title: [TSAPP-TRIP-104] Edit Trip flow and persistence
