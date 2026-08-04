# Internal Beta Round 1 Test Script

## Objective
Validate Beta Candidate 1 with a small tester cohort and one clear end-to-end journey.

## Cohort
- Target size: 10-20 testers
- Device mix: at least 70% physical Android devices
- Distribution: Google Play Internal Testing build only

## Single Journey For Every Tester
1. Install app
2. Complete onboarding
3. Sign in
4. Create a trip
5. Add flight, hotel, and taxi
6. Use Maps and Nearby
7. Add an expense
8. Ask AI for help
9. Trigger one reminder
10. Sign out and sign back in

## Test Session Rules
- No exploratory feature expansion during this round.
- Focus on completion of the single journey.
- Capture evidence for failures: screenshot, exact step, timestamp, device model.
- If blocked, stop and report immediately.

## Pass Criteria
- Tester can complete the full journey without crash or dead end.
- Core data persists after sign-out/sign-in.
- Permissions prompts appear when needed and are recoverable after deny.

## Failure Signals To Track
- Crashes
- Sign-in failures
- Broken navigation
- Missing permissions
- Incorrect trip data
- Slow or blank screens
- Provider or API failures
- Confusing steps

## Execution Matrix
| Tester | Device | Android Version | Build | Start Time | End Time | Journey Completed | Highest Severity | Notes |
|---|---|---|---|---|---|---|---|---|
| T01 |  |  | BC1 |  |  |  |  |  |
| T02 |  |  | BC1 |  |  |  |  |  |
| T03 |  |  | BC1 |  |  |  |  |  |
| T04 |  |  | BC1 |  |  |  |  |  |
| T05 |  |  | BC1 |  |  |  |  |  |
| T06 |  |  | BC1 |  |  |  |  |  |
| T07 |  |  | BC1 |  |  |  |  |  |
| T08 |  |  | BC1 |  |  |  |  |  |
| T09 |  |  | BC1 |  |  |  |  |  |
| T10 |  |  | BC1 |  |  |  |  |  |

## Required Monitoring During Round
Confirm these are active before inviting testers:
- Crash reporting
- App-level error logging
- Analytics for onboarding, trip creation, and key flows
- Backend and API logs
- Firebase usage and permission monitoring

## Exit Condition For Round 1
- All P0 and P1 issues fixed or rollback decision made
- Targeted tests rerun for changed areas
- Full regression executed
- Beta Candidate 2 build produced
- Expansion plan to 30-50 testers approved
