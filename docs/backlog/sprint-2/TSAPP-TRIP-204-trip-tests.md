# TSAPP-TRIP-204: Trip Test Expansion

## Type
Quality

## Goal
Raise confidence for Sprint 2 changes with focused widget and provider tests.

## Scope
- Add or update tests for:
  - Edit flow
  - Delete flow
  - Duplicate flow
  - Existing list -> details navigation regression
- Keep tests deterministic using provider overrides

## Acceptance Criteria
1. Every Sprint 2 feature has at least one happy-path test.
2. Every validation or destructive path has at least one negative test.
3. Tests are isolated and do not require live backend services.

## Candidate Test Files
- test/features/trips/create_trip_page_test.dart
- test/features/trips/trip_details_page_test.dart
- test/features/trips/trip_card_test.dart
- new: test/features/trips/trip_lifecycle_test.dart

## Estimate
3 story points

## Dependencies
TSAPP-TRIP-201
TSAPP-TRIP-202
TSAPP-TRIP-203
