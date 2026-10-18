"use client";

// One worker's task on one visit (ARCHITECTURE §13 "Timesheets"): sessions, GPS
// checks on a map, photos, materials, flags. The manager approves it, corrects a
// session ("forgot to stop the break") or accepts a location that failed the
// geofence. Every action is audited server-side (§31); approval locks the timesheet.

import Link from "next/link";
import { useParams } from "next/navigation";
import { useState, type FormEvent } from "react";

import { SiteMap } from "@/components/site-map";
import { ErrorBox, Field, Flags, Loading, Modal, StatusBadge } from "@/components/ui";
import { api, type Schemas } from "@/lib/api/client";
import {
  formatDate,
  formatDateTime,
  formatDuration,
  formatMoney,
  formatTime,
  fromLocalInput,
  yerevanLocalInput,
} from "@/lib/format";
import { useI18n } from "@/lib/i18n";
import type { MessageKey } from "@/lib/i18n/en";
import { useApi } from "@/lib/use-api";

type Detail = Schemas["TimesheetDetailOut"];
type Entry = Schemas["TimeEntryRowOut"];
type Check = Schemas["LocationCheckRowOut"];

function seconds(entry: Entry): number {
  const end = entry.ended_at ? Date.parse(entry.ended_at) : Date.now();
  return Math.max(0, (end - Date.parse(entry.started_at)) / 1000);
}

function insideSite(c: Check): boolean {
  return c.server_distance_m <= c.radius_m;
}

