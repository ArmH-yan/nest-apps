"use client";

// Assessment requests (ARCHITECTURE §9, §12): website leads plus leads taken by
// phone. "Open" (new + in review) is the default view; filters live in the URL.

import Link from "next/link";
import { usePathname, useRouter, useSearchParams } from "next/navigation";
import { useState, type FormEvent } from "react";

import { Empty, ErrorBox, Field, Loading, Modal, PageHeader, StatusBadge } from "@/components/ui";
import { api, type Schemas } from "@/lib/api/client";
import { formatDateTime } from "@/lib/format";
import { useI18n } from "@/lib/i18n";
import type { MessageKey } from "@/lib/i18n/en";
import { useApi } from "@/lib/use-api";

type Request = Schemas["RequestOut"];
type Service = Schemas["ServiceOut"];

const SHOW = ["open", "NEW", "IN_REVIEW", "CONVERTED", "REJECTED", "SPAM", "all"] as const;
type Show = (typeof SHOW)[number];

function statusQuery(show: Show): string {
  if (show === "all") return "";
  if (show === "open") return "&status=NEW&status=IN_REVIEW";
  return `&status=${show}`;
}

export default function RequestsPage() {
  const { t } = useI18n();
  const router = useRouter();
  const pathname = usePathname();
  const params = useSearchParams();
  const showParam = params.get("show");
  const show: Show = SHOW.find((s) => s === showParam) ?? "open";
  const q = params.get("q") ?? "";
  const [search, setSearch] = useState(q);
  const [creating, setCreating] = useState(false);
  const rows = useApi<Request[]>(
    `/api/v1/assessment-requests?limit=200${statusQuery(show)}${q ? `&q=${encodeURIComponent(q)}` : ""}`,
  );

  const set = (name: string, value: string) => {
    const next = new URLSearchParams(params.toString());
    if (value) next.set(name, value);
    else next.delete(name);
    router.replace(`${pathname}?${next.toString()}`);
  };

  return (
    <div className="stack">
      <PageHeader
        title={t("req.title")}
        action={
          <button className="btn primary" onClick={() => setCreating(true)}>
            {t("req.newPhone")}
          </button>
        }
      />
      <form
        className="card row"
        style={{ alignItems: "end" }}
        onSubmit={(e) => {
          e.preventDefault();
          set("q", search.trim());
        }}
      >
        <Field label={t("ts.show")}>
          <select value={show} onChange={(e) => set("show", e.target.value)}>
            {SHOW.map((s) => (
              <option key={s} value={s}>
                {s === "open" ? t("req.open") : s === "all" ? t("ts.filterAll") : t(`reqStatus.${s}` as MessageKey)}
              </option>
            ))}
          </select>
        </Field>
        <Field label={t("common.search")}>
          <input value={search} placeholder={t("req.searchHint")} onChange={(e) => setSearch(e.target.value)} />
        </Field>
        <button className="btn" type="submit">
          {t("common.search")}
        </button>
      </form>

      <div className="card">
        <ErrorBox error={rows.error} />
        {rows.loading && !rows.data ? (
          <Loading />
        ) : rows.data?.length ? (
          <table className="list">
            <thead>
              <tr>
                <th>{t("req.received")}</th>
                <th>{t("common.name")}</th>
                <th>{t("req.contact")}</th>
                <th>{t("projects.service")}</th>
                <th>{t("common.status")}</th>
                <th />
              </tr>
            </thead>
            <tbody>
              {rows.data.map((r) => (
                <tr key={r.id}>
                  <td>
                    {formatDateTime(r.created_at)}
                    <div className="muted small">
                      {r.reference} · {t(`reqSource.${r.source}` as MessageKey)}
                    </div>
                  </td>
                  <td>
                    {r.submitted_name}
                    {r.submitted_company && <div className="muted small">{r.submitted_company}</div>}
                  </td>
                  <td>
                    {r.submitted_phone && <div>{r.submitted_phone}</div>}
                    {r.submitted_email && <div className="muted small">{r.submitted_email}</div>}
                  </td>
                  <td>
                    {r.service_slug ? (
                      <ServiceName slug={r.service_slug} />
                    ) : (
                      <span className="muted">{r.submitted_service ?? t("common.none")}</span>
                    )}
                    {r.project_type && <div className="muted small">{r.project_type}</div>}
                  </td>
                  <td>
                    <StatusBadge status={reqTone(r.status)} label={t(`reqStatus.${r.status}` as MessageKey)} />
                  </td>
                  <td style={{ textAlign: "right" }}>
                    <Link href={`/requests/${r.id}`} className="btn">
                      {t("ts.explore")}
                    </Link>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        ) : (
          <Empty text={t("req.none")} />
        )}
      </div>
      {creating && (
        <NewPhoneLead
          onClose={() => setCreating(false)}
          onCreated={(id) => router.push(`/requests/${id}`)}
        />
      )}
    </div>
  );
}

/** Badge colours: the generic tones know NEW/CANCELLED etc., not every request status. */
function reqTone(status: Request["status"]): string {
  return { NEW: "IN_PROGRESS", IN_REVIEW: "PLANNED", CONVERTED: "COMPLETED", REJECTED: "CANCELLED", SPAM: "CANCELLED" }[
    status
  ];
}

function ServiceName({ slug }: { slug: string }) {
  const { locale } = useI18n();
  const services = useApi<Service[]>("/api/v1/services");
  const s = services.data?.find((x) => x.slug === slug);
  if (!s) return <>{slug}</>;
  return <>{locale === "hy" ? s.name_hy : locale === "ru" ? s.name_ru : s.name_en}</>;
}

function NewPhoneLead({ onClose, onCreated }: { onClose: () => void; onCreated: (id: number) => void }) {
  const { t, locale } = useI18n();
  const services = useApi<Service[]>("/api/v1/services");
  const [form, setForm] = useState({ name: "", company: "", phone: "", email: "", service_slug: "", message: "", site_address: "" });
  const [error, setError] = useState<unknown>(null);
  const [busy, setBusy] = useState(false);

  async function submit(e: FormEvent) {
    e.preventDefault();
    setBusy(true);
    setError(null);
    try {
      const body: Schemas["ManualRequestIn"] = {
        source: "phone",
        name: form.name.trim(),
        company: form.company.trim() || null,
        phone: form.phone.trim() || null,
        email: form.email.trim() || null,
        service_slug: form.service_slug || null,
        message: form.message.trim(),
        site_address: form.site_address.trim() || null,
        locale: locale,
      };
      const created = await api.post<Request>("/api/v1/assessment-requests", body);
      onCreated(created.id);
    } catch (err) {
      setError(err);
      setBusy(false);
    }
  }

  return (
    <Modal open title={t("req.newPhone")} onClose={onClose}>
      <form className="stack" onSubmit={submit}>
        <div className="grid-2">
          <Field label={t("common.name")}>
            <input required value={form.name} onChange={(e) => setForm({ ...form, name: e.target.value })} />
          </Field>
          <Field label={t("common.company")}>
            <input value={form.company} onChange={(e) => setForm({ ...form, company: e.target.value })} />
          </Field>
          <Field label={t("common.phone")}>
            <input type="tel" value={form.phone} onChange={(e) => setForm({ ...form, phone: e.target.value })} />
          </Field>
          <Field label={t("common.email")}>
            <input type="email" value={form.email} onChange={(e) => setForm({ ...form, email: e.target.value })} />
          </Field>
        </div>
        <Field label={t("projects.service")}>
          <select value={form.service_slug} onChange={(e) => setForm({ ...form, service_slug: e.target.value })}>
            <option value="">{t("common.none")}</option>
            {(services.data ?? []).map((s) => (
              <option key={s.slug} value={s.slug}>
                {locale === "hy" ? s.name_hy : locale === "ru" ? s.name_ru : s.name_en}
              </option>
            ))}
          </select>
        </Field>
        <Field label={t("common.address")}>
          <input value={form.site_address} onChange={(e) => setForm({ ...form, site_address: e.target.value })} />
        </Field>
        <Field label={t("req.message")}>
          <textarea required value={form.message} onChange={(e) => setForm({ ...form, message: e.target.value })} />
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
