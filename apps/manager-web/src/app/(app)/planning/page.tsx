"use client";

// Planning timeline (ARCHITECTURE §14a). Two modes of one screen:
// - by project: planned period (dashed), net on site (solid), jobs with their visits
// - by worker: who is booked when (GET /schedule)
// Read-only in v1: a bar opens its job, where visits and crews are edited.
// Mode, zoom and start date live in the URL.

import { usePathname, useRouter, useSearchParams } from "next/navigation";
import { useState } from "react";

import { Bar, Scale, Timeline, TimelineRow, ZOOMS, type Zoom } from "@/components/timeline";
import { Empty, ErrorBox, Loading, PageHeader, StatusBadge } from "@/components/ui";
import type { Schemas } from "@/lib/api/client";
import { JOB_TYPES } from "@/lib/constants";
import { addDays, formatDate, formatTime, yerevanDate, yerevanInstant } from "@/lib/format";
import { useI18n } from "@/lib/i18n";
import type { MessageKey } from "@/lib/i18n/en";
import { useApi } from "@/lib/use-api";

type Project = Schemas["PlanningProjectOut"];
type Visit = Schemas["PlanningVisitOut"];
type Entry = Schemas["ScheduleEntryOut"];
type Worker = Schemas["WorkerOut"];

const MODES = ["projects", "workers"] as const;
type Mode = (typeof MODES)[number];
const ZOOM_KEYS = Object.keys(ZOOMS) as Zoom[];
const ZOOM_LABEL: Record<Zoom, MessageKey> = {
  "2w": "planning.zoom2w",
  "3m": "planning.zoom3m",
  "1y": "planning.zoom1y",
};
const DATE_RE = /^\d{4}-\d{2}-\d{2}$/;

export default function PlanningPage() {
  const { t } = useI18n();
  const router = useRouter();
  const pathname = usePathname();
  const params = useSearchParams();
  const today = yerevanDate();
  const mode: Mode = MODES.find((m) => m === params.get("mode")) ?? "projects";
  const zoom: Zoom = ZOOM_KEYS.find((z) => z === params.get("zoom")) ?? "3m";
  const startParam = params.get("start");
  const start =
    startParam && DATE_RE.test(startParam) ? startParam : addDays(today, -ZOOMS[zoom].lead);
  const scale = new Scale(start, zoom);

  const set = (patch: Record<string, string | null>) => {
    const next = new URLSearchParams(params.toString());
    for (const [k, v] of Object.entries(patch)) {
      if (v === null) next.delete(k);
      else next.set(k, v);
    }
    router.replace(`${pathname}?${next.toString()}`);
  };
  const shift = (direction: 1 | -1) =>
    set({ start: addDays(start, direction * Math.round(ZOOMS[zoom].days / 2)) });

  return (
    <div className="stack">
      <PageHeader title={t("planning.title")} />
      <div className="card row" style={{ justifyContent: "space-between" }}>
        <div className="segmented" role="group" aria-label={t("planning.title")}>
          {MODES.map((m) => (
            <button
              key={m}
              className={`btn${m === mode ? " primary" : ""}`}
              onClick={() => set({ mode: m })}
            >
              {t(m === "projects" ? "planning.byProject" : "planning.byWorker")}
            </button>
          ))}
        </div>
        <div className="row">
          <button className="btn" aria-label={t("planning.earlier")} onClick={() => shift(-1)}>
            ←
          </button>
          <button className="btn" onClick={() => set({ start: null })}>
            {t("planning.today")}
          </button>
          <button className="btn" aria-label={t("planning.later")} onClick={() => shift(1)}>
            →
          </button>
          <span className="muted small">
            {formatDate(`${scale.start}T12:00:00Z`)} – {formatDate(`${scale.end}T12:00:00Z`)}
          </span>
        </div>
        <div className="segmented" role="group">
          {ZOOM_KEYS.map((z) => (
            <button
              key={z}
              className={`btn${z === zoom ? " primary" : ""}`}
              onClick={() => set({ zoom: z, start: null })}
            >
              {t(ZOOM_LABEL[z])}
            </button>
          ))}
        </div>
      </div>

      <div className="card" style={{ padding: 0, overflow: "hidden" }}>
        {mode === "projects" ? <ProjectsView scale={scale} /> : <WorkersView scale={scale} />}
      </div>
      <Legend mode={mode} />
    </div>
  );
}

