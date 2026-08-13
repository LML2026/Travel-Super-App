# ITAREVO Agent Instructions

## Project
ITAREVO is an existing Flutter travel super-app. Preserve all working functionality.

## Safety
- Never expose, print, paste, log, or commit API keys, tokens, passwords, secrets, or credentials.
- Treat Google Maps/Places keys as sensitive even when browser-visible.
- Never delete working functionality merely to resolve an error.
- Never run git reset --hard, git clean, destructive filesystem commands, or force-push.
- Never push to a remote unless explicitly instructed.
- Ask before major architecture changes, dependency replacements, migrations, or security configuration changes.

## Working method
- Inspect relevant existing code before editing.
- Prefer focused, reversible changes.
- Preserve existing public behavior unless the task explicitly changes it.
- Avoid broad search-and-replace operations that could corrupt Dart files.
- Do not use line-deduplication or similar transformations on source code.
- Reuse existing services, models, screens, and patterns where reasonable.
- Keep Flutter code readable and maintainable.

## Validation
After code changes:
1. Run dart format on modified Dart files.
2. Run flutter analyze.
3. Run relevant tests when available.
4. Inspect git diff.
5. Do not claim success if validation failed.
6. If local Codex sandbox permissions prevent Flutter commands from completing, report that clearly instead of modifying unrelated files to work around it.

## Git
- Do not commit unless explicitly instructed.
- Before committing, ensure the intended diff is understood.
- Never include temporary files such as web/index1.txt, web/index2.txt, etc.
- Do not alter Git history without explicit approval.

## Current ITAREVO priorities
- Preserve Trips CRUD and SharedPreferences persistence.
- Preserve day-by-day itinerary CRUD and persistence.
- Preserve Google Places location search.
- Preserve interactive itinerary Google Maps.
- Preserve Nearby Essentials.
- Finance, flights, hotels, translator, wallet, and AI features may currently be placeholders; do not pretend they are implemented.

## API/location behavior
- Users should search for place names; latitude/longitude should normally remain internal implementation details.
- Nearby search and map features must degrade gracefully when a location is unavailable.
- Do not change Google Cloud API restrictions or billing configuration from code.

## Testing
- Replace obsolete template tests over time with meaningful ITAREVO tests.
- Add tests for new logic where practical.
