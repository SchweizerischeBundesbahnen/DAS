import {Injectable} from '@angular/core';

@Injectable({
  providedIn: 'root',
})
export class RecentCompaniesStore {
  private readonly storageKey = 'recent_companies'

  get(): string[] {
    const raw = localStorage.getItem(this.storageKey);
    if (!raw) {
      return [];
    }

    try {
      const parsed = JSON.parse(raw);
      return Array.isArray(parsed)
        ? parsed.filter((value): value is string => typeof value === 'string')
        : [];
    } catch {
      return [];
    }
  }

  save(companyCodes: string[]): void {
    localStorage.setItem(this.storageKey, JSON.stringify(companyCodes));
  }
}

