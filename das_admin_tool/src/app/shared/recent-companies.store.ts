import { inject, Service } from '@angular/core';
import { AuthService } from './auth-service';

@Service()
export class RecentCompaniesStore {
  private readonly authService = inject(AuthService);
  private readonly storageKey = `recent_companies_${this.authService.oid()}`;

  get(): string[] {
    const raw = localStorage.getItem(this.storageKey);
    if (!raw) {
      return [];
    }

    try {
      const parsed: unknown = JSON.parse(raw);
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
