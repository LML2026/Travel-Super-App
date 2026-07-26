# TSAPP-TRIP-102: Trip List States and Refresh

## Type
Feature

## Goal
Provide a reliable list experience with loading, empty, and data states.

## Scope
- Display trips for current user
- Show loading indicator while fetching
- Show empty state when no trips exist
- Support pull-to-refresh or explicit refresh action

## Acceptance Criteria
1. List renders all user trips with stable ordering.
2. Empty state is visible with clear next action.
3. Refresh updates list without app restart.

## Technical Notes
- Primary files:
  - lib/features/trips/presentation/screens/trip_list_page.dart
  - lib/features/trips/presentation/providers/trip_provider.dart

## Test Plan
- Widget test: loading to loaded transition
- Widget test: empty state rendering
- Provider test: refresh flow

## Estimate
2 story points

## Dependencies
TSAPP-TRIP-101

## Ownership and Schedule
- Owner: FE-TRIPS-2
- Target date: 2026-07-29

## Git Workflow
- Branch: feature/trips/tsapp-trip-102-trip-list
- PR title: [TSAPP-TRIP-102] Trip List states and refresh
