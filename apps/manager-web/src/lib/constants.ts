// Enum values used in forms (mirrors the API; labels live in the i18n dictionaries).
export const JOB_TYPES = ["INSTALLATION", "DISMANTLING", "INSPECTION", "MAINTENANCE", "SURVEY"] as const;
export type JobType = (typeof JOB_TYPES)[number];
