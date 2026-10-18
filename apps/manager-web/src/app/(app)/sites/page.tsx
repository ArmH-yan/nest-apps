"use client";

import { useState, type FormEvent } from "react";

import { SiteMap } from "@/components/site-map";
import { Empty, ErrorBox, Field, Loading, Modal, PageHeader } from "@/components/ui";
import { api, type Schemas } from "@/lib/api/client";
import { useI18n } from "@/lib/i18n";
import { useApi } from "@/lib/use-api";

type Site = Schemas["SiteOut"];
type Company = Schemas["CompanyOut"];

const DEFAULT_RADIUS = 150; // settings.default_geofence_radius_m (shown when unset)

export default function SitesPage() {
  const { t } = useI18n();
  const sites = useApi<Site[]>("/api/v1/sites?limit=200");
  const companies = useApi<Company[]>("/api/v1/companies?limit=200");
  const [editing, setEditing] = useState<Site | "new" | null>(null);
  const companyName = (id: number | null | undefined) =>
    companies.data?.find((c) => c.id === id)?.name ?? t("common.none");

  return (
    <div className="stack">
      <PageHeader
        title={t("sites.title")}
        action={
          <button className="btn primary" onClick={() => setEditing("new")}>
            {t("sites.new")}
          </button>
        }
      />
      <div className="card">
        <ErrorBox error={sites.error} />
        {sites.loading && !sites.data ? (
          <Loading />
        ) : sites.data?.length ? (
          <table className="list">
            <thead>
              <tr>
                <th>{t("common.name")}</th>
                <th>{t("common.company")}</th>
                <th>{t("common.address")}</th>
                <th>{t("sites.radius")}</th>
              </tr>
            </thead>
            <tbody>
              {sites.data.map((s) => (
                <tr key={s.id} className="clickable" onClick={() => setEditing(s)}>
                  <td>
                    {s.name} {s.location_confirmed ? "✓" : ""}
                  </td>
                  <td>{companyName(s.company_id)}</td>
                  <td>{s.address}</td>
                  <td>{s.geofence_radius_m ?? `${DEFAULT_RADIUS} (${t("sites.radiusDefault")})`}</td>
                </tr>
              ))}
            </tbody>
          </table>
        ) : (
          <Empty />
        )}
      </div>
      {editing && (
        <SiteForm
          site={editing === "new" ? null : editing}
          companies={companies.data ?? []}
          onClose={() => setEditing(null)}
          onSaved={() => {
            setEditing(null);
            sites.reload();
          }}
        />
      )}
    </div>
  );
}

function SiteForm({
  site,
  companies,
  onClose,
  onSaved,
}: {
  site: Site | null;
  companies: Company[];
  onClose: () => void;
  onSaved: () => void;
}) {
  const { t } = useI18n();
  const [form, setForm] = useState({
    name: site?.name ?? "",
    address: site?.address ?? "",
    company_id: site?.company_id ? String(site.company_id) : "",
    latitude: site ? Number(site.latitude) : (null as number | null),
    longitude: site ? Number(site.longitude) : (null as number | null),
    radius: site?.geofence_radius_m ? String(site.geofence_radius_m) : "",
    confirmed: site?.location_confirmed ?? true,
    access_notes: site?.access_notes ?? "",
  });
  const [error, setError] = useState<unknown>(null);
  const [busy, setBusy] = useState(false);
  const radius = Number(form.radius) || DEFAULT_RADIUS;

  async function submit(e: FormEvent) {
    e.preventDefault();
    if (form.latitude == null || form.longitude == null) {
      setError(new Error(t("sites.pinMissing")));
      return;
    }
    setBusy(true);
    setError(null);
    const body = {
      name: form.name.trim(),
      address: form.address.trim(),
      company_id: form.company_id ? Number(form.company_id) : null,
      latitude: form.latitude.toFixed(6),
      longitude: form.longitude.toFixed(6),
      geofence_radius_m: form.radius ? Number(form.radius) : null,
      location_confirmed: form.confirmed,
      access_notes: form.access_notes || null,
    };
    try {
      if (site) await api.patch(`/api/v1/sites/${site.id}`, body);
      else await api.post("/api/v1/sites", body satisfies Schemas["SiteIn"]);
      onSaved();
    } catch (err) {
      setError(err);
    } finally {
      setBusy(false);
    }
  }

  return (
    <Modal open title={site ? site.name : t("sites.new")} onClose={onClose}>
      <form className="stack" onSubmit={submit}>
        <div className="grid-2">
          <Field label={t("common.name")}>
            <input
              required
              value={form.name}
              onChange={(e) => setForm({ ...form, name: e.target.value })}
            />
          </Field>
          <Field label={t("common.company")}>
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
        </div>
        <Field label={t("common.address")}>
          <input
            required
            value={form.address}
            onChange={(e) => setForm({ ...form, address: e.target.value })}
          />
        </Field>
        <SiteMap
          lat={form.latitude}
          lng={form.longitude}
          radius={radius}
          onPick={(latitude, longitude) => setForm((f) => ({ ...f, latitude, longitude }))}
        />
        <p className="muted small">
          {t("sites.mapHint")}{" "}
          {form.latitude != null && form.longitude != null
            ? `(${form.latitude.toFixed(6)}, ${form.longitude.toFixed(6)})`
            : ""}
        </p>
        <div className="grid-2">
          <Field label={t("sites.radius")} hint={`${t("sites.radiusDefault")}: ${DEFAULT_RADIUS}`}>
            <input
              type="number"
              min={10}
              max={5000}
              value={form.radius}
              onChange={(e) => setForm({ ...form, radius: e.target.value })}
            />
          </Field>
          <label className="check" style={{ alignSelf: "end", paddingBottom: 8 }}>
            <input
              type="checkbox"
              checked={form.confirmed}
              onChange={(e) => setForm({ ...form, confirmed: e.target.checked })}
              style={{ minHeight: 0 }}
            />
            {t("sites.confirmed")}
          </label>
        </div>
        <Field label={t("sites.accessNotes")}>
          <textarea
            value={form.access_notes}
            onChange={(e) => setForm({ ...form, access_notes: e.target.value })}
          />
        </Field>
        <ErrorBox error={error} />
        <div className="row" style={{ justifyContent: "flex-end" }}>
          <button type="button" className="btn" onClick={onClose}>
            {t("common.cancel")}
          </button>
          <button type="submit" className="btn primary" disabled={busy}>
            {site ? t("common.save") : t("common.create")}
          </button>
        </div>
      </form>
    </Modal>
  );
}
