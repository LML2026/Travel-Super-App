# Setup

## Prerequisites
- Flutter SDK
- Node.js (LTS)
- Firebase project configuration

## App Setup
1. Install Flutter dependencies.
2. Configure Firebase options for target platforms.
3. Run app: flutter run

## Backend Setup
1. cd backend
2. npm install
3. configure .env values (DUFFEL_API_KEY, OPENAI_API_KEY optional)
4. node server.js

## Recommended Validation
- From repository root: node tools/check-architecture.mjs
- Flutter static checks: flutter analyze
- Feature tests: flutter test test/features/trips

## Notes
- AI planner supports fallback mode when no provider key is configured.
