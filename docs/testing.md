# Testing

## Engineering Standards

Each feature should align with:
- Clean Architecture
- Riverpod state management
- Repository pattern
- Reusable widgets
- Code documentation for key flows and contracts

## Required Test Types
- Unit tests
- Widget tests
- Integration tests (as feature scope grows)
- Backend endpoint/contract tests

## Feature Completion Checklist
For each feature, include:
- Flutter UI
- Models
- Repository
- Services
- Riverpod providers
- Backend API
- Input validation and error handling checks
- Firestore schema updates (if needed)
- Unit tests
- Widget tests
- Integration tests for cross-module behavior when applicable
- Documentation

## Sprint Deliverable Pack

Every sprint-ready feature should include:
1. Architecture fit statement.
2. Backend implementation and validation.
3. Flutter implementation (models, providers, screens, widgets).
4. Tests for feature scope.
5. Stable git checkpoint.

## Quality Gates
- flutter analyze passes
- relevant flutter test suites pass
- architecture checks pass
- backend syntax/route checks pass

## Cross-Reference
- Detailed testing strategy: TESTING_STRATEGY.md