function visitTitle(v: Visit, t: ReturnType<typeof useI18n>["t"]): string {
  const crew = v.crew.length ? v.crew.join(", ") : t("planning.noCrew");
  return `${formatDate(v.starts_at)} ${formatTime(v.starts_at)}–${formatTime(v.ends_at)}\n${crew}\n${t(
    `visitStatus.${v.status}` as MessageKey,
  )}`;
}

function ProjectsView({ scale }: { scale: Scale }) {
  const { t } = useI18n();
  const projects = useApi<Project[]>(`/api/v1/planning/projects?from=${scale.start}&to=${scale.end}`);
  const [collapsed, setCollapsed] = useState<Set<number>>(new Set());
  const now = new Date().toISOString();

  if (projects.loading && !projects.data) return <Loading />;
  if (!projects.data) return <ErrorBox error={projects.error} />;
  if (projects.data.length === 0) return <Empty text={t("planning.noProjects")} />;

  const toggle = (id: number) =>
    setCollapsed((s) => {
      const next = new Set(s);
      if (next.has(id)) next.delete(id);
      else next.add(id);
      return next;
    });

  return (
    <Timeline scale={scale} now={now}>
      {projects.data.map((p) => {
        const open = !collapsed.has(p.id);
        const tone = p.dismantle_overdue ? " overdue" : p.dismantle_soon ? " soon" : "";
        const planned =
          p.expected_install_date != null
            ? {
                from: yerevanInstant(p.expected_install_date, "00:00"),
                to: p.expected_dismantle_date
                  ? yerevanInstant(addDays(p.expected_dismantle_date, 1), "00:00")
                  : yerevanInstant(addDays(scale.end, 1), "00:00"),
              }
            : null;
        return (
          <div key={p.id}>
            <TimelineRow
              scale={scale}
              label={
                <button className="tl-project" onClick={() => toggle(p.id)} aria-expanded={open}>
                  <span className="tl-caret">{open ? "▾" : "▸"}</span>
                  <span className="tl-name">
                    <strong>{p.reference}</strong> {p.name}
                    <span className="muted small tl-sub">
                      {[p.company_name, p.site_name].filter(Boolean).join(" · ")}
                    </span>
                    <span className="flags">
                      <StatusBadge status={p.status} label={t(`projectStatus.${p.status}` as MessageKey)} />
                      {p.dismantle_overdue && <span className="badge bad">{t("planning.overdue")}</span>}
                      {p.dismantle_soon && <span className="badge warn">{t("planning.soon")}</span>}
                      {p.unstaffed_visits > 0 && (
                        <span className="badge warn">{t("planning.unstaffed", { n: p.unstaffed_visits })}</span>
                      )}
                    </span>
                  </span>
                </button>
              }
            >
              {planned && (
                <Bar
                  scale={scale}
                  {...planned}
                  className="planned"
                  title={t("planning.plannedPeriod", {
                    from: formatDate(planned.from),
                    to: p.expected_dismantle_date ? formatDate(`${p.expected_dismantle_date}T12:00:00Z`) : "…",
                  })}
                />
              )}
              {p.on_site_from && (
                <Bar
                  scale={scale}
                  from={p.on_site_from}
                  to={p.on_site_to ?? now}
                  className={`onsite${tone}`}
                  title={t("planning.onSiteSince", { date: formatDate(p.on_site_from) })}
                />
              )}
            </TimelineRow>
            {open &&
              p.jobs.map((j) => (
                <TimelineRow
                  key={j.id}
                  sub
                  scale={scale}
                  label={
                    <span className="tl-job">
                      <span className={`dot jt-${j.job_type}`} />
                      <span className="tl-name">
                        {j.title}
                        <span className="muted small tl-sub">
                          {t(`jobType.${j.job_type}` as MessageKey)} · {t(`jobStatus.${j.status}` as MessageKey)}
                        </span>
                      </span>
                    </span>
                  }
                >
                  {j.visits.map((v) => (
                    <Bar
                      key={v.id}
                      scale={scale}
                      from={v.starts_at}
                      to={v.ends_at}
                      href={`/jobs/${j.id}`}
                      className={`visit jt-${j.job_type}${v.crew.length ? "" : " unstaffed"}${
                        v.status === "DONE" ? " done" : ""
                      }`}
                      title={visitTitle(v, t)}
                    >
                      {scale.zoom === "2w" && v.crew.length > 0 && <span>{v.crew.length}</span>}
                    </Bar>
                  ))}
                </TimelineRow>
              ))}
          </div>
        );
      })}
    </Timeline>
  );
}

