# TSAPP-TRIP-202: Delete Trip Flow

## Type
Feature

## Goal
Allow users to delete a trip safely with confirmation and immediate UI update.

## Scope
- Delete from:
  - Trip card menu
  - Trip details menu
- Confirmation dialog with explicit destructive action
- Snackbar feedback for success and failure

## Acceptance Criteria
1. User must confirm before delete executes.
2. On success, trip disappears from list without full app reload.
3. On failure, user sees actionable error message.
4. Details page returns to previous screen when deleted.

## Technical Notes
- Primary files:
  - lib/features/trips/screens/trip_list_page.dart
  - lib/features/trips/screens/trip_details_page.dart
  - lib/features/trips/providers/trip_provider.dart

## Test Plan
- Widget test: confirmation dialog shown
- Widget test: cancel path keeps item
- Widget test: confirm path removes item and shows message

## Estimate
2 story points

## Dependencies
TSAPP-TRIP-201 recommended but not required
