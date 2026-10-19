"use client";

// Company "Info" (ARCHITECTURE §13a): what NEST did for this customer over a window
// (default: the last 12 months): projects, jobs, visits, crew hours and pay, materials,
// month by month, plus the raw list of jobs and a CSV.

import Link from "next/link";
import { useParams } from "next/navigation";
import { useState } from "react";

import { ErrorBox, Field, Loading, StatTile, StatusBadge } from "@/components/ui";
import { downloadFile, type Schemas } from "@/lib/api/client";
import { formatDate, formatDuration, formatMoney } from "@/lib/format";
import { useI18n } from "@/lib/i18n";
import type { MessageKey } from "@/lib/i18n/en";
import { useApi } from "@/lib/use-api";

type Info = Schemas["CompanyInsightsOut"];
type JobRow = Schemas["CompanyJobRowOut"];

export default function CompanyInfoPage() {
  const { id } = useParams<{ id: string }>();
  const { t } = useI18n();
  const [from, setFrom] = useState("");
  const [to, setTo] = useState("");
  const [raw, setRaw] = useState(false);
  const [error, setError] = useState<unknown>(null);
  const range = new URLSearchParams();
  if (from) range.set("from", from);
  if (to) range.set("to", to);
  const qs = range.toString() ? `?${range.toString()}` : "";
  const info = useApi<Info>(`/api/v1/insights/companies/${id}${qs}`);
  const jobs = useApi<JobRow[]>(raw ? `/api/v1/insights/companies/${id}/jobs${qs}` : null);

  if (info.loading && !info.data) return <Loading />;
  if (!info.data) return <ErrorBox error={info.error} />;
  const d = info.data;

  async function exportCsv() {
    setError(null);
    try {
      await downloadFile(
        `/api/v1/insights/companies/${id}/jobs.csv${qs}`,
        `nest-company-${d.company_id}-${d.period_start}-${d.period_end}.csv`,
      );
    } catch (err) {
      setError(err);
    }
  }

  return (
    <div className="stack">
      <div>
        <Link href="/companies" className="muted small">
          ← {t("companies.title")}
        </Link>
        <div className="page-header" style={{ marginTop: 6 }}>
          <div>
            <h1>{d.company_name}</h1>
            <p className="muted">
              {t("info.period", {
                from: formatDate(`${d.period_start}T12:00:00Z`),
                to: formatDate(`${d.period_end}T12:00:00Z`),
              })}
            </p>
          </div>
          <div className="row">
            <button className="btn" onClick={() => setRaw((v) => !v)}>
              {raw ? t("info.hideRaw") : t("info.raw")}
            </button>
            <button className="btn" onClick={() => void exportCsv()}>
              {t("info.exportCsv")}
            </button>
          </div>
        </div>
      </div>

      <div className="card row" style={{ alignItems: "end" }}>
        <Field label={t("ts.from")}>
          <input type="date" value={from || d.period_start} onChange={(e) => setFrom(e.target.value)} />
        </Field>
        <Field label={t("ts.to")}>
          <input type="date" value={to || d.period_end} onChange={(e) => setTo(e.target.value)} />
        </Field>
      </div>

      <ErrorBox error={error ?? info.error} />

      <div className="stats">
        <StatTile label={t("info.projects")} value={d.projects} hint={t("info.sites", { n: d.sites })} />
        <StatTile label={t("info.visitsDone")} value={d.visits_done} />
        <StatTile label={t("info.tasksDone")} value={d.tasks_submitted} />
        <StatTile label={t("info.workerHours")} value={formatDuration(d.work_seconds)} />
        <StatTile label={t("info.meanVisit")} value={formatDuration(d.mean_work_seconds_per_visit)} hint={t("info.workerHoursHint")} />
        <StatTile label={t("info.crewPay")} value={formatMoney(d.crew_pay)} hint={t("info.crewPayHint")} />
        <StatTile
          label={t("info.lastVisit")}
          value={d.last_visit_at ? formatDate(d.last_visit_at) : t("common.none")}
          hint={d.first_visit_at ? t("info.firstTask", { date: formatDate(d.first_visit_at) }) : undefined}
        />
      </div>

      <div className="grid-2">
        <section className="card stack" style={{ gap: 8 }}>
          <h2>{t("info.projectsByStatus")}</h2>
          {Object.keys(d.projects_by_status).length === 0 && <p className="muted">{t("common.empty")}</p>}
          {Object.entries(d.projects_by_status).map(([status, n]) => (
            <div key={status} className="row" style={{ justifyContent: "space-between" }}>
              <StatusBadge status={status} label={t(`projectStatus.${status}` as MessageKey)} />
              <strong>{n}</strong>
            </div>
          ))}
        </section>
        <section className="card stack" style={{ gap: 8 }}>
          <h2>{t("info.jobsByType")}</h2>
          {d.jobs_by_type.length === 0 && <p className="muted">{t("common.empty")}</p>}
          {d.jobs_by_type.map((j) => (
            <div key={j.job_type} className="row" style={{ justifyContent: "space-between" }}>
              <span>{t(`jobType.${j.job_type}` as MessageKey)}</span>
              <strong>{j.jobs}</strong>
            </div>
          ))}
        </section>
      </div>

      <section className="card stack" style={{ gap: 8 }}>
        <h2>{t("info.byMonth")}</h2>
        <div className="table-scroll">
          <table className="list">
            <thead>
              <tr>
                <th>{t("info.month")}</th>
                <th>{t("info.visitsDone")}</th>
                <th>{t("info.tasksDone")}</th>
                <th>{t("info.workerHours")}</th>
                <th>{t("info.crewPay")}</th>
              </tr>
            </thead>
            <tbody>
              {[...d.months].reverse().map((m) => (
                <tr key={m.month}>
                  <td>{m.month}</td>
                  <td>{m.visits_done}</td>
                  <td>{m.tasks_submitted}</td>
                  <td>{formatDuration(m.work_seconds)}</td>
                  <td>{formatMoney(m.crew_pay)}</td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </section>

      {d.materials.length > 0 && (
        <section className="card stack" style={{ gap: 8 }}>
          <h2>{t("ts.materials")}</h2>
          <table className="list">
            <thead>
              <tr>
                <th>{t("common.name")}</th>
                <th>{t("movement.INSTALLED")}</th>
                <th>{t("movement.RETRIEVED")}</th>
                <th>{t("info.damagedLost")}</th>
              </tr>
            </thead>
            <tbody>
              {d.materials.map((m) => (
                <tr key={m.item_name}>
                  <td>{m.item_name}</td>
                  <td>{Number(m.installed)} {m.unit}</td>
                  <td>{Number(m.retrieved)} {m.unit}</td>
                  <td>{Number(m.damaged_or_lost)} {m.unit}</td>
                </tr>
              ))}
            </tbody>
          </table>
        </section>
      )}

      {raw && (
        <section className="card stack" style={{ gap: 8 }}>
          <h2>{t("info.raw")}</h2>
          <ErrorBox error={jobs.error} />
          {jobs.loading && !jobs.data ? (
            <Loading />
          ) : (
            <div className="table-scroll">
              <table className="list">
                <thead>
                  <tr>
                    <th>{t("jobs.project")}</th>
                    <th>{t("ts.job")}</th>
                    <th>{t("common.status")}</th>
                    <th>{t("info.visitsDone")}</th>
                    <th>{t("info.planned")}</th>
                    <th>{t("info.dates")}</th>
                    <th>{t("info.tasksDone")}</th>
                    <th>{t("info.workerHours")}</th>
                    <th>{t("info.crewPay")}</th>
                  </tr>
                </thead>
                <tbody>
                  {(jobs.data ?? []).map((j) => (
                    <tr key={j.job_id}>
                      <td>
                        {j.project_reference}
                        <div className="muted small">{j.project_name}</div>
                      </td>
                      <td>
                        <Link href={`/jobs/${j.job_id}`}>{j.job_title}</Link>
                        <div className="muted small">
                          {t(`jobType.${j.job_type}` as MessageKey)} · {j.site_name}
                        </div>
                      </td>
                      <td>
                        <StatusBadge status={j.job_status} label={t(`jobStatus.${j.job_status}` as MessageKey)} />
                      </td>
                      <td>{j.visits_done}</td>
                      <td>{j.visits_planned}</td>
                      <td>
                        {j.first_visit_at ? formatDate(j.first_visit_at) : t("common.none")}
                        {j.last_visit_at && j.last_visit_at !== j.first_visit_at && ` – ${formatDate(j.last_visit_at)}`}
                      </td>
                      <td>{j.tasks_submitted}</td>
                      <td>{formatDuration(j.work_seconds)}</td>
                      <td>{formatMoney(j.crew_pay)}</td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
          )}
        </section>
      )}
    </div>
  );
}
