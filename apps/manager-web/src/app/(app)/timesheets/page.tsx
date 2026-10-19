"use client";

// Timesheets (ARCHITECTURE §13): every worker's task per visit with recomputed
// hours, flags and approval state. Approving makes the task's pay count as earned
// in the worker app (§8). Filters live in the URL so "back" from a detail keeps them.

import Link from "next/link";
import { usePathname, useRouter, useSearchParams } from "next/navigation";
import { useState } from "react";

import { Empty, ErrorBox, Field, Flags, Loading, PageHeader, StatusBadge } from "@/components/ui";
import { api, downloadFile, type Schemas } from "@/lib/api/client";
import {
  addDays,
  formatDate,
  formatDuration,
  formatMoney,
  formatTime,
  yerevanDate,
  yerevanInstant,
} from "@/lib/format";
import { useI18n } from "@/lib/i18n";
import type { MessageKey } from "@/lib/i18n/en";
import { useApi } from "@/lib/use-api";

type Row = Schemas["TimesheetRowOut"];
type Worker = Schemas["WorkerOut"];

const SHOW = ["pending", "flagged", "approved", "all"] as const;
type Show = (typeof SHOW)[number];
const SHOW_LABEL: Record<Show, MessageKey> = {
  pending: "ts.filterPending",
  flagged: "ts.filterFlagged",
  approved: "ts.filterApproved",
  all: "ts.filterAll",
};
const SHOW_QUERY: Record<Show, string> = {
  pending: "&reviewed=false",
  flagged: "&flagged=true",
  approved: "&reviewed=true",
  all: "",
};

/** [from, to] as Yerevan dates (both inclusive) → API instants [from 00:00, to+1 00:00). */
function rangeQuery(from: string, to: string): string {
  const start = encodeURIComponent(yerevanInstant(from, "00:00"));
  const end = encodeURIComponent(yerevanInstant(addDays(to, 1), "00:00"));
  return `from=${start}&to=${end}`;
}

export default function TimesheetsPage() {
  const { t } = useI18n();
  const router = useRouter();
  const pathname = usePathname();
  const params = useSearchParams();
  const today = yerevanDate();
  const from = params.get("from") ?? `${today.slice(0, 8)}01`;
  const to = params.get("to") ?? today;
  const worker = params.get("worker") ?? "";
  const showParam = params.get("show");
  const show: Show = SHOW.find((s) => s === showParam) ?? "pending";

  const setParam = (name: string, value: string) => {
    const next = new URLSearchParams(params.toString());
    next.set(name, value);
    router.replace(`${pathname}?${next.toString()}`);
  };

  const query =
    `/api/v1/timesheets?${rangeQuery(from, to)}${SHOW_QUERY[show]}` +
    (worker ? `&worker_id=${worker}` : "");
  const rows = useApi<Row[]>(from && to ? query : null);
  const workers = useApi<Worker[]>("/api/v1/workers");
  const [error, setError] = useState<unknown>(null);
  const [busy, setBusy] = useState<number | null>(null);

  async function approve(row: Row) {
    setError(null);
    setBusy(row.assignment_id);
    try {
      await api.post(`/api/v1/timesheets/assignments/${row.assignment_id}/approve`);
      rows.reload();
    } catch (err) {
      setError(err);
    } finally {
      setBusy(null);
    }
  }

  async function exportCsv() {
    setError(null);
    try {
      await downloadFile(
        `/api/v1/timesheets/export.csv?${rangeQuery(from, to)}`,
        `nest-timesheets-${from}-${to}.csv`,
      );
    } catch (err) {
      setError(err);
    }
  }

  return (
    <div className="stack">
      <PageHeader
        title={t("ts.title")}
        action={
          <button className="btn" onClick={() => void exportCsv()}>
            {t("ts.exportCsv")}
          </button>
        }
      />
      <div className="card row" style={{ alignItems: "end" }}>
        <Field label={t("ts.from")}>
          <input type="date" value={from} max={to} onChange={(e) => setParam("from", e.target.value)} />
        </Field>
        <Field label={t("ts.to")}>
          <input type="date" value={to} min={from} onChange={(e) => setParam("to", e.target.value)} />
        </Field>
        <Field label={t("ts.worker")}>
          <select value={worker} onChange={(e) => setParam("worker", e.target.value)}>
            <option value="">{t("ts.allWorkers")}</option>
            {(workers.data ?? []).map((w) => (
              <option key={w.id} value={w.id}>
                {w.full_name} ({w.employee_code})
              </option>
            ))}
          </select>
        </Field>
        <Field label={t("ts.show")}>
          <select value={show} onChange={(e) => setParam("show", e.target.value)}>
            {SHOW.map((s) => (
              <option key={s} value={s}>
                {t(SHOW_LABEL[s])}
              </option>
            ))}
          </select>
        </Field>
      </div>

      <ErrorBox error={error ?? rows.error} />
      <div className="card">
        {rows.loading && !rows.data ? (
          <Loading />
        ) : rows.data?.length ? (
          <table className="list">
            <thead>
              <tr>
                <th>{t("ts.date")}</th>
                <th>{t("ts.worker")}</th>
                <th>{t("ts.job")}</th>
                <th>{t("ts.work")}</th>
                <th>{t("ts.break")}</th>
                <th>{t("jobs.pay")}</th>
                <th>{t("ts.flags")}</th>
                <th>{t("common.status")}</th>
                <th />
              </tr>
            </thead>
            <tbody>
              {rows.data.map((r) => (
                <tr key={r.assignment_id}>
                  <td>
                    {formatDate(r.scheduled_start)}
                    <div className="muted small">
                      {formatTime(r.scheduled_start)}–{formatTime(r.scheduled_end)}
                    </div>
                  </td>
                  <td>
                    {r.worker_name}
                    <div className="muted small">
                      {r.employee_code} · {r.role === "LEAD" ? t("jobs.lead") : t("jobs.member")}
                    </div>
                  </td>
                  <td>
                    {r.job_title}
                    <div className="muted small">{r.site_name}</div>
                  </td>
                  <td>{formatDuration(r.work_seconds)}</td>
                  <td>{formatDuration(r.break_seconds)}</td>
                  <td>{formatMoney(r.pay_amount)}</td>
                  <td>
                    <Flags flags={r.review_flags} />
                  </td>
                  <td>
                    {r.reviewed_at ? (
                      <StatusBadge status="COMPLETED" label={t("ts.approved")} />
                    ) : (
                      <StatusBadge
                        status={r.status}
                        label={t(`assignmentStatus.${r.status}` as MessageKey)}
                      />
                    )}
                  </td>
                  <td style={{ textAlign: "right" }}>
                    <div className="actions">
                      {/* flagged tasks are approved from the detail page, after a look */}
                      {!r.reviewed_at && r.status === "SUBMITTED" && r.review_flags.length === 0 && (
                        <button
                          className="btn primary"
                          disabled={busy === r.assignment_id}
                          onClick={() => void approve(r)}
                        >
                          {t("ts.approve")}
                        </button>
                      )}
                      <Link href={`/timesheets/${r.assignment_id}`} className="btn">
                        {t("ts.explore")}
                      </Link>
                    </div>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        ) : (
          <Empty text={t("ts.noRows")} />
        )}
      </div>
    </div>
  );
}
