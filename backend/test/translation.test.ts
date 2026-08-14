import assert from "node:assert/strict";
import http from "node:http";
import { after, before, test } from "node:test";
import { Express } from "express";
import { createApp } from "../src/app";
import { TokenVerifier } from "../src/auth/auth_middleware";
import { RateLimiter } from "../src/security/rate_limiter";
import { TranslationProvider, TranslationProviderError } from "../src/translation/translation_provider";
import { UnavailableTranslationProvider } from "../src/translation/unavailable_translation_provider";

class FakeProvider implements TranslationProvider {
  constructor(
    private readonly outcome: "success" | "providerUnavailable" | "timeout" | "failure" = "success",
  ) {}

  async translate(request: { text: string; sourceLanguage: string; targetLanguage: string }) {
    if (this.outcome !== "success") {
      throw new TranslationProviderError(
        this.outcome === "failure" ? "translationFailed" : this.outcome,
      );
    }
    return {
      translatedText: `translated:${request.text}`,
      detectedSourceLanguage: request.sourceLanguage === "auto" ? "en" : undefined,
    };
  }
}

class FakeRateLimiter implements RateLimiter {
  constructor(private readonly allowed: boolean) {}

  check() {
    return this.allowed ? { allowed: true } : { allowed: false, retryAfterSeconds: 30 };
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
    createApp({ tokenVerifier: verifier, provider: new FakeProvider() }),
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
    return await fetch(`http://127.0.0.1:${address.port}/translate`, init);
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
    text: "Where is the train station?",
    sourceLanguage: "auto",
    targetLanguage: "it",
    ...overrides,
  });
}

test("missing authorization is unauthorized", async () => {
  const response = await request("/translate", {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: body(),
  });
  assert.equal(response.status, 401);
  assert.deepEqual(await response.json(), { error: { code: "unauthorized" } });
});

test("invalid token is unauthorized", async () => {
  const response = await request("/translate", {
    method: "POST",
    headers: { ...authHeaders, Authorization: "Bearer invalid-token" },
    body: body(),
  });
  assert.equal(response.status, 401);
  assert.deepEqual(await response.json(), { error: { code: "unauthorized" } });
});

test("malformed JSON is invalidRequest", async () => {
  const response = await request("/translate", {
    method: "POST",
    headers: authHeaders,
    body: "{not-json",
  });
  assert.equal(response.status, 400);
  assert.deepEqual(await response.json(), { error: { code: "invalidRequest" } });
});

test("empty text is invalidRequest", async () => {
  const response = await request("/translate", {
    method: "POST",
    headers: authHeaders,
    body: body({ text: "   " }),
  });
  assert.equal(response.status, 400);
  assert.deepEqual(await response.json(), { error: { code: "invalidRequest" } });
});

test("oversized text is requestTooLarge", async () => {
  const response = await request("/translate", {
    method: "POST",
    headers: authHeaders,
    body: body({ text: "x".repeat(5001) }),
  });
  assert.equal(response.status, 413);
  assert.deepEqual(await response.json(), { error: { code: "requestTooLarge" } });
});

test("unsupported languages are rejected", async () => {
  for (const overrides of [
    { sourceLanguage: "xx" },
    { targetLanguage: "xx" },
  ]) {
    const response = await request("/translate", {
      method: "POST",
      headers: authHeaders,
      body: body(overrides),
    });
    assert.equal(response.status, 400);
    assert.deepEqual(await response.json(), { error: { code: "unsupportedLanguage" } });
  }
});

test("explicit same source and target is invalidRequest", async () => {
  const response = await request("/translate", {
    method: "POST",
    headers: authHeaders,
    body: body({ sourceLanguage: "it", targetLanguage: "it" }),
  });
  assert.equal(response.status, 400);
  assert.deepEqual(await response.json(), { error: { code: "invalidRequest" } });
});

test("fake provider success maps detected language", async () => {
  const response = await request("/translate", {
    method: "POST",
    headers: authHeaders,
    body: body(),
  });
  assert.equal(response.status, 200);
  assert.deepEqual(await response.json(), {
    translatedText: "translated:Where is the train station?",
    detectedSourceLanguage: "en",
  });
});

test("unavailable provider returns providerUnavailable without text", async () => {
  const response = await requestWithApp(
    createApp({ tokenVerifier: verifier, provider: new UnavailableTranslationProvider() }),
    { method: "POST", headers: authHeaders, body: body() },
  );
  const payload = await response.json() as Record<string, unknown>;
  assert.equal(response.status, 503);
  assert.deepEqual(payload, { error: { code: "providerUnavailable" } });
  assert.equal(JSON.stringify(payload).includes("Where is the train station?"), false);
  assert.equal(JSON.stringify(payload).includes("valid-token"), false);
});

test("provider timeout maps to timeout", async () => {
  const response = await requestWithApp(
    createApp({ tokenVerifier: verifier, provider: new FakeProvider("timeout") }),
    { method: "POST", headers: authHeaders, body: body() },
  );
  assert.equal(response.status, 504);
  assert.deepEqual(await response.json(), { error: { code: "timeout" } });
});

test("provider failure maps to translationFailed", async () => {
  const response = await requestWithApp(
    createApp({ tokenVerifier: verifier, provider: new FakeProvider("failure") }),
    { method: "POST", headers: authHeaders, body: body() },
  );
  assert.equal(response.status, 503);
  assert.deepEqual(await response.json(), { error: { code: "translationFailed" } });
});

test("rate limiting is public and sanitized", async () => {
  const response = await requestWithApp(
    createApp({ tokenVerifier: verifier, provider: new FakeProvider(), rateLimiter: new FakeRateLimiter(false) }),
    { method: "POST", headers: authHeaders, body: body() },
  );
  assert.equal(response.status, 429);
  assert.equal(response.headers.get("retry-after"), "30");
  assert.deepEqual(await response.json(), { error: { code: "rateLimited" } });
});
