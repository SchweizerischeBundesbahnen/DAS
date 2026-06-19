import { httpResource } from '@angular/common/http';
import { computed, effect, inject, Injectable } from '@angular/core';
import { environment } from '../../../environments/environment';
import { ApiResponse } from '../api-response';
import { ToastService } from '../toast-service';

type CompanyApiResponse = ApiResponse<Company>;

export interface Company {
  code: string;
  shortName: string;
}

@Injectable({ providedIn: 'root' })
export class CompanyService {
  private readonly url = `${environment.backendUrl}/companies/authorized`;
  private readonly companiesResource = httpResource<CompanyApiResponse>(() => this.url);
  readonly loaded = computed(
    () => this.companiesResource.hasValue() || !!this.companiesResource.error(),
  );
  private readonly toastService = inject(ToastService);
  private readonly companies = computed(() =>
    this.companiesResource.hasValue() ? this.companiesResource.value()!.data : [],
  );

  constructor() {
    effect(() => {
      if (this.companiesResource.error()) {
        this.toastService.error(
          $localize`:@@company_service_error_loading:Fehler beim Laden der EVUs`,
        );
      }
    });
  }

  public formatCompanies(companies: string[]): string {
    return companies
      .map((companyCode) => this.getName(companyCode) ?? companyCode)
      .sort((a, b) => a.localeCompare(b))
      .join(', ');
  }

  public getName(code: string): string | undefined {
    return this.companies().find((company) => company.code === code)?.shortName;
  }

  public filterCompanies(query: string, excludedCodes: string[] = []): Company[] {
    const allCompanies = this.companies().filter(
      (company) => !excludedCodes.includes(company.code),
    );

    const caseInsensitiveQuery = query.trim().toLowerCase();
    if (!caseInsensitiveQuery) {
      return allCompanies;
    }

    const matching = allCompanies.filter(
      ({ code, shortName }) =>
        code.toLowerCase().includes(caseInsensitiveQuery)
        || shortName.toLowerCase().includes(caseInsensitiveQuery),
    );

    return this.sortByRelevance(matching, caseInsensitiveQuery);
  }

  private sortByRelevance(candidates: Company[], query: string): Company[] {
    return [...candidates].sort((a, b) => {
      const aCode = a.code.toLowerCase();
      const bCode = b.code.toLowerCase();
      const aName = a.shortName.toLowerCase();
      const bName = b.shortName.toLowerCase();

      const aRank = Math.min(this.rank(query, aCode), this.rank(query, aName));
      const bRank = Math.min(this.rank(query, bCode), this.rank(query, bName));

      if (aRank !== bRank) {
        return aRank - bRank;
      }

      return aName.localeCompare(bName);
    });
  }

  private rank(query: string, candidate: string): number {
    if (candidate === query) {
      return 0;
    }
    if (candidate.startsWith(query)) {
      return 1;
    }
    if (candidate.includes(query)) {
      return 2;
    }
    return 3;
  }
}
