"use client";

// One assessment request (ARCHITECTURE §9): what the customer sent (kept as
// received), the manager's review notes, and conversion into a project, which
// creates or links company, contact and site in one step on the server.

import Link from "next/link";
import { useParams } from "next/navigation";
import { useState, type FormEvent } from "react";

import { SiteMap } from "@/components/site-map";
import { ErrorBox, Field, Loading, Modal, StatusBadge } from "@/components/ui";
import { api, type Schemas } from "@/lib/api/client";
import { formatDateTime } from "@/lib/format";
import { useI18n } from "@/lib/i18n";
import type { MessageKey } from "@/lib/i18n/en";
import { useApi } from "@/lib/use-api";

type Request = Schemas["RequestOut"];
type Service = Schemas["ServiceOut"];
type Company = Schemas["CompanyOut"];
type Contact = Schemas["ContactOut"];
type Site = Schemas["SiteOut"];

const OPEN: Request["status"][] = ["NEW", "IN_REVIEW"];

function serviceName(s: Service, locale: string): string {
  return locale === "hy" ? s.name_hy : locale === "ru" ? s.name_ru : s.name_en;
}

export default function RequestPage() {
  const { id } = useParams<{ id: string }>();
  const { t } = useI18n();
  const req = useApi<Request>(`/api/v1/assessment-requests/${id}`);
  const [rejecting, setRejecting] = useState<null | "reject" | "spam">(null);
  const [error, setError] = useState<unknown>(null);

  if (req.loading && !req.data) return <Loading />;
  if (!req.data) return <ErrorBox error={req.error} />;
  const r = req.data;
  const open = OPEN.includes(r.status);

  async function setStatus(status: "IN_REVIEW") {
    setError(null);
    try {
      await api.patch(`/api/v1/assessment-requests/${r.id}`, { status });
      req.reload();
    } catch (err) {
      setError(err);
    }
  }

  return (
    <div className="stack">
      <div>
        <Link href="/requests" className="muted small">
          ← {t("req.title")}
        </Link>
        <div className="page-header" style={{ marginTop: 6 }}>
          <div>
            <h1>
              {r.submitted_name} <span className="muted small">{r.reference}</span>
            </h1>
            <p className="muted">
              {formatDateTime(r.created_at)} · {t(`reqSource.${r.source}` as MessageKey)}
            </p>
          </div>
          <div className="row">
            <StatusBadge
              status={{ NEW: "IN_PROGRESS", IN_REVIEW: "PLANNED", CONVERTED: "COMPLETED", REJECTED: "CANCELLED", SPAM: "CANCELLED" }[r.status]}
              label={t(`reqStatus.${r.status}` as MessageKey)}
            />
            {r.status === "NEW" && (
              <button className="btn" onClick={() => void setStatus("IN_REVIEW")}>
                {t("req.startReview")}
              </button>
            )}
            {(r.status === "REJECTED" || r.status === "SPAM") && (
              <button className="btn" onClick={() => void setStatus("IN_REVIEW")}>
                {t("req.reopen")}
              </button>
            )}
            {open && (
              <>
                <button className="btn danger" onClick={() => setRejecting("reject")}>
                  {t("req.reject")}
                </button>
                <button className="btn danger" onClick={() => setRejecting("spam")}>
                  {t("req.spam")}
                </button>
              </>
            )}
          </div>
        </div>
      </div>
      <ErrorBox error={error} />

      {r.status === "CONVERTED" && r.project_id != null && (
        <div className="alert ok">
          {t("req.converted")}{" "}
          <Link href="/projects" className="btn link">
            → {t("nav.projects")}
          </Link>
        </div>
      )}

      <div className="grid-2">
        <Submitted r={r} />
        {r.status !== "CONVERTED" && <Review r={r} onSaved={req.reload} />}
      </div>

      {open && <Convert r={r} onDone={req.reload} />}

      {rejecting && (
        <RejectModal
          request={r}
          spam={rejecting === "spam"}
          onClose={() => setRejecting(null)}
          onDone={() => {
            setRejecting(null);
            req.reload();
          }}
        />
      )}
    </div>
  );
}

