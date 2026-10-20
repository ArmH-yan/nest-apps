"use client";

// Worker "Info" (ARCHITECTURE §13a): totals and averages over a window (default:
// the last 12 months), month by month, plus the raw list of every task and a CSV.

import Link from "next/link";
import { useParams } from "next/navigation";
import { useState } from "react";

import { TimeOffSection } from "@/components/time-off";
import { ErrorBox, Field, Flags, Loading, StatTile, StatusBadge } from "@/components/ui";
import { downloadFile, type Schemas } from "@/lib/api/client";
import { formatDate, formatDuration, formatMoney, formatTime } from "@/lib/format";
import { useI18n } from "@/lib/i18n";
import type { MessageKey } from "@/lib/i18n/en";
import { useApi } from "@/lib/use-api";

type Info = Schemas["WorkerInsightsOut"];
type Task = Schemas["TimesheetRowOut"];

function percent(ratio: number): string {
  return `${Math.round(ratio * 100)}%`;
}

export default function WorkerInfoPage() {
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
  const info = useApi<Info>(`/api/v1/insights/workers/${id}${qs}`);
  const tasks = useApi<Task[]>(raw ? `/api/v1/insights/workers/${id}/tasks${qs}` : null);

  if (info.loading && !info.data) return <Loading />;
  if (!info.data) return <ErrorBox error={info.error} />;
  const d = info.data;

  async function exportCsv() {
    setError(null);
    try {
      await downloadFile(
        `/api/v1/insights/workers/${id}/tasks.csv${qs}`,
        `nest-${d.employee_code}-${d.period_start}-${d.period_end}.csv`,
      );
    } catch (err) {
      setError(err);
    }
  }

  return (
    <div className="stack">
      <div>
        <Link href="/workers" className="muted small">
          ← {t("workers.title")}
        </Link>
        <div className="page-header" style={{ marginTop: 6 }}>
          <div>
            <h1>
              {d.worker_name} <span className="muted small">{d.employee_code}</span>
            </h1>
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
        <StatTile label={t("info.meanMonthlyPay")} value={formatMoney(d.mean_monthly_pay)} />
        <StatTile label={t("info.approvedPay")} value={formatMoney(d.approved_pay)} />
        <StatTile label={t("info.meanPayPerTask")} value={formatMoney(d.mean_pay_per_task)} />
        <StatTile label={t("info.meanTasksPerMonth")} value={d.mean_tasks_per_month} />
        <StatTile label={t("info.meanWork")} value={formatDuration(d.mean_work_seconds_per_task)} hint={t("info.perTask")} />
        <StatTile label={t("info.meanBreak")} value={formatDuration(d.mean_break_seconds_per_task)} hint={t("info.perTask")} />
        <StatTile label={t("info.totalWork")} value={formatDuration(d.work_seconds)} />
        <StatTile label={t("info.tasksDone")} value={d.tasks_submitted} hint={t("info.ofAssigned", { n: d.tasks_assigned })} />
        <StatTile label={t("info.approvalRate")} value={percent(d.approval_rate)} />
        <StatTile label={t("info.flagRate")} value={percent(d.flag_rate)} hint={t("info.flaggedTasks", { n: d.flagged_tasks })} />
        <StatTile label={t("info.cancelled")} value={d.tasks_cancelled} />
        <StatTile
          label={t("info.lastTask")}
          value={d.last_task_at ? formatDate(d.last_task_at) : t("common.none")}
          hint={d.first_task_at ? t("info.firstTask", { date: formatDate(d.first_task_at) }) : undefined}
        />
      </div>

      <TimeOffSection workerId={d.worker_id} />

      <section className="card stack" style={{ gap: 8 }}>
        <h2>{t("info.byMonth")}</h2>
        <div className="table-scroll">
          <table className="list">
            <thead>
              <tr>
                <th>{t("info.month")}</th>
                <th>{t("info.assigned")}</th>
                <th>{t("info.tasksDone")}</th>
                <th>{t("ts.approved")}</th>
                <th>{t("info.approvedPay")}</th>
                <th>{t("ts.work")}</th>
                <th>{t("ts.break")}</th>
                <th>{t("ts.flags")}</th>
              </tr>
            </thead>
            <tbody>
              {[...d.months].reverse().map((m) => (
                <tr key={m.month}>
                  <td>{m.month}</td>
                  <td>{m.tasks_assigned}</td>
                  <td>{m.tasks_submitted}</td>
                  <td>{m.tasks_approved}</td>
                  <td>{formatMoney(m.approved_pay)}</td>
                  <td>{formatDuration(m.work_seconds)}</td>
                  <td>{formatDuration(m.break_seconds)}</td>
                  <td>{m.flagged_tasks}</td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </section>

      {raw && (
        <section className="card stack" style={{ gap: 8 }}>
          <h2>{t("info.raw")}</h2>
          <ErrorBox error={tasks.error} />
          {tasks.loading && !tasks.data ? (
            <Loading />
          ) : (
            <div className="table-scroll">
              <table className="list">
                <thead>
                  <tr>
                    <th>{t("ts.date")}</th>
                    <th>{t("ts.job")}</th>
                    <th>{t("jobs.crew")}</th>
                    <th>{t("common.status")}</th>
                    <th>{t("ts.work")}</th>
                    <th>{t("ts.break")}</th>
                    <th>{t("jobs.pay")}</th>
                    <th>{t("ts.flags")}</th>
                    <th>{t("ts.approved")}</th>
                    <th />
                  </tr>
                </thead>
                <tbody>
                  {(tasks.data ?? []).map((r) => (
                    <tr key={r.assignment_id}>
                      <td>
                        {formatDate(r.scheduled_start)}
                        <div className="muted small">
                          {formatTime(r.scheduled_start)}–{formatTime(r.scheduled_end)}
                        </div>
                      </td>
                      <td>
                        {r.job_title}
                        <div className="muted small">
                          {t(`jobType.${r.job_type}` as MessageKey)} · {r.site_name}
                        </div>
                      </td>
                      <td>{r.role === "LEAD" ? t("jobs.lead") : t("jobs.member")}</td>
                      <td>
                        <StatusBadge status={r.status} label={t(`assignmentStatus.${r.status}` as MessageKey)} />
                      </td>
                      <td>{formatDuration(r.work_seconds)}</td>
                      <td>{formatDuration(r.break_seconds)}</td>
                      <td>{formatMoney(r.pay_amount)}</td>
                      <td>
                        <Flags flags={r.review_flags} />
                      </td>
                      <td>{r.reviewed_at ? formatDate(r.reviewed_at) : t("common.none")}</td>
                      <td>
                        {r.status !== "ASSIGNED" && r.status !== "CANCELLED" && (
                          <Link href={`/timesheets/${r.assignment_id}`} className="btn">
                            {t("ts.explore")}
                          </Link>
                        )}
                      </td>
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
