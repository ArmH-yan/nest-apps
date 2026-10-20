"use client";

// A worker's time off (ARCHITECTURE §8 worker_time_off, §14): whole days. Scheduling
// over it is allowed (a warning), so the list shows how many booked tasks fall inside.

import { useState, type FormEvent } from "react";

import { ErrorBox, Field } from "@/components/ui";
import { api, type Schemas } from "@/lib/api/client";
import { addDays, formatDate, yerevanDate } from "@/lib/format";
import { useI18n } from "@/lib/i18n";
import type { MessageKey } from "@/lib/i18n/en";
import { useApi } from "@/lib/use-api";

type TimeOff = Schemas["TimeOffOut"];
type Reason = Schemas["TimeOffIn"]["reason"];
const REASONS: Reason[] = ["VACATION", "SICK", "OTHER"];

/** "2026-10-20" → "20.10.2026" */
export function formatDay(date: string): string {
  return formatDate(`${date}T12:00:00Z`);
}

export function TimeOffSection({ workerId }: { workerId: number }) {
  const { t } = useI18n();
  const list = useApi<TimeOff[]>(`/api/v1/workers/${workerId}/time-off`);
  const today = yerevanDate();
  const [form, setForm] = useState({
    first_day: today,
    last_day: today,
    reason: "VACATION" as Reason,
    note: "",
  });
  const [error, setError] = useState<unknown>(null);
  const [busy, setBusy] = useState(false);

  async function submit(e: FormEvent) {
    e.preventDefault();
    setBusy(true);
    setError(null);
    try {
      const body: Schemas["TimeOffIn"] = { ...form, note: form.note.trim() || null };
      await api.post(`/api/v1/workers/${workerId}/time-off`, body);
      setForm({ ...form, note: "" });
      list.reload();
    } catch (err) {
      setError(err);
    } finally {
      setBusy(false);
    }
  }

  async function remove(entry: TimeOff) {
    if (!window.confirm(t("timeOff.deleteConfirm"))) return;
    setError(null);
    try {
      await api.delete(`/api/v1/workers/time-off/${entry.id}`);
      list.reload();
    } catch (err) {
      setError(err);
    }
  }

  // upcoming and current first, then the past (most recent first)
  const rows = [...(list.data ?? [])].sort((a, b) => {
    const pastA = a.last_day < today;
    const pastB = b.last_day < today;
    if (pastA !== pastB) return pastA ? 1 : -1;
    return pastA ? b.first_day.localeCompare(a.first_day) : a.first_day.localeCompare(b.first_day);
  });

  return (
    <section className="card stack" style={{ gap: 10 }}>
      <h2>{t("timeOff.title")}</h2>
      <form className="row" onSubmit={submit} style={{ alignItems: "end" }}>
        <Field label={t("timeOff.firstDay")}>
          <input
            type="date"
            required
            value={form.first_day}
            onChange={(e) => {
              const first = e.target.value;
              setForm({ ...form, first_day: first, last_day: form.last_day < first ? first : form.last_day });
            }}
          />
        </Field>
        <Field label={t("timeOff.lastDay")}>
          <input
            type="date"
            required
            min={form.first_day}
            max={addDays(form.first_day, 366)}
            value={form.last_day}
            onChange={(e) => setForm({ ...form, last_day: e.target.value })}
          />
        </Field>
        <Field label={t("timeOff.reason")}>
          <select value={form.reason} onChange={(e) => setForm({ ...form, reason: e.target.value as Reason })}>
            {REASONS.map((r) => (
              <option key={r} value={r}>
                {t(`timeOffReason.${r}` as MessageKey)}
              </option>
            ))}
          </select>
        </Field>
        <Field label={`${t("common.notes")} (${t("common.optional")})`}>
          <input value={form.note} maxLength={500} onChange={(e) => setForm({ ...form, note: e.target.value })} />
        </Field>
        <button type="submit" className="btn primary" disabled={busy}>
          {t("timeOff.add")}
        </button>
      </form>
      <ErrorBox error={error ?? list.error} />
      {rows.length === 0 ? (
        <p className="muted">{t("timeOff.none")}</p>
      ) : (
        <table className="list">
          <thead>
            <tr>
              <th>{t("info.dates")}</th>
              <th>{t("timeOff.reason")}</th>
              <th>{t("common.notes")}</th>
              <th>{t("timeOff.booked")}</th>
              <th />
            </tr>
          </thead>
          <tbody>
            {rows.map((r) => (
              <tr key={r.id} className={r.last_day < today ? "muted" : undefined}>
                <td>
                  {formatDay(r.first_day)}
                  {r.last_day !== r.first_day && ` – ${formatDay(r.last_day)}`}
                </td>
                <td>{t(`timeOffReason.${r.reason}` as MessageKey)}</td>
                <td>{r.note ?? t("common.none")}</td>
                <td>
                  {r.booked_tasks > 0 ? (
                    <span className="badge warn">{t("timeOff.bookedTasks", { n: r.booked_tasks })}</span>
                  ) : (
                    t("common.none")
                  )}
                </td>
                <td style={{ textAlign: "right" }}>
                  <button className="btn danger" onClick={() => void remove(r)}>
                    {t("timeOff.delete")}
                  </button>
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      )}
    </section>
  );
}