function Submitted({ r }: { r: Request }) {
  const { t } = useI18n();
  const rows: [MessageKey, React.ReactNode][] = [
    ["common.company", r.submitted_company],
    ["common.phone", r.submitted_phone && <a href={`tel:${r.submitted_phone}`}>{r.submitted_phone}</a>],
    ["common.email", r.submitted_email && <a href={`mailto:${r.submitted_email}`}>{r.submitted_email}</a>],
    ["projects.service", r.submitted_service],
    ["req.projectType", r.project_type],
    ["req.language", r.locale],
  ];
  return (
    <section className="card stack" style={{ gap: 8 }}>
      <h2>{t("req.submitted")}</h2>
      {rows.map(([label, value]) => (
        <div key={label}>
          <span className="muted small">{t(label)}: </span>
          {value || t("common.none")}
        </div>
      ))}
      <div>
        <div className="muted small">{t("req.message")}</div>
        <p style={{ whiteSpace: "pre-wrap" }}>{r.message}</p>
      </div>
    </section>
  );
}

function Review({ r, onSaved }: { r: Request; onSaved: () => void }) {
  const { t, locale } = useI18n();
  const services = useApi<Service[]>("/api/v1/services");
  const [form, setForm] = useState({
    service_slug: r.service_slug ?? "",
    site_address: r.site_address ?? "",
    preferred_date: r.preferred_date ?? "",
    review_note: r.review_note ?? "",
  });
  const [error, setError] = useState<unknown>(null);
  const [saved, setSaved] = useState(false);

  async function submit(e: FormEvent) {
    e.preventDefault();
    setError(null);
    setSaved(false);
    try {
      const body: Schemas["RequestPatch"] = {
        service_slug: form.service_slug || null,
        site_address: form.site_address.trim() || null,
        preferred_date: form.preferred_date || null,
        review_note: form.review_note.trim() || null,
      };
      await api.patch(`/api/v1/assessment-requests/${r.id}`, body);
      setSaved(true);
      onSaved();
    } catch (err) {
      setError(err);
    }
  }

  return (
    <form className="card stack" style={{ gap: 8 }} onSubmit={submit}>
      <h2>{t("req.review")}</h2>
      <Field label={t("projects.service")}>
        <select value={form.service_slug} onChange={(e) => setForm({ ...form, service_slug: e.target.value })}>
          <option value="">{t("common.none")}</option>
          {(services.data ?? []).map((s) => (
            <option key={s.slug} value={s.slug}>
              {serviceName(s, locale)}
            </option>
          ))}
        </select>
      </Field>
      <Field label={t("common.address")}>
        <input value={form.site_address} onChange={(e) => setForm({ ...form, site_address: e.target.value })} />
      </Field>
      <Field label={t("req.preferredDate")}>
        <input type="date" value={form.preferred_date} onChange={(e) => setForm({ ...form, preferred_date: e.target.value })} />
      </Field>
      <Field label={t("req.note")}>
        <textarea value={form.review_note} onChange={(e) => setForm({ ...form, review_note: e.target.value })} />
      </Field>
      <ErrorBox error={error} />
      {saved && <div className="alert ok">{t("common.saved")}</div>}
      <div className="row" style={{ justifyContent: "flex-end" }}>
        <button type="submit" className="btn">
          {t("common.save")}
        </button>
      </div>
    </form>
  );
}

type Mode = "new" | "existing" | "none";

