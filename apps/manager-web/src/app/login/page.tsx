"use client";

import { useState, type FormEvent } from "react";

import { ErrorBox, Field } from "@/components/ui";
import { useI18n } from "@/lib/i18n";
import { useSession } from "@/lib/session";

export default function LoginPage() {
  const { t } = useI18n();
  const { login } = useSession();
  const [phone, setPhone] = useState("");
  const [password, setPassword] = useState("");
  const [error, setError] = useState<unknown>(null);
  const [busy, setBusy] = useState(false);

  async function submit(e: FormEvent) {
    e.preventDefault();
    setBusy(true);
    setError(null);
    try {
      await login(phone.trim(), password);
    } catch (err) {
      setError(err);
    } finally {
      setBusy(false);
    }
  }

  return (
    <main className="login-wrap">
      <form className="card stack login-card" onSubmit={submit}>
        <div className="brand" style={{ padding: 0 }}>
          <span className="brand-mark">N</span>
          {t("app.name")}
        </div>
        <div>
          <h1>{t("login.title")}</h1>
          <p className="muted small">{t("login.subtitle")}</p>
        </div>
        <Field label={t("login.phone")}>
          <input
            name="phone"
            type="tel"
            autoComplete="username"
            required
            value={phone}
            onChange={(e) => setPhone(e.target.value)}
            placeholder="+374 91 000 001"
          />
        </Field>
        <Field label={t("login.password")}>
          <input
            name="password"
            type="password"
            autoComplete="current-password"
            required
            value={password}
            onChange={(e) => setPassword(e.target.value)}
          />
        </Field>
        <ErrorBox error={error} />
        <button className="btn primary" type="submit" disabled={busy}>
          {t("login.submit")}
        </button>
        <p className="muted small">{t("login.workerHint")}</p>
      </form>
    </main>
  );
}
