"use client";

// Job detail: visits (days on site) and each visit's crew with per-task pay
// (ARCHITECTURE §8 "Worker pay", §14). PUT /visits/{id}/crew replaces the whole crew.

import Link from "next/link";
import { useParams } from "next/navigation";
import { useState, type FormEvent } from "react";

import { Empty, ErrorBox, Field, Loading, Modal, StatusBadge } from "@/components/ui";
import { api, type Schemas } from "@/lib/api/client";
import { formatDate, formatMoney, formatTime, yerevanDate, yerevanInstant } from "@/lib/format";
import { useI18n } from "@/lib/i18n";
import type { MessageKey } from "@/lib/i18n/en";
import { useApi } from "@/lib/use-api";

type Job = Schemas["JobDetailOut"];
type Visit = Schemas["VisitOut"];
type Worker = Schemas["WorkerOut"];

export default function JobPage() {
  const { id } = useParams<{ id: string }>();
  const { t } = useI18n();
  const job = useApi<Job>(`/api/v1/jobs/${id}`);
  const [crewFor, setCrewFor] = useState<Visit | null>(null);
  const [cancelling, setCancelling] = useState(false);
  const [error, setError] = useState<unknown>(null);

  if (job.loading && !job.data) return <Loading />;
  if (!job.data) return <ErrorBox error={job.error} />;
  const j = job.data;
  const closed = j.status === "COMPLETED" || j.status === "CANCELLED";

  async function cancelVisit(visit: Visit) {
    if (!window.confirm(t("jobs.cancelVisitConfirm"))) return;
    setError(null);
    try {
      await api.delete(`/api/v1/visits/${visit.id}`);
      job.reload();
    } catch (err) {
      setError(err);
    }
  }

  return (
    <div className="stack">
      <div>
        <Link href="/jobs" className="muted small">
          ← {t("jobs.title")}
        </Link>
        <div className="page-header" style={{ marginTop: 6 }}>
          <div>
            <h1>{j.title}</h1>
            <p className="muted">
              {t(`jobType.${j.job_type}` as MessageKey)} · {j.project_name} · {j.site_name},{" "}
              {j.site_address}
            </p>
          </div>
          <div className="row">
            <StatusBadge status={j.status} label={t(`jobStatus.${j.status}` as MessageKey)} />
            {!closed && (
              <button className="btn danger" onClick={() => setCancelling(true)}>
                {t("jobs.cancelJob")}
              </button>
            )}
          </div>
        </div>
        {j.instructions && <p>{j.instructions}</p>}
      </div>

      <ErrorBox error={error} />

      <section className="stack">
        <h2>{t("jobs.visits")}</h2>
        {j.visits.length === 0 && <Empty text={t("jobs.noVisits")} />}
        {j.visits.map((v) => (
          <VisitCard
            key={v.id}
            visit={v}
            onEditCrew={() => setCrewFor(v)}
            onCancel={() => void cancelVisit(v)}
          />
        ))}
        {!closed && <AddVisit jobId={j.id} onAdded={job.reload} />}
      </section>

      {crewFor && (
        <CrewEditor
          visit={crewFor}
          onClose={() => setCrewFor(null)}
          onSaved={() => {
            setCrewFor(null);
            job.reload();
          }}
        />
      )}
      {cancelling && (
        <CancelJob
          jobId={j.id}
          onClose={() => setCancelling(false)}
          onDone={() => {
            setCancelling(false);
            job.reload();
          }}
        />
      )}
    </div>
  );
}

