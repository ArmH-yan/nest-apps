"use client";

import { useEffect, useRef, type ReactNode } from "react";

import { useI18n } from "@/lib/i18n";
import type { MessageKey } from "@/lib/i18n/en";

export function PageHeader({ title, action }: { title: string; action?: ReactNode }) {
  return (
    <div className="page-header">
      <h1>{title}</h1>
      {action}
    </div>
  );
}

export function Field({
  label,
  children,
  hint,
}: {
  label: string;
  children: ReactNode;
  hint?: string;
}) {
  return (
    <label className="field">
      {label}
      {children}
      {hint && <span className="muted small">{hint}</span>}
    </label>
  );
}

export function ErrorBox({ error }: { error: unknown }) {
  const { errorText } = useI18n();
  if (!error) return null;
  return (
    <div className="alert" role="alert">
      {errorText(error)}
    </div>
  );
}

export function Loading() {
  const { t } = useI18n();
  return <p className="muted">{t("common.loading")}</p>;
}

export function Empty({ text }: { text?: string }) {
  const { t } = useI18n();
  return <p className="muted">{text ?? t("common.empty")}</p>;
}

type Tone = "ok" | "warn" | "bad" | "info" | "neutral";

const TONES: Record<string, Tone> = {
  DRAFT: "neutral",
  SCHEDULED: "info",
  PLANNED: "info",
  ASSIGNED: "info",
  IN_PROGRESS: "warn",
  COMPLETED: "ok",
  DONE: "ok",
  SUBMITTED: "ok",
  WON: "ok",
  INSTALLED: "ok",
  CANCELLED: "bad",
  NO_ACCESS: "bad",
  LOST: "bad",
};

export function StatusBadge({ status, label }: { status: string; label: string }) {
  return <span className={`badge ${TONES[status] ?? "neutral"}`}>{label}</span>;
}

/** One number on an Info page (worker / company statistics). */
export function StatTile({ label, value, hint }: { label: string; value: ReactNode; hint?: string }) {
  return (
    <div className="stat">
      <div className="muted small">{label}</div>
      <div className="value">{value}</div>
      {hint && <div className="muted small">{hint}</div>}
    </div>
  );
}

/** Review flags set by the server (OUTSIDE_GEOFENCE, LATE_SYNC, …; ARCHITECTURE §19). */
export function Flags({ flags }: { flags: string[] }) {
  const { t } = useI18n();
  if (flags.length === 0) return <span className="muted">{t("common.none")}</span>;
  return (
    <span className="flags">
      {flags.map((f) => (
        <span key={f} className="badge warn">
          {t(`flag.${f}` as MessageKey)}
        </span>
      ))}
    </span>
  );
}

/** Native <dialog>: focus trap, Esc to close and backdrop for free. */
export function Modal({
  open,
  title,
  onClose,
  children,
}: {
  open: boolean;
  title: string;
  onClose: () => void;
  children: ReactNode;
}) {
  const ref = useRef<HTMLDialogElement>(null);
  useEffect(() => {
    const dialog = ref.current;
    if (!dialog) return;
    if (open && !dialog.open) dialog.showModal();
    if (!open && dialog.open) dialog.close();
  }, [open]);
  return (
    <dialog ref={ref} className="modal" onClose={onClose}>
      <div className="stack">
        <h2>{title}</h2>
        {children}
      </div>
    </dialog>
  );
}
