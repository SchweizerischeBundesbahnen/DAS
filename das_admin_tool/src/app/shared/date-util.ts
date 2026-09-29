export function toUtcDateOnly(date: Date): Date {
  return new Date(Date.UTC(date.getFullYear(), date.getMonth(), date.getDate()));
}

// Used to mark strings which contain dates
export type DateString = string;
