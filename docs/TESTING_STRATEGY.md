# Testing Strategy

## Goal
Ship each milestone with reliable quality gates across mobile and backend.

## Test Pyramid
- Unit tests: business logic, model mapping, utilities
- Widget tests: screen states, form validation, interactions
- Integration tests: feature workflows across modules
- Backend tests: endpoint behavior and contract validation

## Flutter Test Scope

### Unit
- Model serialization and mapping
- Repository result mapping
- Provider state transitions

### Widget
- Form validation (Create Trip, Edit Trip)
- Loading, error, and empty states for major screens
- Trip list card tap and navigation behavior

### Integration
- Authentication to dashboard path
- Create trip to list to details flow
- Attach saved flight and hotel to trip flow

## Backend Test Scope
- Route validation for required params
- Success and error responses for each endpoint
- Fallback behavior for AI endpoint when provider unavailable

## Required Coverage Per Sprint
- Every new screen: at least 1 widget test for primary happy path
- Every new validation rule: at least 1 negative test
- Every changed endpoint: contract test update

## CI Quality Gates
- flutter analyze with zero errors in touched code
- flutter test for changed feature module
- backend route tests pass
- lint checks pass

## Test Data Strategy
- Use deterministic fake data for widget tests
- Use provider overrides in tests for API responses
- Avoid dependency on live external providers in tests

## Reliability Targets
- Main branch block on test failures
- Flaky test rate below 2 percent
- Regression escape rate trending down release-over-release

## Immediate Next Additions
- Edit trip and delete trip widget tests
- Duplicate trip provider tests
- Backend contract tests for /api/ai/travel-plan