function WorkersView({ scale }: { scale: Scale }) {
  const { t } = useI18n();
  const from = encodeURIComponent(yerevanInstant(scale.start, "00:00"));
  const to = encodeURIComponent(yerevanInstant(addDays(scale.end, 1), "00:00"));
  const workers = useApi<Worker[]>("/api/v1/workers?active=true");
  const entries = useApi<Entry[]>(`/api/v1/schedule?from=${from}&to=${to}`);
  const now = new Date().toISOString();

  if ((workers.loading && !workers.data) || (entries.loading && !entries.data)) return <Loading />;
  if (!workers.data || !entries.data) return <ErrorBox error={workers.error ?? entries.error} />;
  if (workers.data.length === 0) return <Empty />;

  const byWorker = new Map<number, Entry[]>();
  for (const e of entries.data) byWorker.set(e.worker_id, [...(byWorker.get(e.worker_id) ?? []), e]);

  return (
    <Timeline scale={scale} now={now}>
      {workers.data.map((w) => {
        const own = byWorker.get(w.id) ?? [];
        return (
          <TimelineRow
            key={w.id}
            scale={scale}
            label={
              <span className="tl-name">
                <strong>{w.full_name}</strong>
                <span className="muted small tl-sub">
                  {w.employee_code} · {t("planning.tasks", { n: own.length })}
                </span>
              </span>
            }
          >
            {own.map((e) => (
              <Bar
                key={e.assignment_id}
                scale={scale}
                from={e.starts_at}
                to={e.ends_at}
                href={`/jobs/${e.job_id}`}
                className={`visit jt-${e.job_type}${e.status === "SUBMITTED" ? " done" : ""}`}
                title={`${e.job_title}\n${formatDate(e.starts_at)} ${formatTime(e.starts_at)}–${formatTime(
                  e.ends_at,
                )}\n${e.role === "LEAD" ? t("jobs.lead") : t("jobs.member")} · ${t(
                  `assignmentStatus.${e.status}` as MessageKey,
                )}`}
              />
            ))}
          </TimelineRow>
        );
      })}
    </Timeline>
  );
}

function Legend({ mode }: { mode: Mode }) {
  const { t } = useI18n();
  return (
    <div className="row muted small legend">
      {JOB_TYPES.map((type) => (
        <span key={type} className="row" style={{ gap: 6 }}>
          <span className={`dot jt-${type}`} />
          {t(`jobType.${type}`)}
        </span>
      ))}
      {mode === "projects" && (
        <>
          <span className="row" style={{ gap: 6 }}>
            <span className="swatch planned" />
            {t("planning.legendPlanned")}
          </span>
          <span className="row" style={{ gap: 6 }}>
            <span className="swatch onsite" />
            {t("planning.legendOnSite")}
          </span>
          <span className="row" style={{ gap: 6 }}>
            <span className="swatch unstaffed" />
            {t("planning.noCrew")}
          </span>
        </>
      )}
    </div>
  );
}
