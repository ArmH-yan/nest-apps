"use client";

import { useState, type FormEvent } from "react";

import { Empty, ErrorBox, Field, Loading, Modal, PageHeader, StatusBadge } from "@/components/ui";
import { api, type Schemas } from "@/lib/api/client";
import { useI18n } from "@/lib/i18n";
import type { MessageKey } from "@/lib/i18n/en";
import { useApi } from "@/lib/use-api";

type Project = Schemas["ProjectOut"];
type Site = Schemas["SiteOut"];
type Company = Schemas["CompanyOut"];
type Service = Schemas["ServiceOut"];

export default function ProjectsPage() {
  const { t, locale } = useI18n();
  const projects = useApi<Project[]>("/api/v1/projects?limit=200");
  const sites = useApi<Site[]>("/api/v1/sites?limit=200");
  const companies = useApi<Company[]>("/api/v1/companies?limit=200");
  const services = useApi<Service[]>("/api/v1/services");
  const [open, setOpen] = useState(false);

  const siteName = (id: number) => sites.data?.find((s) => s.id === id)?.name ?? `#${id}`;
  const serviceName = (slug: string) => {
    const s = services.data?.find((x) => x.slug === slug);
    if (!s) return slug;
    return locale === "hy" ? s.name_hy : locale === "ru" ? s.name_ru : s.name_en;
  };

  return (
    <div className="stack">
      <PageHeader
        title={t("projects.title")}
        action={
          <button className="btn primary" onClick={() => setOpen(true)}>
            {t("projects.new")}
          </button>
        }
      />
      <div className="card">
        <ErrorBox error={projects.error} />
        {projects.loading && !projects.data ? (
          <Loading />
        ) : projects.data?.length ? (
          <table className="list">
            <thead>
              <tr>
                <th>{t("projects.reference")}</th>
                <th>{t("common.name")}</th>
                <th>{t("projects.site")}</th>
                <th>{t("projects.service")}</th>
                <th>{t("common.status")}</th>
              </tr>
            </thead>
            <tbody>
              {projects.data.map((p) => (
                <tr key={p.id}>
                  <td className="muted">{p.reference}</td>
                  <td>{p.name}</td>
                  <td>{siteName(p.site_id)}</td>
                  <td>{serviceName(p.service_slug)}</td>
                  <td>
                    <StatusBadge
                      status={p.status}
                      label={t(`projectStatus.${p.status}` as MessageKey)}
                    />
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        ) : (
          <Empty />
        )}
      </div>
      {open && (
        <NewProject
          sites={sites.data ?? []}
          companies={companies.data ?? []}
          services={services.data ?? []}
          serviceName={serviceName}
          onClose={() => setOpen(false)}
          onCreated={() => {
            setOpen(false);
            projects.reload();
          }}
        />
      )}
    </div>
  );
}

function NewProject({
  sites,
  companies,
  services,
  serviceName,
  onClose,
  onCreated,
}: {
  sites: Site[];
  companies: Company[];
  services: Service[];
  serviceName: (slug: string) => string;
  onClose: () => void;
  onCreated: () => void;
}) {
  const { t } = useI18n();
  const [form, setForm] = useState({
    name: "",
    site_id: "",
    company_id: "",
    service_slug: services[0]?.slug ?? "safety-system",
  });
  const [error, setError] = useState<unknown>(null);
  const [busy, setBusy] = useState(false);

  async function submit(e: FormEvent) {
    e.preventDefault();
    setBusy(true);
    setError(null);
    try {
      const site = sites.find((s) => s.id === Number(form.site_id));
      const body: Schemas["ProjectIn"] = {
        name: form.name.trim(),
        site_id: Number(form.site_id),
        // a site's company is the natural default
        company_id: form.company_id ? Number(form.company_id) : (site?.company_id ?? null),
        service_slug: form.service_slug,
      };
      await api.post("/api/v1/projects", body);
      onCreated();
    } catch (err) {
      setError(err);
    } finally {
      setBusy(false);
    }
  }

  return (
    <Modal open title={t("projects.new")} onClose={onClose}>
      <form className="stack" onSubmit={submit}>
        <Field label={t("common.name")}>
          <input required value={form.name} onChange={(e) => setForm({ ...form, name: e.target.value })} />
        </Field>
        <div className="grid-2">
          <Field label={t("projects.site")}>
            <select
              required
              value={form.site_id}
              onChange={(e) => setForm({ ...form, site_id: e.target.value })}
            >
              <option value="" disabled>
                —
              </option>
              {sites.map((s) => (
                <option key={s.id} value={s.id}>
                  {s.name}
                </option>
              ))}
            </select>
          </Field>
          <Field label={t("projects.service")}>
            <select
              value={form.service_slug}
              onChange={(e) => setForm({ ...form, service_slug: e.target.value })}
            >
              {services.map((s) => (
                <option key={s.slug} value={s.slug}>
                  {serviceName(s.slug)}
                </option>
              ))}
            </select>
          </Field>
        </div>
        <Field label={t("common.company")} hint={t("common.optional")}>
          <select
            value={form.company_id}
            onChange={(e) => setForm({ ...form, company_id: e.target.value })}
          >
            <option value="">{t("common.none")}</option>
            {companies.map((c) => (
              <option key={c.id} value={c.id}>
                {c.name}
              </option>
            ))}
          </select>
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
