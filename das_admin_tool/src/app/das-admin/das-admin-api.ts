import { HttpClient, httpResource } from '@angular/common/http';
import { inject, Injectable } from '@angular/core';
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

@Injectable({ providedIn: 'root' })
export class DasAdminApi {
	private readonly httpClient = inject(HttpClient);
	private readonly url = `${environment.backendUrl}/v1/settings/app-version`;

	appVersions = httpResource<AppVersionApiResponse>(() => this.url);

	postAppVersion(version: AppVersion): Observable<AppVersionApiResponse> {
		return this.httpClient.post<AppVersionApiResponse>(this.url, version);
	}

	putAppVersion(id: number, version: AppVersion): Observable<AppVersionApiResponse> {
		return this.httpClient.put<AppVersionApiResponse>(`${this.url}/${id}`, version);
	}

	deleteAppVersion(id: number): Observable<void> {
		return this.httpClient.delete<void>(`${this.url}/${id}`);
	}
}
