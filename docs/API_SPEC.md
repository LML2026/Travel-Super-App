# Backend API Specification

Base URL:
- Local: http://localhost:5000

## Authentication
Authentication behavior:
- Production default: bearer auth enabled (`AUTH_REQUIRED=true`) for configured protected routes.
- Default protected route prefixes: `/api/flights`, `/api/hotels`, `/api/ai`.
- Override protected routes with `AUTH_PROTECTED_PATHS` (comma-separated prefixes).
- Global toggle for local/dev workflows: `AUTH_REQUIRED=false`.

When auth is required, send `Authorization: Bearer <Firebase ID token>`.

## Error Format
Common error payload:
- error: string
- details: string or object (optional)

## Endpoints

### POST /api/flights/search
Search flight offers.

Request body:
- origin: string (IATA)
- destination: string (IATA)
- departureDate: string (YYYY-MM-DD)
- returnDate: string optional
- passengers: number optional, default 1
- cabinClass: string optional, default economy

Success 200:
- flights: array
- totalFound: number
- cached: boolean

Validation/other:
- 422 Invalid search parameters
- 500 Provider or parsing error

### GET /api/weather
Retrieve weather for city.

Query params:
- city: string required

Success 200:
- city: string
- country: string
- tempC: number
- tempF: number
- description: string
- iconCode: string
- humidity: number
- windKph: number
- condition: string

Errors:
- 400 city is required
- 404 city not found
- 500 upstream weather failure

### GET /api/hotels/search
Search hotels with query params.

Query params:
- destination: string required
- checkIn: string required (YYYY-MM-DD)
- checkOut: string required (YYYY-MM-DD)
- guests: number optional, default 1
- rooms: number optional, default 1

Success 200:
- city: string
- checkInDate: string
- checkOutDate: string
- guests: number
- rooms: number
- hotels: array
- count: number

Notes:
- Route maps query params into internal hotel search request.

### GET /api/places/nearby
Get nearby attractions, restaurants, and transport.

Query params:
- city: string required
- category: string optional (attractions | restaurants | transport)

Success 200 (no category):
- city: string
- attractions: array
- restaurants: array
- transport: array

Success 200 (category):
- city: string
- category: string
- places: array

Errors:
- 400 city missing
- 400 invalid category

### GET /api/currency/rate
Get conversion rate.

Query params:
- base: string optional, default GBP
- target: string optional, default EUR

Success 200:
- base: string
- target: string
- rate: number

Errors:
- 404 rate not found
- 500 provider failure

### POST /api/ai/travel-plan
Generate travel planning advice.

Request body:
- prompt: string required
- trips: array optional
- flights: array optional
- hotels: array optional
- weather: object optional
- nearbyAttractions: array optional

Success 200:
- prompt: string
- response: string
- source: string (llm or fallback)

Errors:
- 400 prompt is required
- 500 only for unexpected route-level failures; normal provider failures fall back to local planner

## Route Defaults
- 404 returns route not found payload with method and path.
- 500 returns internal server error with details when available.

## Runtime Environment Variables
- `PORT` (default `5000`)
- `NODE_ENV` (`development` or `production`)
- `CORS_ALLOWED_ORIGINS` (required in production; comma-separated)
- `AUTH_REQUIRED` (optional; defaults to `true` in production)
- `AUTH_PROTECTED_PATHS` (optional; comma-separated route prefixes)
- `FIREBASE_PROJECT_ID` or `GOOGLE_CLOUD_PROJECT` (recommended for token verification context)
- `DUFFEL_API_KEY` (required for flights)
- `OPENAI_API_KEY` (optional; AI falls back locally when absent)
- `OPENAI_MODEL` (optional; default `gpt-4o-mini`)
- `RATE_LIMIT_WINDOW_MS` (optional; default 900000)
- `RATE_LIMIT_MAX` (optional; default 120)

## Next API Hardening Steps
- Add OpenAPI 3.1 schema and generated validators.
- Add request IDs and structured logging.
- Add contract tests for every endpoint.
