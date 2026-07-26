# TSAPP-TRIP-201: Edit Trip Flow

## Type
Feature

## Goal
Allow users to update an existing trip from both list and details views.

## Scope
- Entry points:
  - Trip card menu -> Edit
  - Trip details menu -> Edit
- Form fields:
  - destination
  - departureDate
  - returnDate
  - budget
  - currency
  - travellers
  - notes
- Save behavior updates existing document in users/{uid}/trips/{tripId}

## Acceptance Criteria
1. Edit opens pre-populated form for selected trip.
2. Validation matches Create Trip rules.
3. Save updates trip and returns success feedback.
4. Trip list reflects edits after navigation return.

## Technical Notes
- Primary files:
  - lib/features/trips/screens/create_trip_page.dart
  - lib/features/trips/screens/trip_list_page.dart
  - lib/features/trips/screens/trip_details_page.dart
  - lib/features/trips/providers/trip_provider.dart

## Test Plan
- Widget test: open edit and validate pre-filled state
- Widget test: invalid input shows expected errors
- Widget test: successful save path and success message

## Estimate
3 story points

## Dependencies
None
