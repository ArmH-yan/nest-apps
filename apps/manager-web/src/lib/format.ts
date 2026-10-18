// Display helpers. Times are stored in UTC and always shown in Asia/Yerevan
// (CLAUDE.md). Armenia is UTC+4 all year, so visit times typed by a manager are
// converted with a fixed +04:00 offset. Money is a decimal string ("25000.00").

const TZ = "Asia/Yerevan";
const OFFSET = "+04:00";

/** "18.10.2026" in every language (as in the worker app). Browsers often lack
 * Armenian date data and would fall back to US "10/18/2026". */
export function formatDate(iso: string): string {
  const parts = new Intl.DateTimeFormat("en-GB", {
    timeZone: TZ,
    day: "2-digit",
    month: "2-digit",
    year: "numeric",
  }).formatToParts(new Date(iso));
  const get = (type: string) => parts.find((p) => p.type === type)?.value ?? "";
  return `${get("day")}.${get("month")}.${get("year")}`;
}

export function formatTime(iso: string): string {
  return new Intl.DateTimeFormat("en-GB", {
    timeZone: TZ,
    hour: "2-digit",
    minute: "2-digit",
    hour12: false,
  }).format(new Date(iso));
}

export function formatDateTime(iso: string): string {
  return `${formatDate(iso)} ${formatTime(iso)}`;
}

/** "2026-10-18" in Yerevan. */
export function yerevanDate(iso: string = new Date().toISOString()): string {
  return new Intl.DateTimeFormat("en-CA", { timeZone: TZ }).format(new Date(iso));
}

/** Yerevan date + "HH:MM" → ISO instant with the +04:00 offset (the API needs a zone). */
export function yerevanInstant(date: string, time: string): string {
  return `${date}T${time}:00${OFFSET}`;
}

/** "2026-10-18" + n days (calendar arithmetic, no time zone involved). */
export function addDays(date: string, n: number): string {
  const d = new Date(`${date}T00:00:00Z`);
  d.setUTCDate(d.getUTCDate() + n);
  return d.toISOString().slice(0, 10);
}

/** ISO instant → "2026-10-18T09:00" in Yerevan, for <input type="datetime-local">. */
export function yerevanLocalInput(iso: string): string {
  return `${yerevanDate(iso)}T${formatTime(iso)}`;
}

/** <input type="datetime-local"> value (Yerevan) → ISO instant. */
export function fromLocalInput(value: string): string {
  return `${value}:00${OFFSET}`;
}

/** 27000 → "7:30" (hours:minutes; the same in every language). */
export function formatDuration(seconds: number): string {
  const minutes = Math.round(seconds / 60);
  return `${Math.floor(minutes / 60)}:${String(minutes % 60).padStart(2, "0")}`;
}

/** "25000.00" → "25 000 ֏" without going through a float. */
export function formatMoney(amount: string | null | undefined): string {
  if (amount == null || amount === "") return "—";
  const [whole, fraction = ""] = amount.split(".");
  const grouped = whole.replace(/\B(?=(\d{3})+(?!\d))/g, " ");
  const cents = fraction.replace(/0+$/, "");
  return `${grouped}${cents ? `.${fraction.padEnd(2, "0")}` : ""} ֏`;
}
