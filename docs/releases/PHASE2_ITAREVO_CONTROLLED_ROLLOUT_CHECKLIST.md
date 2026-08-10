# Phase 2 ITAREVO Controlled Rollout Checklist

## Scope
This phase updates release and store-facing branding metadata in a controlled step without changing technical runtime identifiers.

## Must Stay Unchanged in Phase 2
- Flutter package name in pubspec.
- Dart package/import paths.
- Android applicationId and namespace.
- iOS bundle identifiers.
- Firebase project/app IDs.
- Signing configuration and keystore wiring.

## Planned Updates
1. Store metadata naming alignment.
- Google Play listing app name and copy.
- App Store Connect app display metadata.

2. Public policy/support branding alignment.
- Privacy, terms, support site text branding.
- URL slug migration only if redirect strategy is ready.

3. Release document alignment.
- Operational runbooks and templates that show public-facing brand text.

## Validation Gates
1. Identity lock check.
- Verify applicationId, bundle ID, and Firebase IDs are identical pre/post change.

2. Build and test check.
- flutter test
- flutter analyze
- Android release build smoke (no upload yet)

3. Store readiness check.
- Confirm screenshots, listing text, and support links are consistent.

## Evidence to Capture
- Before/after screenshots of store metadata.
- Diff bundle proving no identifier changes.
- CI run links for tests and analyze.
- Updated release gate note with reviewer sign-off.

## Exit Criteria
- Branding aligned for store/public metadata.
- No technical identifiers changed.
- CI quality checks green.
- Ready for next release-gate operational actions.
