"use client";

import Link from "next/link";
import { usePathname, useRouter } from "next/navigation";
import { useEffect, type ReactNode } from "react";

import { Loading } from "@/components/ui";
import type { Schemas } from "@/lib/api/client";
import { isLocale, LOCALE_NAMES, LOCALES, useI18n } from "@/lib/i18n";
import type { MessageKey } from "@/lib/i18n/en";
import { useSession } from "@/lib/session";
import { useApi } from "@/lib/use-api";

const NAV: { href: string; label: MessageKey }[] = [
  { href: "/", label: "nav.dashboard" },
  { href: "/requests", label: "nav.requests" },
  { href: "/planning", label: "nav.planning" },
  { href: "/jobs", label: "nav.jobs" },
  { href: "/timesheets", label: "nav.timesheets" },
  { href: "/projects", label: "nav.projects" },
  { href: "/sites", label: "nav.sites" },
  { href: "/companies", label: "nav.companies" },
  { href: "/workers", label: "nav.workers" },
];

export function AppShell({ children }: { children: ReactNode }) {
  const { me, loading, logout } = useSession();
  const { t, locale, setLocale } = useI18n();
  const pathname = usePathname();
  const router = useRouter();

  useEffect(() => {
    if (!loading && !me) router.replace("/login");
  }, [loading, me, router]);

  if (loading || !me) {
    return (
      <main className="login-wrap">
        <Loading />
      </main>
    );
  }

  const active = (href: string) => (href === "/" ? pathname === "/" : pathname.startsWith(href));

  return (
    <div className="shell">
      <aside className="sidebar">
        <div className="brand">
          <span className="brand-mark">N</span>
          {t("app.name")}
        </div>
        <nav className="stack" style={{ gap: 2 }}>
          {NAV.map((item) => (
            <Link
              key={item.href}
              href={item.href}
              className={`nav-link${active(item.href) ? " active" : ""}`}
            >
              {t(item.label)}
              {item.href === "/requests" && <NewRequestsBadge />}
            </Link>
          ))}
        </nav>
        <div className="sidebar-footer">
          <span>{me.full_name}</span>
          <select
            aria-label={t("nav.language")}
            value={locale}
            onChange={(e) => isLocale(e.target.value) && setLocale(e.target.value)}
          >
            {LOCALES.map((l) => (
              <option key={l} value={l}>
                {LOCALE_NAMES[l]}
              </option>
            ))}
          </select>
          <button className="btn" type="button" onClick={() => void logout()}>
            {t("nav.logout")}
          </button>
        </div>
      </aside>
      <main className="main">{children}</main>
    </div>
  );
}

/** Manager alert for new website/phone leads (ARCHITECTURE §41 Phase 4): the
 * count of NEW requests, refreshed every minute. */
function NewRequestsBadge() {
  const counts = useApi<Schemas["RequestCountsOut"]>("/api/v1/assessment-requests/counts");
  const { reload } = counts;
  useEffect(() => {
    const timer = window.setInterval(reload, 60_000);
    return () => window.clearInterval(timer);
  }, [reload]);
  const n = counts.data?.new ?? 0;
  return n > 0 ? <span className="nav-badge">{n}</span> : null;
}
