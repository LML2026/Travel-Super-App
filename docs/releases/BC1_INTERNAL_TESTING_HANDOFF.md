# BC1 Internal Testing Handoff

Date: 2026-08-06
Status: Signed AAB ready for Play Internal Testing

## Signed Artifact

- File: build/app/outputs/bundle/release/app-release.aab
- Size: 59.2 MB (build output)
- SHA-256: B7F806402F571BA62843238FE26CE9272BEFAB53CD0EE54974DC9AE93657B9DD

Execution status:
- Step 1 (Create release + upload AAB): Pending external execution
- Step 2 (Add testers + install from Play): Pending external execution
- Step 3 (Production smoke journey): Pending external execution
- Step 4 (Production integrations verification): Pending external execution

## Steps 1-4 Execution Checklist

### 1) Create Internal Testing Release and Upload AAB

- Play Console -> Testing -> Internal testing -> Create release
- Upload: build/app/outputs/bundle/release/app-release.aab
- Blockers to resolve now: policy/declaration issues that block rollout
- Non-blocking recommendations: defer unless rollout is blocked

Pass criteria:
- Internal release created
- AAB accepted
- No blocking errors remain

### 2) Add Testers and Install from Play

- Add your own Google account
- Add a small tester group (3-10 trusted testers)
- Roll out internal release
- Install only from Play Store opt-in flow (not flutter run)

Pass criteria:
- App appears in Play internal track for tester accounts
- App installs successfully from Play Store

### 3) Final Production Smoke Journey

Run exactly once on Play-installed build:

Fresh install -> onboarding -> login -> Home
-> create trip -> flight -> hotel -> taxi
-> Maps/Nearby -> expense/budget
-> AI -> notification -> logout/login

Pass criteria:
- No crash
- No journey-blocking failure

### 4) Verify Production Integrations on Play Build

Validate in-app and server-side evidence:

- Firebase Auth/Firestore writes and reads in production project
- Maps + location permissions behavior
- AI/backend request success and error handling
- Notifications permission + delivery
- Crash reporting receives at least one controlled non-fatal or test signal

Pass criteria:
- All integrations functional for core flow
- Evidence captured in Firebase/monitoring dashboards

## Decision Gate

If all pass: mark BC1 DISTRIBUTED and invite first beta testers.

Post-gate rule:
- Fix only crashes, security/data issues, and journey-blocking bugs.
- Route all other requests to Version 1.1 backlog.
