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

/** "25000.00" → "25 000 ֏" without going through a float. */
export function formatMoney(amount: string | null | undefined): string {
  if (amount == null || amount === "") return "—";
  const [whole, fraction = ""] = amount.split(".");
  const grouped = whole.replace(/\B(?=(\d{3})+(?!\d))/g, " ");
  const cents = fraction.replace(/0+$/, "");
  return `${grouped}${cents ? `.${fraction.padEnd(2, "0")}` : ""} ֏`;
}
