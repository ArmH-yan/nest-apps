"use client";

// Tiny i18n: three dictionaries, a provider and `useI18n()`. The language follows the
// signed-in user's locale, can be switched in the sidebar, and is remembered in
// localStorage. Missing keys can't happen: hy/ru are typed against en.

import {
  createContext,
  useCallback,
  useContext,
  useEffect,
  useMemo,
  useSyncExternalStore,
  type ReactNode,
} from "react";

import { ApiError } from "@/lib/api/client";

import { en, type MessageKey } from "./en";
import { hy } from "./hy";
import { ru } from "./ru";

export const LOCALES = ["hy", "ru", "en"] as const;
export type Locale = (typeof LOCALES)[number];
export const LOCALE_NAMES: Record<Locale, string> = { hy: "Հայերեն", ru: "Русский", en: "English" };

const DICTS = { hy, ru, en } as const;
const STORAGE_KEY = "nest.locale";

type T = (key: MessageKey, params?: Record<string, string | number>) => string;

interface I18n {
  locale: Locale;
  setLocale: (locale: Locale) => void;
  t: T;
  /** Localized message for an API error (stable codes, ARCHITECTURE §32). */
  errorText: (error: unknown) => string;
}

const I18nContext = createContext<I18n | null>(null);

export function isLocale(value: unknown): value is Locale {
  return typeof value === "string" && (LOCALES as readonly string[]).includes(value);
}

// The chosen language lives in localStorage (an external store). The server and the
// first client render both see "hy"; useSyncExternalStore then switches to the
// stored choice without a hydration mismatch.
const listeners = new Set<() => void>();

let overrideLocale: Locale | null = null;

function storedLocale(): Locale {
  if (overrideLocale) return overrideLocale;
  try {
    const stored = window.localStorage.getItem(STORAGE_KEY);
    if (isLocale(stored)) return stored;
  } catch {
    // storage blocked: fall through
  }
  const browser = navigator.language.slice(0, 2);
  return isLocale(browser) ? browser : "hy";
}

function subscribe(listener: () => void): () => void {
  listeners.add(listener);
  window.addEventListener("storage", listener);
  return () => {
    listeners.delete(listener);
    window.removeEventListener("storage", listener);
  };
}

export function I18nProvider({ children }: { children: ReactNode }) {
  const locale = useSyncExternalStore(subscribe, storedLocale, () => "hy" as Locale);

  useEffect(() => {
    document.documentElement.lang = locale;
  }, [locale]);

  const setLocale = useCallback((next: Locale) => {
    try {
      window.localStorage.setItem(STORAGE_KEY, next);
    } catch {
      // not remembered across reloads; still switch now
    }
    overrideLocale = next;
    listeners.forEach((l) => l());
  }, []);

  const value = useMemo<I18n>(() => {
    const dict = DICTS[locale];
    const t: T = (key, params) => {
      let text: string = dict[key] ?? en[key] ?? key;
      if (params) {
        for (const [name, v] of Object.entries(params)) text = text.replaceAll(`{${name}}`, String(v));
      }
      return text;
    };
    const errorText = (error: unknown): string => {
      if (error instanceof ApiError) {
        if (error.code === "NETWORK_ERROR") return t("error.network");
        const key = `error.${error.code}` as MessageKey;
        if (key in dict) return t(key);
        return error.message || t("error.generic");
      }
      return t("error.generic");
    };
    return { locale, setLocale, t, errorText };
  }, [locale, setLocale]);

  return <I18nContext.Provider value={value}>{children}</I18nContext.Provider>;
}

export function useI18n(): I18n {
  const ctx = useContext(I18nContext);
  if (!ctx) throw new Error("useI18n outside I18nProvider");
  return ctx;
}
