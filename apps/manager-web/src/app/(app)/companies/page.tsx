"use client";

import Link from "next/link";
import { useState, type FormEvent } from "react";

import { Empty, ErrorBox, Field, Loading, Modal, PageHeader } from "@/components/ui";
import { api, type Schemas } from "@/lib/api/client";
import { useI18n } from "@/lib/i18n";
import { useApi } from "@/lib/use-api";

type Company = Schemas["CompanyOut"];

export default function CompaniesPage() {
  const { t } = useI18n();
  const [q, setQ] = useState("");
  const list = useApi<Company[]>(`/api/v1/companies?limit=200${q ? `&q=${encodeURIComponent(q)}` : ""}`);
  const [open, setOpen] = useState(false);

  return (
    <div className="stack">
      <PageHeader
        title={t("companies.title")}
        action={
          <button className="btn primary" onClick={() => setOpen(true)}>
            {t("companies.new")}
          </button>
        }
      />
      <input
        placeholder={t("common.search")}
        value={q}
        onChange={(e) => setQ(e.target.value)}
        style={{ maxWidth: 320 }}
      />
      <div className="card">
        <ErrorBox error={list.error} />
        {list.loading && !list.data ? (
          <Loading />
        ) : list.data?.length ? (
          <table className="list">
            <thead>
              <tr>
                <th>{t("common.name")}</th>
                <th>{t("companies.taxId")}</th>
                <th>{t("common.phone")}</th>
                <th>{t("common.address")}</th>
                <th />
              </tr>
            </thead>
            <tbody>
              {list.data.map((c) => (
                <tr key={c.id}>
                  <td>{c.name}</td>
                  <td>{c.tax_id ?? t("common.none")}</td>
                  <td>{c.phone ?? t("common.none")}</td>
                  <td>{c.address ?? t("common.none")}</td>
                  <td style={{ textAlign: "right" }}>
                    <Link href={`/companies/${c.id}`} className="btn">
                      {t("info.button")}
                    </Link>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        ) : (
          <Empty />
        )}
      </div>
      <NewCompany
        open={open}
        onClose={() => setOpen(false)}
        onCreated={() => {
          setOpen(false);
          list.reload();
        }}
      />
    </div>
  );
}

function NewCompany({
  open,
  onClose,
  onCreated,
}: {
  open: boolean;
  onClose: () => void;
  onCreated: () => void;
}) {
  const { t } = useI18n();
  const [form, setForm] = useState({ name: "", tax_id: "", phone: "", email: "", address: "" });
  const [error, setError] = useState<unknown>(null);
  const [busy, setBusy] = useState(false);
  const set = (key: keyof typeof form) => (e: { target: { value: string } }) =>
    setForm((f) => ({ ...f, [key]: e.target.value }));

  async function submit(e: FormEvent) {
    e.preventDefault();
    setBusy(true);
    setError(null);
    try {
      const body: Schemas["CompanyIn"] = {
        name: form.name.trim(),
        tax_id: form.tax_id || null,
        phone: form.phone || null,
        email: form.email || null,
        address: form.address || null,
      };
      await api.post("/api/v1/companies", body);
      setForm({ name: "", tax_id: "", phone: "", email: "", address: "" });
      onCreated();
    } catch (err) {
      setError(err);
    } finally {
      setBusy(false);
    }
  }

  return (
    <Modal open={open} title={t("companies.new")} onClose={onClose}>
      <form className="stack" onSubmit={submit}>
        <Field label={t("common.name")}>
          <input required value={form.name} onChange={set("name")} />
        </Field>
        <div className="grid-2">
          <Field label={t("companies.taxId")}>
            <input value={form.tax_id} onChange={set("tax_id")} />
          </Field>
          <Field label={t("common.phone")}>
            <input type="tel" value={form.phone} onChange={set("phone")} />
          </Field>
        </div>
        <Field label={t("common.email")}>
          <input type="email" value={form.email} onChange={set("email")} />
        </Field>
        <Field label={t("common.address")}>
          <input value={form.address} onChange={set("address")} />
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
