import { HttpClient, httpResource } from '@angular/common/http';
import { inject, Service } from '@angular/core';
import { Observable } from 'rxjs';
import { ApiResponse } from '~shared/api-response';
import { Auditable } from '~shared/audit/auditable';
import { environment } from '~src/environments/environment';

export interface AppVersion extends Auditable {
  id?: number;
  version: string;
  minimalVersion: boolean;
  expiryDate?: Date;
}

export type AppVersionApiResponse = ApiResponse<AppVersion>;

export interface InternalCompany extends Auditable {
  id: number;
  code: string;
  shortName: string;
  tenantId: string;
}

export type InternalCompanyApiResponse = ApiResponse<InternalCompany>;

@Service()
export class DasAdminApi {
  private readonly httpClient = inject(HttpClient);

  private readonly appVersionsUrl = `${environment.backendUrl}/app-versions`;
  public readonly appVersions = httpResource<AppVersionApiResponse>(() => this.appVersionsUrl);

  private readonly companiesUrl = `${environment.backendUrl}/companies`;
  public readonly companiesResource = httpResource<InternalCompanyApiResponse>(
    () => this.companiesUrl,
  );

  postAppVersion(version: AppVersion): Observable<AppVersionApiResponse> {
    return this.httpClient.post<AppVersionApiResponse>(this.appVersionsUrl, version);
  }

  putAppVersion(id: number, version: AppVersion): Observable<AppVersionApiResponse> {
    return this.httpClient.put<AppVersionApiResponse>(`${this.appVersionsUrl}/${id}`, version);
  }

  deleteAppVersion(id: number): Observable<void> {
    return this.httpClient.delete<void>(`${this.appVersionsUrl}/${id}`);
  }

  postCompany(company: InternalCompany): Observable<InternalCompanyApiResponse> {
    return this.httpClient.post<InternalCompanyApiResponse>(this.companiesUrl, company);
  }

  putCompany(id: number, company: InternalCompany): Observable<InternalCompanyApiResponse> {
    return this.httpClient.put<InternalCompanyApiResponse>(`${this.companiesUrl}/${id}`, company);
  }

  deleteCompanyById(id: number): Observable<void> {
    return this.httpClient.delete<void>(`${this.companiesUrl}/${id}`);
  }
}
