# Deployment

## Branching Strategy
```text
main
 |
 +- develop
 |
 +- feature/auth
 +- feature/flights
 +- feature/hotels
 +- feature/weather
 +- feature/trips
 +- feature/wallet
 +- feature/translator
 +- feature/ai
 +- feature/payments
```

Rules:
- Feature development happens only on feature branches.
- Every feature branch is reviewed and tested before merge to develop.
- Develop is the integration branch for sprint-ready increments.
- Main receives promoted, validated release candidates only.

## Release Flow
1. Build and validate on feature branch.
2. Merge feature branch into develop after review.
3. Run CI checks and sprint sign-off on develop.
4. Promote tested release to main.
5. Tag release version and publish notes.

## CI Baseline
- Architecture check
- Backend checks
- Flutter analyze
- Feature test suites
- Release notes and docs checks for touched scope

## Production Release (3.0)
- Google Play build and submission
- Apple App Store build and submission
- Analytics and crash monitoring enabled
- Performance and security verification completed
- Accessibility review completed
- Privacy policy and terms of service published
