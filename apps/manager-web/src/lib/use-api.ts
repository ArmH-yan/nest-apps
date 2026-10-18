"use client";

// Minimal data hook: GET on mount, when `path` changes, and on `reload()`. Enough
// for a desktop admin app with < 20 workers; no client cache library needed
// (CLAUDE.md: simplest). `loading` is derived: true until the response for the
// current path/reload arrives, so the effect never sets state synchronously.

import { useCallback, useEffect, useState } from "react";

import { api } from "@/lib/api/client";

export interface ApiState<T> {
  data: T | undefined;
  error: unknown;
  loading: boolean;
  reload: () => void;
}

interface Result<T> {
  key: string;
  data: T | undefined;
  error: unknown;
}

export function useApi<T>(path: string | null): ApiState<T> {
  const [tick, setTick] = useState(0);
  const key = `${path}#${tick}`;
  const [result, setResult] = useState<Result<T>>({ key: "", data: undefined, error: null });

  useEffect(() => {
    if (path === null) return;
    let active = true;
    api
      .get<T>(path)
      .then((data) => {
        if (active) setResult({ key, data, error: null });
      })
      .catch((error: unknown) => {
        // keep the previous data visible while showing the error
        if (active) setResult((prev) => ({ key, data: prev.data, error }));
      });
    return () => {
      active = false;
    };
  }, [path, key]);

  const reload = useCallback(() => setTick((n) => n + 1), []);
  return {
    data: result.data,
    error: result.error,
    loading: path !== null && result.key !== key,
    reload,
  };
}
