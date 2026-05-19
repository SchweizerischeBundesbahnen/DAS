import {httpResource} from '@angular/common/http';
import {Injectable} from '@angular/core';
import {environment} from '../../../environments/environment';
import {ApiResponse} from '../api-response';

export interface Company {
  code: string;
  name: string;
}

type CompanyApiResponse = ApiResponse<Company[]>;

@Injectable({
  providedIn: 'root',
})
export class CompaniesApi {
  private readonly url = `${environment.backendUrl}/v1/companies`;

  readonly companies = httpResource<CompanyApiResponse>(() => this.url);
}
