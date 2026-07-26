# TSAPP-TRIP-203: Duplicate Trip Flow

## Type
Feature

## Goal
Enable users to duplicate an existing trip as a starting point for a new itinerary.

## Scope
- Duplicate action from list card menu and details menu
- Create a new trip using existing trip values
- New generated ID and fresh timestamps
- Option to adjust fields before save

## Acceptance Criteria
1. Duplicate action creates a new trip draft from source trip.
2. Duplicate does not overwrite original trip.
3. New trip is persisted with new ID and server timestamps.
4. Duplicated trip appears in list and opens details correctly.

## Technical Notes
- Primary files:
  - lib/features/trips/screens/trip_list_page.dart
  - lib/features/trips/screens/trip_details_page.dart
  - lib/features/trips/providers/trip_provider.dart
  - lib/features/trips/models/trip.dart

## Test Plan
- Provider/unit test: duplication creates distinct id
- Widget test: duplicate flow produces new card in list
- Regression test: original trip remains unchanged

## Estimate
3 story points

## Dependencies
TSAPP-TRIP-201
