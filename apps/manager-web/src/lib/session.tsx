"use client";

// The signed-in manager. `GET /me` with the session cookie decides: a 401 that the
// API client can't renew means signed out. Login/logout go through /auth/web/*.

import { useRouter } from "next/navigation";
import {
  createContext,
  useCallback,
  useContext,
  useEffect,
  useMemo,
  useState,
  type ReactNode,
} from "react";

import { api, ApiError, setSessionEndedHandler, type Schemas } from "@/lib/api/client";
import { isLocale, useI18n } from "@/lib/i18n";

type Me = Schemas["MeResponse"];

interface Session {
  me: Me | null;
  loading: boolean;
  login: (phone: string, password: string) => Promise<void>;
  logout: () => Promise<void>;
}

const SessionContext = createContext<Session | null>(null);

export function SessionProvider({ children }: { children: ReactNode }) {
  const router = useRouter();
  const { setLocale } = useI18n();
  const [me, setMe] = useState<Me | null>(null);
  const [loading, setLoading] = useState(true);

  const signedOut = useCallback(() => {
    setMe(null);
    router.replace("/login");
  }, [router]);

  useEffect(() => {
    setSessionEndedHandler(signedOut);
    let active = true;
    api
      .get<Me>("/api/v1/me")
      .then((user) => {
        if (active) setMe(user);
      })
      .catch((e: unknown) => {
        if (!(e instanceof ApiError) || e.status !== 401) console.error(e);
      })
      .finally(() => {
        if (active) setLoading(false);
      });
    return () => {
      active = false;
      setSessionEndedHandler(null);
    };
  }, [signedOut]);

  const login = useCallback(
    async (phone: string, password: string) => {
      const user = await api.post<Me>("/api/v1/auth/web/login", { phone, password });
      setMe(user);
      if (isLocale(user.locale)) setLocale(user.locale);
      router.replace("/");
    },
    [router, setLocale],
  );

  const logout = useCallback(async () => {
    try {
      await api.post("/api/v1/auth/web/logout");
    } finally {
      signedOut();
    }
  }, [signedOut]);

  const value = useMemo(() => ({ me, loading, login, logout }), [me, loading, login, logout]);
  return <SessionContext.Provider value={value}>{children}</SessionContext.Provider>;
}

export function useSession(): Session {
  const ctx = useContext(SessionContext);
  if (!ctx) throw new Error("useSession outside SessionProvider");
  return ctx;
}
