# AI Planner Setup

The backend AI planner endpoint supports two modes:

1. `LLM mode`: used when `OPENAI_API_KEY` is configured.
2. `Fallback mode`: used when no AI provider key is configured or the upstream call fails.

## Environment variables

Create `backend/.env` from `backend/.env.example` and set:

```env
PORT=5000
DUFFEL_API_KEY=your_duffel_api_key_here
OPENAI_API_KEY=your_openai_api_key_here
OPENAI_MODEL=gpt-4o-mini
```

## Variables

- `OPENAI_API_KEY`: enables the backend LLM planner.
- `OPENAI_MODEL`: optional model override. Defaults to `gpt-4o-mini`.
- `DUFFEL_API_KEY`: still required for flight search.

## Run locally

```powershell
cd backend
npm install
node server.js
```

The planner endpoint will be available at:

```text
POST http://localhost:5000/api/ai/travel-plan
```

## Behavior

- If `OPENAI_API_KEY` is present, the backend attempts an LLM-generated itinerary response.
- If the provider is unavailable or the key is missing, the endpoint falls back to the built-in local planner logic.

## Verify

Example request body:

```json
{
  "prompt": "I am travelling to Paris for four days with a budget of £1500",
  "trips": [],
  "flights": [],
  "hotels": [],
  "weather": { "tempC": 22, "description": "Sunny" },
  "nearbyAttractions": ["Eiffel Tower", "Louvre Museum"]
}
```

The response contains:

```json
{
  "prompt": "...",
  "response": "...",
  "source": "llm" | "fallback"
}
```