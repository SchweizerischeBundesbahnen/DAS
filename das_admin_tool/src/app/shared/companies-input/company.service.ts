import { httpResource } from '@angular/common/http';
import { computed, Injectable } from '@angular/core';
import { environment } from '~src/environments/environment';
import { ApiResponse } from '../api-response';

type CompanyApiResponse = ApiResponse<Company>;

export interface Company {
	code: string;
	name: string;
}

@Injectable({ providedIn: 'root' })
export class CompanyService {
	private readonly url = `${environment.backendUrl}/v1/companies`;

	private readonly companiesResource = httpResource<CompanyApiResponse>(() => this.url);
	private readonly companies = computed(() => this.companiesResource.value()?.data ?? []);

	public formatCompanies(companies: string[]): string {
		return companies
			.map((companyCode) => this.getName(companyCode) ?? companyCode)
			.toSorted((a, b) => a.localeCompare(b))
			.join(', ');
	}

	public getName(code: string): string | undefined {
		return this.companies().find((company) => company.code === code)?.name;
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
			({ code, name }) => code.toLowerCase().includes(query) || name.toLowerCase().includes(query),
		);

		return this.sortByRelevance(matching, query);
	}

	private sortByRelevance(candidates: Company[], query: string): Company[] {
		return candidates.toSorted((a, b) => {
			const aCode = a.code.toLowerCase();
			const bCode = b.code.toLowerCase();
			const aName = a.name.toLowerCase();
			const bName = b.name.toLowerCase();

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
