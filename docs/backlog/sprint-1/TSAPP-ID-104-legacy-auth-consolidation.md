# TSAPP-ID-104: Legacy Auth Stack Consolidation

## Type
Tech Debt

## Goal
Consolidate duplicate authentication implementations so the application uses one production auth stack based on the new features/authentication domain-first architecture.

## Scope
- Inventory and remove deprecated auth flow paths in features/auth that duplicate new logic
- Migrate remaining usages to features/authentication providers and routes
- Align route entry points to a single login/register/forgot-password source
- Ensure profile sign-out and splash boot path read from consolidated providers only
- Remove dead imports/services after migration

## Acceptance Criteria
1. Only one active auth implementation remains in app runtime paths.
2. Login/register/forgot-password/email-verification flows resolve through features/authentication.
3. Analyzer and tests pass after removing legacy auth duplicates.
4. No regressions in protected-route redirects and sign-out behavior.

## Technical Notes
- Primary files:
  - lib/features/auth/
  - lib/features/authentication/
  - lib/app/router.dart
  - lib/app/route_groups/auth_routes.dart
- Keep non-auth features untouched except where imports must be updated.

## Test Plan
- Provider tests for auth state and action controller
- Widget smoke tests for login/register/forgot-password screens
- Regression checks for splash redirects and protected routes

## Estimate
3 story points

## Dependencies
TSAPP-ID-102

## Ownership and Schedule
- Owner: FE-AUTH-2
- Target date: 2026-07-29

## Git Workflow
- Branch: feature/authentication/tsapp-id-104-legacy-auth-consolidation
- PR title: [TSAPP-ID-104] Consolidate legacy auth stack to domain-first architecture
