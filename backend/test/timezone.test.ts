import assert from "node:assert/strict";
import http from "node:http";
import { after, before, test } from "node:test";
import { Express } from "express";
import { createApp } from "../src/app";
import { TokenVerifier } from "../src/auth/auth_middleware";
import {
  GoogleTimezoneHttpClient,
  GoogleTimezoneProvider,
} from "../src/timezone/google_timezone_provider";
import { createConfiguredTimezoneProvider } from "../src/timezone/timezone_provider_factory";
import { TimezoneProvider, TimezoneProviderError } from "../src/timezone/timezone_provider";

class FakeTimezoneProvider implements TimezoneProvider {
  constructor(private readonly outcome: "success" | "unavailable" = "success") {}

  async resolve() {
    if (this.outcome === "unavailable") {
      throw new TimezoneProviderError("providerUnavailable");
    }
    return { timezoneId: "Asia/Tokyo" };
  }
}

const verifier: TokenVerifier = {
  async verifyIdToken(token) {
    if (token !== "valid-token") throw new Error("invalid token");
    return { uid: "verified-user" };
  },
};

let baseUrl: string;
let server: http.Server;

before(async () => {
  server = http.createServer(
    createApp({ tokenVerifier: verifier, timezoneProvider: new FakeTimezoneProvider() }),
  );
  await new Promise<void>((resolve) => server.listen(0, resolve));
  const address = server.address();
  if (!address || typeof address === "string") throw new Error("server did not start");
  baseUrl = `http://127.0.0.1:${address.port}`;
});

after(async () => {
  await new Promise<void>((resolve, reject) => server.close((error) => error ? reject(error) : resolve()));
});

async function request(path: string, init: RequestInit = {}) {
  return fetch(`${baseUrl}${path}`, init);
}

async function requestWithApp(app: Express, init: RequestInit) {
  const temporaryServer = http.createServer(app);
  await new Promise<void>((resolve) => temporaryServer.listen(0, resolve));
  const address = temporaryServer.address();
  if (!address || typeof address === "string") throw new Error("server did not start");
  try {
    return await fetch(`http://127.0.0.1:${address.port}/timezone`, init);
  } finally {
    await new Promise<void>((resolve, reject) => temporaryServer.close((error) => error ? reject(error) : resolve()));
  }
}

const authHeaders = {
  Authorization: "Bearer valid-token",
  "Content-Type": "application/json",
};

function body(overrides: Record<string, unknown> = {}) {
  return JSON.stringify({
    latitude: 35.6762,
    longitude: 139.6503,
    timestamp: 1_723_729_600,
    ...overrides,
  });
}

test("timezone endpoint requires Firebase authentication", async () => {
  const response = await request("/timezone", {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: body(),
  });

  assert.equal(response.status, 401);
  assert.deepEqual(await response.json(), { error: { code: "unauthorized" } });
});

test("timezone endpoint validates coordinates and Unix-second timestamp", async () => {
  for (const overrides of [
    { latitude: 91 },
    { longitude: 181 },
    { timestamp: -1 },
    { timestamp: 1.5 },
    { timestamp: 1_700_000_000_000 },
    { destination: "Tokyo" },
  ]) {
    const response = await request("/timezone", {
      method: "POST",
      headers: authHeaders,
      body: body(overrides),
    });
    assert.equal(response.status, 400);
    assert.deepEqual(await response.json(), { error: { code: "invalidRequest" } });
  }
});

test("timezone endpoint normalizes successful provider result", async () => {
  const response = await request("/timezone", {
    method: "POST",
    headers: authHeaders,
    body: body(),
  });
  const payload = await response.json() as Record<string, unknown>;

  assert.equal(response.status, 200);
  assert.equal(payload.timezoneId, "Asia/Tokyo");
  assert.equal(payload.status, "resolved");
  assert.equal(payload.source, "authoritativeProvider");
  assert.equal(payload.confidence, "confirmed");
  assert.deepEqual(payload.coordinateEvidence, { latitude: 35.6762, longitude: 139.6503 });
  assert.equal("apiKey" in payload, false);
  assert.equal("rawOffset" in payload, false);
  assert.equal("dstOffset" in payload, false);
});

test("provider unavailability is sanitized", async () => {
  const response = await requestWithApp(
    createApp({ tokenVerifier: verifier, timezoneProvider: new FakeTimezoneProvider("unavailable") }),
    { method: "POST", headers: authHeaders, body: body() },
  );
  const payload = await response.json() as Record<string, unknown>;

  assert.equal(response.status, 503);
  assert.deepEqual(payload, { error: { code: "providerUnavailable" } });
  assert.equal(JSON.stringify(payload).includes("valid-token"), false);
  assert.equal(JSON.stringify(payload).includes("private"), false);
});

test("health endpoints remain public and unchanged", async () => {
  for (const path of ["/health", "/healthz"]) {
    const response = await request(path);
    assert.equal(response.status, 200);
    assert.deepEqual(await response.json(), { status: "ok" });
  }
});

test("Google adapter preserves IANA ID and request timestamp without leaking key", async () => {
  let capturedUrl: URL | undefined;
  const client: GoogleTimezoneHttpClient = {
    async fetch(input) {
      capturedUrl = new URL(String(input));
      return new Response(JSON.stringify({ status: "OK", timeZoneId: "Asia/Tokyo" }), { status: 200 });
    },
  };
  const provider = new GoogleTimezoneProvider({ apiKey: "test-only-key", client });

  const result = await provider.resolve({ latitude: 35.6762, longitude: 139.6503, timestamp: 1_723_729_600 });

  assert.equal(result.timezoneId, "Asia/Tokyo");
  assert.equal(capturedUrl?.searchParams.get("location"), "35.6762,139.6503");
  assert.equal(capturedUrl?.searchParams.get("timestamp"), "1723729600");
});

test("Google adapter normalizes malformed and network failures", async () => {
  for (const client of [
    { async fetch() { return new Response("{}", { status: 200 }); } },
    {
      async fetch() {
        return new Response(
          JSON.stringify({ status: "OVER_QUERY_LIMIT", timeZoneId: "Asia/Tokyo" }),
          { status: 200 },
        );
      },
    },
    { async fetch() { throw new Error("private provider failure"); } },
  ] satisfies GoogleTimezoneHttpClient[]) {
    const provider = new GoogleTimezoneProvider({ apiKey: "test-only-key", client });
    await assert.rejects(
      provider.resolve({ latitude: 35.6762, longitude: 139.6503, timestamp: 1_723_729_600 }),
      (error: unknown) => error instanceof TimezoneProviderError && error.kind === "providerUnavailable",
    );
  }
});

test("timezone provider is unavailable when server configuration is absent", async () => {
  const provider = createConfiguredTimezoneProvider({});
  await assert.rejects(
    provider.resolve({ latitude: 35.6762, longitude: 139.6503, timestamp: 1_723_729_600 }),
    (error: unknown) => error instanceof TimezoneProviderError && error.kind === "providerUnavailable",
  );
});
