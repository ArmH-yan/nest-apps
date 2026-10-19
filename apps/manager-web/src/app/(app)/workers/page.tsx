"use client";

import Link from "next/link";
import { useState, type FormEvent } from "react";

import { Empty, ErrorBox, Field, Loading, Modal, PageHeader } from "@/components/ui";
import { api, type Schemas } from "@/lib/api/client";
import { useI18n } from "@/lib/i18n";
import { useApi } from "@/lib/use-api";

type Worker = Schemas["WorkerOut"];

// Languages of the worker app (CLAUDE.md), shown in their own script.
const APP_LOCALES = [
  ["hy", "Հայերեն"],
  ["ru", "Русский"],
  ["en", "English"],
  ["hi", "हिन्दी"],
  ["id", "Bahasa Indonesia"],
] as const;

export default function WorkersPage() {
  const { t } = useI18n();
  const workers = useApi<Worker[]>("/api/v1/workers");
  const [creating, setCreating] = useState(false);
  const [resetting, setResetting] = useState<Worker | null>(null);
  const [error, setError] = useState<unknown>(null);

  async function toggle(w: Worker) {
    setError(null);
    try {
      await api.patch(`/api/v1/workers/${w.id}`, { is_active: !w.is_active });
      workers.reload();
    } catch (err) {
      setError(err);
    }
  }

  return (
    <div className="stack">
      <PageHeader
        title={t("workers.title")}
        action={
          <button className="btn primary" onClick={() => setCreating(true)}>
            {t("workers.new")}
          </button>
        }
      />
      <ErrorBox error={error ?? workers.error} />
      <div className="card">
        {workers.loading && !workers.data ? (
          <Loading />
        ) : workers.data?.length ? (
          <table className="list">
            <thead>
              <tr>
                <th>{t("workers.code")}</th>
                <th>{t("common.name")}</th>
                <th>{t("common.phone")}</th>
                <th>{t("workers.locale")}</th>
                <th>{t("common.status")}</th>
                <th />
              </tr>
            </thead>
            <tbody>
              {workers.data.map((w) => (
                <tr key={w.id}>
                  <td className="muted">{w.employee_code}</td>
                  <td>
                    {w.full_name}
                    {w.must_change_password && (
                      <div className="muted small">{t("workers.mustChange")}</div>
                    )}
                  </td>
                  <td>{w.phone}</td>
                  <td>{APP_LOCALES.find(([code]) => code === w.locale)?.[1] ?? w.locale}</td>
                  <td>
                    <span className={`badge ${w.is_active ? "ok" : "neutral"}`}>
                      {w.is_active ? t("workers.active") : t("workers.inactive")}
                    </span>
                  </td>
                  <td>
                    <div className="row" style={{ justifyContent: "flex-end" }}>
                      <Link href={`/workers/${w.id}`} className="btn">
                        {t("info.button")}
                      </Link>
                      <button className="btn" onClick={() => setResetting(w)}>
                        {t("workers.resetPassword")}
                      </button>
                      <button
                        className={`btn${w.is_active ? " danger" : ""}`}
                        onClick={() => void toggle(w)}
                      >
                        {w.is_active ? t("workers.deactivate") : t("workers.activate")}
                      </button>
                    </div>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        ) : (
          <Empty />
        )}
      </div>
      {creating && (
        <NewWorker
          onClose={() => setCreating(false)}
          onCreated={() => {
            setCreating(false);
            workers.reload();
          }}
        />
      )}
      {resetting && (
        <ResetPassword
          worker={resetting}
          onClose={() => setResetting(null)}
          onDone={() => {
            setResetting(null);
            workers.reload();
          }}
        />
      )}
    </div>
  );
}

function NewWorker({ onClose, onCreated }: { onClose: () => void; onCreated: () => void }) {
  const { t } = useI18n();
  const [form, setForm] = useState({
    first_name: "",
    last_name: "",
    phone: "",
    employee_code: "",
    initial_password: "",
    locale: "hy",
  });
  const [error, setError] = useState<unknown>(null);
  const [busy, setBusy] = useState(false);
  const set = (key: keyof typeof form) => (e: { target: { value: string } }) =>
    setForm((f) => ({ ...f, [key]: e.target.value }));

  async function submit(e: FormEvent) {
    e.preventDefault();
    setBusy(true);
    setError(null);
    try {
      await api.post("/api/v1/workers", { ...form, skills: [] } as Schemas["WorkerIn"]);
      onCreated();
    } catch (err) {
      setError(err);
    } finally {
      setBusy(false);
    }
  }

  return (
    <Modal open title={t("workers.new")} onClose={onClose}>
      <form className="stack" onSubmit={submit}>
        <div className="grid-2">
          <Field label={t("workers.firstName")}>
            <input required value={form.first_name} onChange={set("first_name")} />
          </Field>
          <Field label={t("workers.lastName")}>
            <input required value={form.last_name} onChange={set("last_name")} />
          </Field>
          <Field label={t("common.phone")}>
            <input required type="tel" value={form.phone} onChange={set("phone")} placeholder="+374…" />
          </Field>
          <Field label={t("workers.code")}>
            <input required value={form.employee_code} onChange={set("employee_code")} placeholder="NEST-0XX" />
          </Field>
          <Field label={t("workers.initialPassword")}>
            <input required minLength={8} value={form.initial_password} onChange={set("initial_password")} />
          </Field>
          <Field label={t("workers.locale")}>
            <select value={form.locale} onChange={set("locale")}>
              {APP_LOCALES.map(([code, name]) => (
                <option key={code} value={code}>
                  {name}
                </option>
              ))}
            </select>
          </Field>
        </div>
        <ErrorBox error={error} />
        <div className="row" style={{ justifyContent: "flex-end" }}>
          <button type="button" className="btn" onClick={onClose}>
            {t("common.cancel")}
          </button>
          <button type="submit" className="btn primary" disabled={busy}>
            {t("common.create")}
          </button>
        </div>
      </form>
    </Modal>
  );
}

function ResetPassword({
  worker,
  onClose,
  onDone,
}: {
  worker: Worker;
  onClose: () => void;
  onDone: () => void;
}) {
  const { t } = useI18n();
  const [password, setPassword] = useState("");
  const [error, setError] = useState<unknown>(null);
  const [done, setDone] = useState(false);

  async function submit(e: FormEvent) {
    e.preventDefault();
    setError(null);
    try {
      await api.post(`/api/v1/workers/${worker.id}/reset-password`, { new_password: password });
      setDone(true);
    } catch (err) {
      setError(err);
    }
  }

  return (
    <Modal open title={`${t("workers.resetPassword")}: ${worker.full_name}`} onClose={done ? onDone : onClose}>
      {done ? (
        <div className="stack">
          <div className="alert ok">{t("workers.passwordReset")}</div>
          <button className="btn primary" onClick={onDone}>
            {t("common.close")}
          </button>
        </div>
      ) : (
        <form className="stack" onSubmit={submit}>
          <Field label={t("workers.newPassword")}>
            <input required minLength={8} value={password} onChange={(e) => setPassword(e.target.value)} />
          </Field>
          <ErrorBox error={error} />
          <div className="row" style={{ justifyContent: "flex-end" }}>
            <button type="button" className="btn" onClick={onClose}>
              {t("common.cancel")}
            </button>
            <button type="submit" className="btn primary">
              {t("common.save")}
            </button>
          </div>
        </form>
      )}
    </Modal>
  );
}
