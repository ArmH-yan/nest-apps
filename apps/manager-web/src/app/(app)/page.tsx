"use client";

// Dashboard (ARCHITECTURE §13), first slice: today's crews and jobs without a crew.
// Live per-worker state and flagged timesheets come with the timesheet module.

import Link from "next/link";

import { Empty, ErrorBox, Loading, PageHeader, StatusBadge } from "@/components/ui";
import type { Schemas } from "@/lib/api/client";
import { formatDate, formatTime, yerevanDate, yerevanInstant } from "@/lib/format";
import { useI18n } from "@/lib/i18n";
import type { MessageKey } from "@/lib/i18n/en";
import { useApi } from "@/lib/use-api";

type Entry = Schemas["ScheduleEntryOut"];
type JobItem = Schemas["JobListItemOut"];

export default function Dashboard() {
  const { t } = useI18n();
  const today = yerevanDate();
  const from = encodeURIComponent(yerevanInstant(today, "00:00"));
  const to = encodeURIComponent(yerevanInstant(today, "23:59"));
  const schedule = useApi<Entry[]>(`/api/v1/schedule?from=${from}&to=${to}`);
  const drafts = useApi<JobItem[]>("/api/v1/jobs?status=DRAFT&limit=50");

  const visits = new Map<number, Entry[]>();
  for (const e of schedule.data ?? []) {
    visits.set(e.visit_id, [...(visits.get(e.visit_id) ?? []), e]);
  }

  return (
    <div className="stack">
      <PageHeader title={`${t("dashboard.title")} · ${formatDate(new Date().toISOString())}`} />

      <section className="card stack">
        <h2>{t("dashboard.todayVisits")}</h2>
        <ErrorBox error={schedule.error} />
        {schedule.loading && !schedule.data ? (
          <Loading />
        ) : visits.size === 0 ? (
          <Empty text={t("dashboard.noVisits")} />
        ) : (
          <table className="list">
            <thead>
              <tr>
                <th>{t("jobs.start")}</th>
                <th>{t("jobs.jobTitle")}</th>
                <th>{t("jobs.crew")}</th>
              </tr>
            </thead>
            <tbody>
              {[...visits.values()].map((crew) => {
                const first = crew[0];
                return (
                  <tr key={first.visit_id}>
                    <td>
                      {formatTime(first.starts_at)} – {formatTime(first.ends_at)}
                    </td>
                    <td>
                      <Link href={`/jobs/${first.job_id}`}>{first.job_title}</Link>
                      <div className="muted small">{t(`jobType.${first.job_type}` as MessageKey)}</div>
                    </td>
                    <td>
                      <div className="row" style={{ gap: 6 }}>
                        {crew.map((m) => (
                          <span key={m.assignment_id} className="row" style={{ gap: 4 }}>
                            {m.role === "LEAD" ? "★ " : ""}
                            {m.worker_name}
                            <StatusBadge
                              status={m.status}
                              label={t(`assignmentStatus.${m.status}` as MessageKey)}
                            />
                          </span>
                        ))}
                      </div>
                    </td>
                  </tr>
                );
              })}
            </tbody>
          </table>
        )}
      </section>

      <section className="card stack">
        <h2>{t("dashboard.unstaffed")}</h2>
        <ErrorBox error={drafts.error} />
        {drafts.loading && !drafts.data ? (
          <Loading />
        ) : drafts.data?.length ? (
          <ul className="stack" style={{ gap: 8, listStyle: "none" }}>
            {drafts.data.map((j) => (
              <li key={j.id}>
                <Link href={`/jobs/${j.id}`}>{j.title}</Link>{" "}
                <span className="muted small">
                  {j.project_name} · {j.site_name}
                </span>
              </li>
            ))}
          </ul>
        ) : (
          <Empty text={t("dashboard.noUnstaffed")} />
        )}
      </section>
    </div>
  );
}
