"use client";

// A small Gantt-style timeline (ARCHITECTURE §14a): a date axis, rows with a sticky
// label and a lane, absolutely positioned bars, a "today" line. Our own component
// on purpose: < 50 rows, Yerevan dates, hy/ru/en, our CSS (no Gantt library).

import Link from "next/link";
import type { CSSProperties, ReactNode } from "react";

import { addDays } from "@/lib/format";

const DAY_MS = 86_400_000;
export const LABEL_W = 280;

export type Zoom = "2w" | "3m" | "1y";

export const ZOOMS: Record<Zoom, { days: number; dayW: number; lead: number }> = {
  "2w": { days: 14, dayW: 72, lead: 2 }, // lead: days shown before today by default
  "3m": { days: 91, dayW: 14, lead: 7 },
  "1y": { days: 365, dayW: 3.2, lead: 30 },
};

/** Maps instants and Yerevan dates to x positions in the lane. */
export class Scale {
  readonly width: number;
  readonly end: string; // inclusive last day
  private readonly origin: number;

  constructor(
    readonly start: string, // "2026-10-12", Yerevan
    readonly zoom: Zoom,
  ) {
    const { days, dayW } = ZOOMS[zoom];
    this.width = days * dayW;
    this.end = addDays(start, days - 1);
    this.origin = Date.parse(`${start}T00:00:00+04:00`);
  }

  get dayW(): number {
    return ZOOMS[this.zoom].dayW;
  }

  x(iso: string): number {
    return ((Date.parse(iso) - this.origin) / DAY_MS) * this.dayW;
  }

  /** Start of a Yerevan date. */
  xDate(date: string): number {
    return this.x(`${date}T00:00:00+04:00`);
  }
}

function dayOfWeek(date: string): number {
  return new Date(`${date}T00:00:00Z`).getUTCDay(); // 0 = Sunday
}

interface Tick {
  date: string;
  label: string | null;
  strong: boolean;
}

/** Column lines and labels for the zoom level. */
function ticks(scale: Scale): Tick[] {
  const out: Tick[] = [];
  const days = ZOOMS[scale.zoom].days;
  for (let i = 0; i < days; i++) {
    const date = addDays(scale.start, i);
    const [y, m, d] = date.split("-");
    if (scale.zoom === "2w") out.push({ date, label: `${d}.${m}`, strong: dayOfWeek(date) === 1 });
    else if (scale.zoom === "3m" && dayOfWeek(date) === 1)
      out.push({ date, label: `${d}.${m}`, strong: d <= "07" });
    else if (scale.zoom === "1y" && d === "01") out.push({ date, label: `${m}.${y}`, strong: m === "01" });
  }
  return out;
}

export function Timeline({
  scale,
  now,
  children,
}: {
  scale: Scale;
  now: string;
  children: ReactNode;
}) {
  const marks = ticks(scale);
  const today = scale.x(now);
  const weekend =
    scale.zoom === "2w"
      ? Array.from({ length: ZOOMS["2w"].days }, (_, i) => addDays(scale.start, i)).filter(
          (d) => dayOfWeek(d) === 0 || dayOfWeek(d) === 6,
        )
      : [];
  return (
    <div className="tl-scroll">
      <div className="tl-inner" style={{ width: LABEL_W + scale.width }}>
        <div className="tl-grid" style={{ left: LABEL_W, width: scale.width }} aria-hidden>
          {weekend.map((d) => (
            <div key={d} className="tl-weekend" style={{ left: scale.xDate(d), width: scale.dayW }} />
          ))}
          {marks.map((m) => (
            <div key={m.date} className={`tl-line${m.strong ? " strong" : ""}`} style={{ left: scale.xDate(m.date) }} />
          ))}
          {today >= 0 && today <= scale.width && <div className="tl-today" style={{ left: today }} />}
        </div>
        <div className="tl-row tl-head">
          <div className="tl-label" />
          <div className="tl-lane" style={{ width: scale.width }}>
            {marks
              .filter((m) => m.label)
              .map((m) => (
                <span key={m.date} className="tl-tick" style={{ left: scale.xDate(m.date) + 4 }}>
                  {m.label}
                </span>
              ))}
          </div>
        </div>
        {children}
      </div>
    </div>
  );
}

export function TimelineRow({
  label,
  scale,
  children,
  sub = false,
}: {
  label: ReactNode;
  scale: Scale;
  children?: ReactNode;
  sub?: boolean;
}) {
  return (
    <div className={`tl-row${sub ? " sub" : ""}`}>
      <div className="tl-label">{label}</div>
      <div className="tl-lane" style={{ width: scale.width }}>
        {children}
      </div>
    </div>
  );
}

/** A bar from `from` to `to` (ISO instants), clipped to the window. */
export function Bar({
  scale,
  from,
  to,
  className,
  title,
  href,
  minWidth = 6,
  style,
  children,
}: {
  scale: Scale;
  from: string;
  to: string;
  className: string;
  title?: string;
  href?: string;
  minWidth?: number;
  style?: CSSProperties;
  children?: ReactNode;
}) {
  const x1 = scale.x(from);
  const x2 = Math.max(scale.x(to), x1 + minWidth);
  if (x2 <= 0 || x1 >= scale.width) return null;
  const left = Math.max(0, x1);
  const right = Math.min(scale.width, x2);
  const clip = `${x1 < 0 ? " clip-start" : ""}${x2 > scale.width ? " clip-end" : ""}`;
  const props = {
    className: `bar ${className}${clip}`,
    style: { ...style, left, width: right - left },
    title,
  };
  return href ? (
    <Link href={href} {...props}>
      {children}
    </Link>
  ) : (
    <div {...props}>{children}</div>
  );
}
