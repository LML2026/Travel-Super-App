# TSAPP-TRIP-101: Create Trip Flow

## Type
Feature

## Goal
Enable authenticated users to create a trip with validated core fields.

## Scope
- Create form fields:
  - destination
  - departureDate
  - returnDate
  - budget
  - currency
  - travellers
  - notes
- Validate required and date constraints
- Persist to users/{uid}/trips/{tripId}

## Acceptance Criteria
1. User can submit a valid trip and receives success feedback.
2. Invalid input blocks submit and displays useful messages.
3. Newly created trip appears in Trip List after creation.

## Technical Notes
- Primary files:
  - lib/features/trips/presentation/screens/create_trip_page.dart
  - lib/features/trips/presentation/providers/trip_provider.dart
  - lib/core/services/trip_service.dart

## Test Plan
- Widget test: valid create path
- Widget test: invalid form validation
- Provider test: createTrip state transitions

## Estimate
3 story points

## Dependencies
None

## Ownership and Schedule
- Owner: FE-TRIPS-1
- Target date: 2026-07-28

## Git Workflow
- Branch: feature/trips/tsapp-trip-101-create-trip
- PR title: [TSAPP-TRIP-101] Create Trip flow and validation
