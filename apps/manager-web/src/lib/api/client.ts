// Fetch wrapper for the NEST API (ARCHITECTURE §7, §32).
//
// - Types come from `schema.d.ts`, generated from apps/api/openapi.json
//   (`npm run gen:api`). Never hand-write API types.
// - The session lives in HttpOnly cookies set by /auth/web/login. Every write sends
//   the `nest_csrf` cookie back as `X-CSRF-Token` (double-submit CSRF).
// - An expired access cookie (401 TOKEN_EXPIRED) is renewed once through
//   /auth/web/refresh, shared by all requests waiting at that moment, and the
//   request is retried. If the refresh fails, `onSessionEnded` runs (→ login page).
// - Errors use the API's {"error": {"code", "message", "details"}} envelope.

import type { components } from "./schema";

export type Schemas = components["schemas"];

export const API_BASE_URL =
  process.env.NEXT_PUBLIC_API_BASE_URL ?? "http://localhost:8000";

const CSRF_COOKIE = "nest_csrf";
const CSRF_HEADER = "X-CSRF-Token";
const SAFE_METHODS = new Set(["GET", "HEAD", "OPTIONS"]);

interface ErrorEnvelope {
  error: { code: string; message: string; details: Record<string, unknown> };
}

export class ApiError extends Error {
  constructor(
    public readonly status: number,
    public readonly code: string,
    message: string,
    public readonly details: Record<string, unknown> = {},
  ) {
    super(message);
    this.name = "ApiError";
  }
}

function isErrorEnvelope(body: unknown): body is ErrorEnvelope {
  return (
    typeof body === "object" &&
    body !== null &&
    "error" in body &&
    typeof (body as ErrorEnvelope).error?.code === "string"
  );
}

function readCookie(name: string): string | null {
  if (typeof document === "undefined") return null;
  const match = document.cookie
    .split("; ")
    .find((part) => part.startsWith(`${name}=`));
  return match ? decodeURIComponent(match.slice(name.length + 1)) : null;
}

let onSessionEnded: (() => void) | null = null;

/** Called by the session provider: where to go when the session can't be renewed. */
export function setSessionEndedHandler(handler: (() => void) | null): void {
  onSessionEnded = handler;
}

let refreshing: Promise<boolean> | null = null;

function refreshOnce(): Promise<boolean> {
  refreshing ??= send("/api/v1/auth/web/refresh", { method: "POST" })
    .then((r) => r.ok)
    .catch(() => false)
    .finally(() => {
      refreshing = null;
    });
  return refreshing;
}

function send(path: string, init: RequestInit): Promise<Response> {
  const method = (init.method ?? "GET").toUpperCase();
  const headers = new Headers(init.headers);
  headers.set("Accept", "application/json");
  if (init.body !== undefined && !headers.has("Content-Type")) {
    headers.set("Content-Type", "application/json");
  }
  const csrf = readCookie(CSRF_COOKIE);
  if (!SAFE_METHODS.has(method) && csrf) headers.set(CSRF_HEADER, csrf);
  return fetch(`${API_BASE_URL}${path}`, {
    ...init,
    method,
    headers,
    credentials: "include",
  });
}

async function parse<T>(response: Response): Promise<T> {
  if (response.status === 204) return undefined as T;
  const body: unknown = await response.json().catch(() => null);
  if (!response.ok) {
    if (isErrorEnvelope(body)) {
      throw new ApiError(
        response.status,
        body.error.code,
        body.error.message,
        body.error.details,
      );
    }
    throw new ApiError(response.status, "UNKNOWN_ERROR", response.statusText);
  }
  return body as T;
}

async function sendWithRefresh(path: string, init: RequestInit): Promise<Response> {
  let response: Response;
  try {
    response = await send(path, init);
  } catch {
    throw new ApiError(0, "NETWORK_ERROR", "No connection to the server.");
  }
  if (response.status === 401 && !path.startsWith("/api/v1/auth/web/")) {
    if (await refreshOnce()) {
      response = await send(path, init);
    } else {
      onSessionEnded?.();
    }
  }
  return response;
}

export async function apiFetch<T>(path: string, init: RequestInit = {}): Promise<T> {
  return parse<T>(await sendWithRefresh(path, init));
}

/** GET a file (e.g. the timesheet CSV) with the session cookies and save it. */
export async function downloadFile(path: string, filename: string): Promise<void> {
  const response = await sendWithRefresh(path, {});
  if (!response.ok) await parse(response); // throws the API error
  const url = URL.createObjectURL(await response.blob());
  const link = document.createElement("a");
  link.href = url;
  link.download = filename;
  link.click();
  URL.revokeObjectURL(url);
}

export const api = {
  get: <T>(path: string) => apiFetch<T>(path),
  post: <T>(path: string, body?: unknown) =>
    apiFetch<T>(path, {
      method: "POST",
      body: body === undefined ? undefined : JSON.stringify(body),
    }),
  put: <T>(path: string, body: unknown) =>
    apiFetch<T>(path, { method: "PUT", body: JSON.stringify(body) }),
  patch: <T>(path: string, body: unknown) =>
    apiFetch<T>(path, { method: "PATCH", body: JSON.stringify(body) }),
  delete: <T>(path: string) => apiFetch<T>(path, { method: "DELETE" }),
};

export function getHealth(): Promise<Schemas["HealthResponse"]> {
  return apiFetch<Schemas["HealthResponse"]>("/health");
}