function VisitCard({
  visit,
  onEditCrew,
  onCancel,
}: {
  visit: Visit;
  onEditCrew: () => void;
  onCancel: () => void;
}) {
  const { t } = useI18n();
  const planned = visit.status === "PLANNED";
  return (
    <div className="card stack" style={{ gap: 12 }}>
      <div className="row" style={{ justifyContent: "space-between" }}>
        <div className="row">
          <strong>{formatDate(visit.starts_at)}</strong>
          <span>
            {formatTime(visit.starts_at)} – {formatTime(visit.ends_at)}
          </span>
          <StatusBadge status={visit.status} label={t(`visitStatus.${visit.status}` as MessageKey)} />
        </div>
        {planned && (
          <div className="row">
            <button className="btn" onClick={onEditCrew}>
              {t("jobs.editCrew")}
            </button>
            <button className="btn danger" onClick={onCancel}>
              {t("jobs.cancelVisit")}
            </button>
          </div>
        )}
      </div>
      {visit.crew.length === 0 ? (
        <p className="muted">{t("jobs.noCrew")}</p>
      ) : (
        <table className="list">
          <thead>
            <tr>
              <th>{t("common.name")}</th>
              <th>{t("jobs.crew")}</th>
              <th>{t("jobs.pay")}</th>
              <th>{t("common.status")}</th>
            </tr>
          </thead>
          <tbody>
            {visit.crew.map((m) => (
              <tr key={m.assignment_id}>
                <td>
                  {m.worker_name} <span className="muted small">{m.employee_code}</span>
                </td>
                <td>{m.role === "LEAD" ? t("jobs.lead") : t("jobs.member")}</td>
                <td>{formatMoney(m.pay_amount)}</td>
                <td>
                  <StatusBadge
                    status={m.status}
                    label={t(`assignmentStatus.${m.status}` as MessageKey)}
                  />
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      )}
    </div>
  );
}

function AddVisit({ jobId, onAdded }: { jobId: number; onAdded: () => void }) {
  const { t } = useI18n();
  const [date, setDate] = useState(yerevanDate());
  const [start, setStart] = useState("09:00");
  const [end, setEnd] = useState("17:00");
  const [error, setError] = useState<unknown>(null);
  const [busy, setBusy] = useState(false);

  async function submit(e: FormEvent) {
    e.preventDefault();
    setBusy(true);
    setError(null);
    try {
      const body: Schemas["VisitIn"] = {
        starts_at: yerevanInstant(date, start),
        ends_at: yerevanInstant(date, end),
      };
      await api.post(`/api/v1/jobs/${jobId}/visits`, body);
      onAdded();
    } catch (err) {
      setError(err);
    } finally {
      setBusy(false);
    }
  }

  return (
    <form className="card row" onSubmit={submit} style={{ alignItems: "end" }}>
      <Field label={t("jobs.date")}>
        <input type="date" required value={date} onChange={(e) => setDate(e.target.value)} />
      </Field>
      <Field label={t("jobs.start")}>
        <input type="time" required value={start} onChange={(e) => setStart(e.target.value)} />
      </Field>
      <Field label={t("jobs.end")}>
        <input type="time" required value={end} onChange={(e) => setEnd(e.target.value)} />
      </Field>
      <button type="submit" className="btn primary" disabled={busy}>
        {t("jobs.addVisit")}
      </button>
      <div style={{ flexBasis: "100%" }}>
        <ErrorBox error={error} />
      </div>
    </form>
  );
}

interface CrewRow {
  worker_id: string;
  role: "LEAD" | "MEMBER";
  pay: string;
}

function CrewEditor({
  visit,
  onClose,
  onSaved,
}: {
  visit: Visit;
  onClose: () => void;
  onSaved: () => void;
}) {
  const { t, errorText } = useI18n();
  const workers = useApi<Worker[]>("/api/v1/workers?active=true");
  // time off is a warning, not a block (ARCHITECTURE §14)
  const timeOff = useApi<Schemas["TimeOffOut"][]>(
    `/api/v1/workers/time-off?from=${yerevanDate(visit.starts_at)}&to=${yerevanDate(visit.ends_at)}`,
  );
  const away = new Map((timeOff.data ?? []).map((o) => [String(o.worker_id), o]));
  const [rows, setRows] = useState<CrewRow[]>(
    visit.crew.map((m) => ({
      worker_id: String(m.worker_id),
      role: m.role,
      pay: m.pay_amount ? String(Number(m.pay_amount)) : "",
    })),
  );
  const [error, setError] = useState<unknown>(null);
  const [message, setMessage] = useState<string | null>(null);
  const [busy, setBusy] = useState(false);

  const update = (i: number, patch: Partial<CrewRow>) =>
    setRows((rs) =>
      rs.map((r, k) => {
        if (k === i) return { ...r, ...patch };
        // choosing a new lead demotes the old one
        return patch.role === "LEAD" && r.role === "LEAD" ? { ...r, role: "MEMBER" } : r;
      }),
    );

  async function save() {
    setError(null);
    setMessage(null);
    const filled = rows.filter((r) => r.worker_id);
    if (filled.length > 0 && filled.filter((r) => r.role === "LEAD").length !== 1) {
      setMessage(t("jobs.needOneLead"));
      return;
    }
    setBusy(true);
    try {
      const body: Schemas["CrewIn"] = {
        members: filled.map((r) => ({
          worker_id: Number(r.worker_id),
          role: r.role,
          pay_amount: r.pay ? r.pay : null,
        })),
      };
      await api.put(`/api/v1/visits/${visit.id}/crew`, body);
      onSaved();
    } catch (err) {
      setError(err);
    } finally {
      setBusy(false);
    }
  }

  const chosen = new Set(rows.map((r) => r.worker_id));

  return (
    <Modal open title={t("jobs.editCrew")} onClose={onClose}>
      {workers.loading && !workers.data ? (
        <Loading />
      ) : (
        <div className="stack">
          {rows.map((row, i) => (
            <div key={i} className="row" style={{ alignItems: "end" }}>
              <Field label={t("common.name")}>
                <select
                  value={row.worker_id}
                  onChange={(e) => update(i, { worker_id: e.target.value })}
                  style={{ minWidth: 200 }}
                >
                  <option value="">—</option>
                  {(workers.data ?? []).map((w) => (
                    <option
                      key={w.id}
                      value={w.id}
                      disabled={chosen.has(String(w.id)) && row.worker_id !== String(w.id)}
                    >
                      {w.full_name} ({w.employee_code})
                      {away.has(String(w.id)) ? ` · ${t("timeOff.onLeave")}` : ""}
                    </option>
                  ))}
                </select>
              </Field>
              <label className="check">
                <input
                  type="radio"
                  name="lead"
                  checked={row.role === "LEAD"}
                  onChange={() => update(i, { role: "LEAD" })}
                  style={{ minHeight: 0 }}
                />
                {t("jobs.lead")}
              </label>
              <Field label={t("jobs.pay")}>
                <input
                  type="number"
                  min={0}
                  step={500}
                  value={row.pay}
                  onChange={(e) => update(i, { pay: e.target.value })}
                  style={{ width: 120 }}
                />
              </Field>
              <button
                type="button"
                className="btn"
                aria-label="remove"
                onClick={() => setRows((rs) => rs.filter((_, k) => k !== i))}
              >
                ✕
              </button>
            </div>
          ))}
          <button
            type="button"
            className="btn"
            onClick={() =>
              setRows((rs) => [
                ...rs,
                { worker_id: "", role: rs.length === 0 ? "LEAD" : "MEMBER", pay: "" },
              ])
            }
          >
            + {t("jobs.addWorker")}
          </button>
          {rows
            .filter((r) => away.has(r.worker_id))
            .map((r) => {
              const o = away.get(r.worker_id)!;
              return (
                <div key={r.worker_id} className="alert warn">
                  {t("timeOff.crewWarning", {
                    name: o.worker_name,
                    reason: t(`timeOffReason.${o.reason}` as MessageKey),
                    from: formatDate(`${o.first_day}T12:00:00Z`),
                    to: formatDate(`${o.last_day}T12:00:00Z`),
                  })}
                </div>
              );
            })}
          {message && <div className="alert">{message}</div>}
          {error != null && (
            <div className="alert">
              {errorText(error)}
              {error instanceof Object && "details" in error && conflictHint(error)}
            </div>
          )}
          <div className="row" style={{ justifyContent: "flex-end" }}>
            <button type="button" className="btn" onClick={onClose}>
              {t("common.cancel")}
            </button>
            <button type="button" className="btn primary" disabled={busy} onClick={() => void save()}>
              {t("jobs.saveCrew")}
            </button>
          </div>
        </div>
      )}
    </Modal>
  );
}

/** "→ job #12" for a double booking, so the manager can go and look. */
function conflictHint(error: object): React.ReactNode {
  const details = (error as { details?: Record<string, unknown> }).details;
  const jobId = details?.conflicting_job_id;
  return typeof jobId === "number" ? (
    <>
      {" "}
      <Link href={`/jobs/${jobId}`} className="btn link">
        → #{jobId}
      </Link>
    </>
  ) : null;
}

function CancelJob({
  jobId,
  onClose,
  onDone,
}: {
  jobId: number;
  onClose: () => void;
  onDone: () => void;
}) {
  const { t } = useI18n();
  const [reason, setReason] = useState("");
  const [error, setError] = useState<unknown>(null);

  async function submit(e: FormEvent) {
    e.preventDefault();
    try {
      await api.post(`/api/v1/jobs/${jobId}/cancel`, { reason });
      onDone();
    } catch (err) {
      setError(err);
    }
  }

  return (
    <Modal open title={t("jobs.cancelJob")} onClose={onClose}>
      <form className="stack" onSubmit={submit}>
        <Field label={t("jobs.cancelReason")}>
          <textarea required value={reason} onChange={(e) => setReason(e.target.value)} />
        </Field>
        <ErrorBox error={error} />
        <div className="row" style={{ justifyContent: "flex-end" }}>
          <button type="button" className="btn" onClick={onClose}>
            {t("common.cancel")}
          </button>
          <button type="submit" className="btn danger">
            {t("common.confirm")}
          </button>
        </div>
      </form>
    </Modal>
  );
}