export default function TimesheetPage() {
  const { id } = useParams<{ id: string }>();
  const { t } = useI18n();
  const sheet = useApi<Detail>(`/api/v1/timesheets/assignments/${id}`);
  const [adjusting, setAdjusting] = useState<Entry | null>(null);
  const [accepting, setAccepting] = useState<Check | null>(null);
  const [error, setError] = useState<unknown>(null);
  const [busy, setBusy] = useState(false);

  if (sheet.loading && !sheet.data) return <Loading />;
  if (!sheet.data) return <ErrorBox error={sheet.error} />;
  const d = sheet.data;
  const locked = d.reviewed_at != null;

  async function approve() {
    setError(null);
    setBusy(true);
    try {
      await api.post(`/api/v1/timesheets/assignments/${d.assignment_id}/approve`);
      sheet.reload();
    } catch (err) {
      setError(err);
    } finally {
      setBusy(false);
    }
  }

  const done = () => {
    setAdjusting(null);
    setAccepting(null);
    sheet.reload();
  };

  return (
    <div className="stack">
      <div>
        <Link href="/timesheets" className="muted small">
          ← {t("ts.title")}
        </Link>
        <div className="page-header" style={{ marginTop: 6 }}>
          <div>
            <h1>
              {d.worker_name} <span className="muted small">{d.employee_code}</span>
            </h1>
            <p className="muted">
              <Link href={`/jobs/${d.job_id}`}>{d.job_title}</Link> · {d.site_name} ·{" "}
              {d.role === "LEAD" ? t("jobs.lead") : t("jobs.member")}
            </p>
          </div>
          <div className="row">
            {locked ? (
              <StatusBadge status="COMPLETED" label={t("ts.approved")} />
            ) : (
              <StatusBadge status={d.status} label={t(`assignmentStatus.${d.status}` as MessageKey)} />
            )}
            {!locked && d.status === "SUBMITTED" && (
              <button className="btn primary" disabled={busy} onClick={() => void approve()}>
                {t("ts.approve")}
              </button>
            )}
          </div>
        </div>
        {locked && d.reviewed_at && (
          <div className="alert ok">
            {t("ts.approvedBy", {
              name: d.reviewed_by_name ?? "—",
              date: formatDateTime(d.reviewed_at),
            })}
          </div>
        )}
      </div>

      <ErrorBox error={error} />

      <div className="grid-2">
        <section className="card stack" style={{ gap: 8 }}>
          <h2>{t("ts.totals")}</h2>
          <div>
            {t("ts.scheduled")}: {formatDate(d.scheduled_start)} {formatTime(d.scheduled_start)}–
            {formatTime(d.scheduled_end)}
          </div>
          <div>
            {t("ts.work")}: <strong>{formatDuration(d.work_seconds)}</strong> · {t("ts.break")}:{" "}
            <strong>{formatDuration(d.break_seconds)}</strong>
          </div>
          <div>
            {t("jobs.pay")}: <strong>{formatMoney(d.pay_amount)}</strong>
          </div>
          {d.reported_work_seconds != null && (
            <div className="muted small">
              {t("ts.reported", {
                work: formatDuration(d.reported_work_seconds),
                break: formatDuration(d.reported_break_seconds ?? 0),
              })}
            </div>
          )}
        </section>
        <section className="card stack" style={{ gap: 8 }}>
          <h2>{t("ts.flags")}</h2>
          {d.review_flags.length ? <Flags flags={d.review_flags} /> : <p className="muted">{t("ts.noFlags")}</p>}
          {d.comment && (
            <>
              <h2>{t("ts.comment")}</h2>
              <p style={{ whiteSpace: "pre-wrap" }}>{d.comment}</p>
            </>
          )}
        </section>
      </div>

      <section className="card stack" style={{ gap: 8 }}>
        <h2>{t("ts.entries")}</h2>
        <table className="list">
          <thead>
            <tr>
              <th>{t("ts.kind")}</th>
              <th>{t("ts.started")}</th>
              <th>{t("ts.ended")}</th>
              <th>{t("ts.duration")}</th>
              <th />
            </tr>
          </thead>
          <tbody>
            {d.entries.map((e) => (
              <tr key={e.id}>
                <td>{t(`entryKind.${e.kind}` as MessageKey)}</td>
                <td>{formatDateTime(e.started_at)}</td>
                <td>{e.ended_at ? formatDateTime(e.ended_at) : <em>{t("ts.running")}</em>}</td>
                <td>{formatDuration(seconds(e))}</td>
                <td style={{ textAlign: "right" }}>
                  {!locked && (
                    <button className="btn" onClick={() => setAdjusting(e)}>
                      {t("ts.adjust")}
                    </button>
                  )}
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </section>

      <section className="card stack" style={{ gap: 8 }}>
        <h2>{t("ts.checks")}</h2>
        <SiteMap
          lat={d.site_latitude}
          lng={d.site_longitude}
          radius={d.site_radius_m}
          points={d.checks.map((c) => ({
            lat: c.latitude,
            lng: c.longitude,
            ok: insideSite(c) || c.override_reason != null,
            label: `${t(`checkPurpose.${c.purpose}` as MessageKey)} ${formatTime(c.captured_at)} · ${Math.round(c.server_distance_m)} m`,
          }))}
        />
        <p className="muted small">{t("ts.mapLegend")}</p>
        <table className="list">
          <thead>
            <tr>
              <th>{t("ts.purpose")}</th>
              <th>{t("ts.date")}</th>
              <th>{t("ts.distance")}</th>
              <th>{t("ts.accuracy")}</th>
              <th>{t("common.status")}</th>
              <th />
            </tr>
          </thead>
          <tbody>
            {d.checks.map((c) => {
              const inside = insideSite(c);
              return (
                <tr key={c.id}>
                  <td>{t(`checkPurpose.${c.purpose}` as MessageKey)}</td>
                  <td>{formatDateTime(c.captured_at)}</td>
                  <td>
                    {Math.round(c.server_distance_m)} m{" "}
                    <span className="muted small">/ {Math.round(c.radius_m)} m</span>
                  </td>
                  <td>±{Math.round(c.accuracy_m)} m</td>
                  <td>
                    <span className="flags">
                      <StatusBadge
                        status={inside ? "COMPLETED" : "CANCELLED"}
                        label={inside ? t("ts.inside") : t("ts.outside")}
                      />
                      {c.is_mocked && <span className="badge bad">{t("flag.MOCK_LOCATION")}</span>}
                    </span>
                    {c.override_reason && (
                      <div className="muted small">
                        {t("ts.accepted", { reason: c.override_reason })}
                      </div>
                    )}
                  </td>
                  <td style={{ textAlign: "right" }}>
                    {!locked && !inside && !c.override_reason && c.purpose !== "MANUAL" && (
                      <button className="btn" onClick={() => setAccepting(c)}>
                        {t("ts.accept")}
                      </button>
                    )}
                  </td>
                </tr>
              );
            })}
          </tbody>
        </table>
      </section>

      {d.photos.length > 0 && (
        <section className="card stack" style={{ gap: 8 }}>
          <h2>{t("ts.photos")}</h2>
          <div className="photos">
            {d.photos.map((p) => (
              <a key={p.id} href={p.url} target="_blank" rel="noreferrer">
                {/* presigned S3 URLs: next/image would need the bucket host configured */}
                {/* eslint-disable-next-line @next/next/no-img-element */}
                <img src={p.url} alt={p.taken_at ? formatDateTime(p.taken_at) : p.kind} />
              </a>
            ))}
          </div>
        </section>
      )}

      {d.materials.length > 0 && (
        <section className="card stack" style={{ gap: 8 }}>
          <h2>{t("ts.materials")}</h2>
          <table className="list">
            <thead>
              <tr>
                <th>{t("common.name")}</th>
                <th>{t("ts.quantity")}</th>
                <th>{t("ts.kind")}</th>
                <th>{t("common.notes")}</th>
              </tr>
            </thead>
            <tbody>
              {d.materials.map((m, i) => (
                <tr key={i}>
                  <td>{m.item_name}</td>
                  <td>
                    {Number(m.quantity)} {m.unit}
                  </td>
                  <td>{t(`movement.${m.movement}` as MessageKey)}</td>
                  <td>{m.note ?? t("common.none")}</td>
                </tr>
              ))}
            </tbody>
          </table>
        </section>
      )}

      {adjusting && (
        <AdjustEntry
          assignmentId={d.assignment_id}
          entry={adjusting}
          onClose={() => setAdjusting(null)}
          onDone={done}
        />
      )}
      {accepting && (
        <AcceptCheck check={accepting} onClose={() => setAccepting(null)} onDone={done} />
      )}
    </div>
  );
}

function AdjustEntry({
  assignmentId,
  entry,
  onClose,
  onDone,
}: {
  assignmentId: number;
  entry: Entry;
  onClose: () => void;
  onDone: () => void;
}) {
  const { t } = useI18n();
  const [start, setStart] = useState(yerevanLocalInput(entry.started_at));
  const [end, setEnd] = useState(entry.ended_at ? yerevanLocalInput(entry.ended_at) : "");
  const [reason, setReason] = useState("");
  const [error, setError] = useState<unknown>(null);
  const [busy, setBusy] = useState(false);

  async function submit(e: FormEvent) {
    e.preventDefault();
    setBusy(true);
    setError(null);
    try {
      const body: Schemas["AdjustIn"] = {
        time_entry_id: entry.id,
        started_at: fromLocalInput(start),
        ended_at: fromLocalInput(end),
        reason: reason.trim(),
      };
      await api.post(`/api/v1/timesheets/assignments/${assignmentId}/adjust`, body);
      onDone();
    } catch (err) {
      setError(err);
      setBusy(false);
    }
  }

  return (
    <Modal open title={`${t("ts.adjustTitle")} · ${t(`entryKind.${entry.kind}` as MessageKey)}`} onClose={onClose}>
      <form className="stack" onSubmit={submit}>
        <div className="grid-2">
          <Field label={t("ts.started")}>
            <input type="datetime-local" required value={start} onChange={(e) => setStart(e.target.value)} />
          </Field>
          <Field label={t("ts.ended")}>
            <input
              type="datetime-local"
              required
              min={start}
              value={end}
              onChange={(e) => setEnd(e.target.value)}
            />
          </Field>
        </div>
        <Field label={t("ts.reason")}>
          <textarea required minLength={3} value={reason} onChange={(e) => setReason(e.target.value)} />
        </Field>
        <ErrorBox error={error} />
        <div className="row" style={{ justifyContent: "flex-end" }}>
          <button type="button" className="btn" onClick={onClose}>
            {t("common.cancel")}
          </button>
          <button type="submit" className="btn primary" disabled={busy}>
            {t("common.save")}
          </button>
        </div>
      </form>
    </Modal>
  );
}

function AcceptCheck({
  check,
  onClose,
  onDone,
}: {
  check: Check;
  onClose: () => void;
  onDone: () => void;
}) {
  const { t } = useI18n();
  const [reason, setReason] = useState("");
  const [error, setError] = useState<unknown>(null);
  const [busy, setBusy] = useState(false);

  async function submit(e: FormEvent) {
    e.preventDefault();
    setBusy(true);
    setError(null);
    try {
      const body: Schemas["OverrideIn"] = { reason: reason.trim() };
      await api.post(`/api/v1/location-checks/${check.id}/override`, body);
      onDone();
    } catch (err) {
      setError(err);
      setBusy(false);
    }
  }

  return (
    <Modal open title={t("ts.acceptTitle")} onClose={onClose}>
      <form className="stack" onSubmit={submit}>
        <p className="muted">
          {t(`checkPurpose.${check.purpose}` as MessageKey)} · {formatDateTime(check.captured_at)} ·{" "}
          {Math.round(check.server_distance_m)} m / {Math.round(check.radius_m)} m
        </p>
        <Field label={t("ts.reason")}>
          <textarea required minLength={3} value={reason} onChange={(e) => setReason(e.target.value)} />
        </Field>
        <ErrorBox error={error} />
        <div className="row" style={{ justifyContent: "flex-end" }}>
          <button type="button" className="btn" onClick={onClose}>
            {t("common.cancel")}
          </button>
          <button type="submit" className="btn primary" disabled={busy}>
            {t("ts.accept")}
          </button>
        </div>
      </form>
    </Modal>
  );
}
