# TSAPP-ID-103: User Profile Module

## Type
Feature

## Goal
Deliver a user profile module that stores identity defaults and preferences for authenticated users.

## Scope
- Create profile domain model and repository contract
- Persist profile document in Firestore under users/{uid}/profile
- Add profile read/update use cases and provider wiring
- Build profile screen with editable preferences:
  - display name
  - preferred currency
  - preferred language
  - home airport
- Apply validation and user-friendly error/success feedback
- Wire profile bootstrap into authenticated app flow

## Acceptance Criteria
1. Authenticated users can view and edit profile fields in app.
2. Profile updates persist and are visible after app restart.
3. Missing profile documents are initialized safely with defaults.
4. Errors are surfaced without crashing navigation or providers.

## Technical Notes
- Primary files:
  - lib/features/profile/
  - lib/core/services/firestore_service.dart
  - lib/app/router.dart
- Data contract:
  - users/{uid}/profile

## Test Plan
- Unit test: profile repository mapping and update flow
- Provider test: loading, success, and error states
- Widget test: profile screen edit/save happy path
- Regression: auth to home route with missing profile document

## Estimate
3 story points

## Dependencies
TSAPP-ID-102

## Ownership and Schedule
- Owner: FE-PROFILE-1
- Target date: 2026-08-03

## Git Workflow
- Branch: feature/profile/tsapp-id-103-user-profile-module
- PR title: [TSAPP-ID-103] Implement user profile module and persistence
