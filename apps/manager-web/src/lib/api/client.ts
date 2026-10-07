// Thin fetch wrapper for the NEST API.
//
// - Types come from `schema.d.ts`, generated from FastAPI's OpenAPI (`npm run gen:api`).
//   Never hand-write API types.
// - `credentials: "include"` sends the HttpOnly session cookies (ARCHITECTURE §7).
//   Login, refresh and CSRF handling are added with the auth module.
// - Errors use the API's {"error": {"code", "message", "details"}} envelope.

import type { components } from "./schema";

export type Schemas = components["schemas"];

export const API_BASE_URL =
  process.env.NEXT_PUBLIC_API_BASE_URL ?? "http://localhost:8000";

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

export async function apiFetch<T>(path: string, init: RequestInit = {}): Promise<T> {
  const response = await fetch(`${API_BASE_URL}${path}`, {
    ...init,
    credentials: "include",
    headers: { Accept: "application/json", ...init.headers },
  });

  const body: unknown = await response.json().catch(() => null);

  if (!response.ok) {
    if (isErrorEnvelope(body)) {
      throw new ApiError(response.status, body.error.code, body.error.message, body.error.details);
    }
    throw new ApiError(response.status, "UNKNOWN_ERROR", response.statusText);
  }
  return body as T;
}

export function getHealth(): Promise<Schemas["HealthResponse"]> {
  return apiFetch<Schemas["HealthResponse"]>("/health");
}