function Convert({ r, onDone }: { r: Request; onDone: () => void }) {
  const { t, locale } = useI18n();
  const services = useApi<Service[]>("/api/v1/services");
  const companies = useApi<Company[]>("/api/v1/companies?limit=200");
  const [companyMode, setCompanyMode] = useState<Mode>(r.submitted_company ? "new" : "none");
  const [companyId, setCompanyId] = useState("");
  const [company, setCompany] = useState({ name: r.submitted_company ?? "", tax_id: "" });
  const existingCompany = companyMode === "existing" && companyId ? companyId : null;
  const contacts = useApi<Contact[]>(existingCompany ? `/api/v1/contacts?company_id=${existingCompany}&limit=200` : null);
  const sites = useApi<Site[]>(`/api/v1/sites?limit=200${existingCompany ? `&company_id=${existingCompany}` : ""}`);
  const [contactMode, setContactMode] = useState<"new" | "existing">("new");
  const [contactId, setContactId] = useState("");
  const [contact, setContact] = useState({
    full_name: r.submitted_name,
    phone: r.submitted_phone ?? "",
    email: r.submitted_email ?? "",
    position: "",
  });
  const [siteMode, setSiteMode] = useState<"new" | "existing">("new");
  const [siteId, setSiteId] = useState("");
  const [site, setSite] = useState({
    name: "",
    address: r.site_address ?? "",
    latitude: r.latitude != null ? Number(r.latitude) : null,
    longitude: r.longitude != null ? Number(r.longitude) : null,
  });
  const [project, setProject] = useState({
    name: r.submitted_company || r.submitted_name,
    service_slug: r.service_slug ?? "",
    status: "LEAD" as "LEAD" | "SURVEY",
  });
  const [error, setError] = useState<unknown>(null);
  const [message, setMessage] = useState<string | null>(null);
  const [busy, setBusy] = useState(false);

  async function submit(e: FormEvent) {
    e.preventDefault();
    setError(null);
    setMessage(null);
    if (siteMode === "new" && (site.latitude == null || site.longitude == null)) {
      setMessage(t("sites.pinMissing"));
      return;
    }
    setBusy(true);
    try {
      const body: Schemas["ConvertIn"] = {
        company_id: existingCompany ? Number(existingCompany) : null,
        new_company:
          companyMode === "new" ? { name: company.name.trim(), tax_id: company.tax_id.trim() || null } : null,
        contact_id: contactMode === "existing" && contactId ? Number(contactId) : null,
        new_contact:
          contactMode === "new"
            ? {
                full_name: contact.full_name.trim(),
                phone: contact.phone.trim() || null,
                email: contact.email.trim() || null,
                position: contact.position.trim() || null,
              }
            : null,
        site_id: siteMode === "existing" ? Number(siteId) : null,
        new_site:
          siteMode === "new"
            ? {
                name: site.name.trim(),
                address: site.address.trim(),
                latitude: String(site.latitude),
                longitude: String(site.longitude),
              }
            : null,
        project: { name: project.name.trim(), service_slug: project.service_slug, status: project.status },
      };
      await api.post(`/api/v1/assessment-requests/${r.id}/convert`, body);
      onDone();
    } catch (err) {
      setError(err);
      setBusy(false);
    }
  }

  const modeSelect = <M extends string>(value: M, options: [M, MessageKey][], onChange: (m: M) => void) => (
    <div className="segmented">
      {options.map(([m, label]) => (
        <button key={m} type="button" className={`btn${m === value ? " primary" : ""}`} onClick={() => onChange(m)}>
          {t(label)}
        </button>
      ))}
    </div>
  );

  return (
    <form className="card stack" onSubmit={submit}>
      <h2>{t("req.convert")}</h2>
      <p className="muted small">{t("req.convertHint")}</p>

      <h3>{t("common.company")}</h3>
      {modeSelect<Mode>(
        companyMode,
        [
          ["new", "req.new"],
          ["existing", "req.existing"],
          ["none", "req.privatePerson"],
        ],
        (m) => {
          setCompanyMode(m);
          if (m !== "existing") setContactMode("new");
        },
      )}
      {companyMode === "new" && (
        <div className="grid-2">
          <Field label={t("common.name")}>
            <input required value={company.name} onChange={(e) => setCompany({ ...company, name: e.target.value })} />
          </Field>
          <Field label={`${t("companies.taxId")} (${t("common.optional")})`}>
            <input value={company.tax_id} onChange={(e) => setCompany({ ...company, tax_id: e.target.value })} />
          </Field>
        </div>
      )}
      {companyMode === "existing" && (
        <Field label={t("common.company")}>
          <select required value={companyId} onChange={(e) => setCompanyId(e.target.value)}>
            <option value="" disabled>
              —
            </option>
            {(companies.data ?? []).map((c) => (
              <option key={c.id} value={c.id}>
                {c.name}
              </option>
            ))}
          </select>
        </Field>
      )}

      <h3>{t("req.contactPerson")}</h3>
      {existingCompany &&
        modeSelect<"new" | "existing">(
          contactMode,
          [
            ["new", "req.new"],
            ["existing", "req.existing"],
          ],
          setContactMode,
        )}
      {contactMode === "new" ? (
        <div className="grid-2">
          <Field label={t("common.name")}>
            <input required value={contact.full_name} onChange={(e) => setContact({ ...contact, full_name: e.target.value })} />
          </Field>
          <Field label={`${t("req.position")} (${t("common.optional")})`}>
            <input value={contact.position} onChange={(e) => setContact({ ...contact, position: e.target.value })} />
          </Field>
          <Field label={t("common.phone")}>
            <input value={contact.phone} onChange={(e) => setContact({ ...contact, phone: e.target.value })} />
          </Field>
          <Field label={t("common.email")}>
            <input type="email" value={contact.email} onChange={(e) => setContact({ ...contact, email: e.target.value })} />
          </Field>
        </div>
      ) : (
        <Field label={t("req.contactPerson")}>
          <select required value={contactId} onChange={(e) => setContactId(e.target.value)}>
            <option value="" disabled>
              —
            </option>
            {(contacts.data ?? []).map((c) => (
              <option key={c.id} value={c.id}>
                {c.full_name}
                {c.phone ? ` · ${c.phone}` : ""}
              </option>
            ))}
          </select>
        </Field>
      )}

      <h3>{t("projects.site")}</h3>
      {modeSelect<"new" | "existing">(
        siteMode,
        [
          ["new", "req.new"],
          ["existing", "req.existing"],
        ],
        setSiteMode,
      )}
      {siteMode === "new" ? (
        <div className="stack" style={{ gap: 8 }}>
          <div className="grid-2">
            <Field label={t("common.name")}>
              <input required value={site.name} placeholder="Building A" onChange={(e) => setSite({ ...site, name: e.target.value })} />
            </Field>
            <Field label={t("common.address")}>
              <input required value={site.address} onChange={(e) => setSite({ ...site, address: e.target.value })} />
            </Field>
          </div>
          <SiteMap
            lat={site.latitude}
            lng={site.longitude}
            radius={150}
            onPick={(lat, lng) => setSite({ ...site, latitude: lat, longitude: lng })}
          />
          <p className="muted small">{t("sites.mapHint")}</p>
        </div>
      ) : (
        <Field label={t("projects.site")}>
          <select required value={siteId} onChange={(e) => setSiteId(e.target.value)}>
            <option value="" disabled>
              —
            </option>
            {(sites.data ?? []).map((s) => (
              <option key={s.id} value={s.id}>
                {s.name} · {s.address}
              </option>
            ))}
          </select>
        </Field>
      )}

      <h3>{t("jobs.project")}</h3>
      <div className="grid-2">
        <Field label={t("common.name")}>
          <input required value={project.name} onChange={(e) => setProject({ ...project, name: e.target.value })} />
        </Field>
        <Field label={t("projects.service")}>
          <select required value={project.service_slug} onChange={(e) => setProject({ ...project, service_slug: e.target.value })}>
            <option value="" disabled>
              —
            </option>
            {(services.data ?? []).map((s) => (
              <option key={s.slug} value={s.slug}>
                {serviceName(s, locale)}
              </option>
            ))}
          </select>
        </Field>
        <Field label={t("req.startAs")}>
          <select
            value={project.status}
            onChange={(e) => setProject({ ...project, status: e.target.value as "LEAD" | "SURVEY" })}
          >
            <option value="LEAD">{t("projectStatus.LEAD")}</option>
            <option value="SURVEY">{t("projectStatus.SURVEY")}</option>
          </select>
        </Field>
      </div>

      {message && <div className="alert">{message}</div>}
      <ErrorBox error={error} />
      <div className="row" style={{ justifyContent: "flex-end" }}>
        <button type="submit" className="btn primary" disabled={busy}>
          {t("req.convertButton")}
        </button>
      </div>
    </form>
  );
}

function RejectModal({
  request,
  spam,
  onClose,
  onDone,
}: {
  request: Request;
  spam: boolean;
  onClose: () => void;
  onDone: () => void;
}) {
  const { t } = useI18n();
  const [reason, setReason] = useState(spam ? "Spam" : "");
  const [error, setError] = useState<unknown>(null);

  async function submit(e: FormEvent) {
    e.preventDefault();
    try {
      await api.post(`/api/v1/assessment-requests/${request.id}/reject`, { reason, spam });
      onDone();
    } catch (err) {
      setError(err);
    }
  }

  return (
    <Modal open title={spam ? t("req.spam") : t("req.reject")} onClose={onClose}>
      <form className="stack" onSubmit={submit}>
        <Field label={t("req.reason")}>
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
