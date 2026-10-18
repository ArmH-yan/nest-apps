"use client";

import Link from "next/link";
import { useRouter } from "next/navigation";
import { useState, type FormEvent } from "react";

import { Empty, ErrorBox, Field, Loading, Modal, PageHeader, StatusBadge } from "@/components/ui";
import { api, type Schemas } from "@/lib/api/client";
import { JOB_TYPES, type JobType } from "@/lib/constants";
import { formatDateTime } from "@/lib/format";
import { useI18n } from "@/lib/i18n";
import type { MessageKey } from "@/lib/i18n/en";
import { useApi } from "@/lib/use-api";

type JobItem = Schemas["JobListItemOut"];
type Project = Schemas["ProjectOut"];

export default function JobsPage() {
  const { t } = useI18n();
  const jobs = useApi<JobItem[]>("/api/v1/jobs?limit=200");
  const [open, setOpen] = useState(false);

  return (
    <div className="stack">
      <PageHeader
        title={t("jobs.title")}
        action={
          <button className="btn primary" onClick={() => setOpen(true)}>
            {t("jobs.new")}
          </button>
        }
      />
      <div className="card">
        <ErrorBox error={jobs.error} />
        {jobs.loading && !jobs.data ? (
          <Loading />
        ) : jobs.data?.length ? (
          <table className="list">
            <thead>
              <tr>
                <th>{t("jobs.jobTitle")}</th>
                <th>{t("jobs.type")}</th>
                <th>{t("jobs.project")}</th>
                <th>{t("jobs.nextVisit")}</th>
                <th>{t("common.status")}</th>
              </tr>
            </thead>
            <tbody>
              {jobs.data.map((j) => (
                <tr key={j.id} className="clickable">
                  <td>
                    <Link href={`/jobs/${j.id}`}>{j.title}</Link>
                    <div className="muted small">{j.site_name}</div>
                  </td>
                  <td>{t(`jobType.${j.job_type}` as MessageKey)}</td>
                  <td>{j.project_name}</td>
                  <td>{j.next_visit_at ? formatDateTime(j.next_visit_at) : t("common.none")}</td>
                  <td>
                    <StatusBadge status={j.status} label={t(`jobStatus.${j.status}` as MessageKey)} />
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        ) : (
          <Empty />
        )}
      </div>
      {open && <NewJob onClose={() => setOpen(false)} />}
    </div>
  );
}

function NewJob({ onClose }: { onClose: () => void }) {
  const { t } = useI18n();
  const router = useRouter();
  const projects = useApi<Project[]>("/api/v1/projects?limit=200");
  const [form, setForm] = useState({
    project_id: "",
    job_type: "INSTALLATION" as JobType,
    title: "",
    instructions: "",
  });
  const [error, setError] = useState<unknown>(null);
  const [busy, setBusy] = useState(false);

  async function submit(e: FormEvent) {
    e.preventDefault();
    setBusy(true);
    setError(null);
    try {
      const body: Schemas["JobIn"] = {
        project_id: Number(form.project_id),
        job_type: form.job_type,
        title: form.title.trim(),
        instructions: form.instructions || null,
        priority: 0,
      };
      const job = await api.post<Schemas["JobOut"]>("/api/v1/jobs", body);
      router.push(`/jobs/${job.id}`); // next: add visits and the crew
    } catch (err) {
      setError(err);
      setBusy(false);
    }
  }

  return (
    <Modal open title={t("jobs.new")} onClose={onClose}>
      <form className="stack" onSubmit={submit}>
        <div className="grid-2">
          <Field label={t("jobs.project")}>
            <select
              required
              value={form.project_id}
              onChange={(e) => setForm({ ...form, project_id: e.target.value })}
            >
              <option value="" disabled>
                —
              </option>
              {(projects.data ?? []).map((p) => (
                <option key={p.id} value={p.id}>
                  {p.reference} · {p.name}
                </option>
              ))}
            </select>
          </Field>
          <Field label={t("jobs.type")}>
            <select
              value={form.job_type}
              onChange={(e) =>
                setForm({ ...form, job_type: e.target.value as JobType })
              }
            >
              {JOB_TYPES.map((type) => (
                <option key={type} value={type}>
                  {t(`jobType.${type}`)}
                </option>
              ))}
            </select>
          </Field>
        </div>
        <Field label={t("jobs.jobTitle")}>
          <input
            required
            value={form.title}
            onChange={(e) => setForm({ ...form, title: e.target.value })}
            placeholder="Install Safety Net - Building A"
          />
        </Field>
        <Field label={t("jobs.instructions")}>
          <textarea
            value={form.instructions}
            onChange={(e) => setForm({ ...form, instructions: e.target.value })}
          />
        </Field>
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
