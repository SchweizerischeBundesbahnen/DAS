import {inject, Injectable} from '@angular/core';
import {HttpClient, httpResource} from '@angular/common/http';
import {environment} from '../../environments/environment';
import {Observable} from 'rxjs';

export interface Response {
  data: AppVersion[];
}

export interface AppVersion {
  id?: number;
  version: string;
  minimalVersion: boolean;
  expiryDate?: Date;
}

@Injectable({
  providedIn: 'root',
})
export class DasAdminApi {
  private httpClient = inject(HttpClient);

  private url = `${environment.backendUrl}/v1/settings/app-version`;

  appVersions = httpResource<Response>(() => this.url);

  postAppVersion(version: AppVersion): Observable<Response> {
    return this.httpClient.post<Response>(this.url, version);
  }

  putAppVersion(id: number, version: AppVersion): Observable<Response> {
    return this.httpClient.put<Response>(`${this.url}/${id}`, version);
  }

  deleteAppVersion(id: number): Observable<void> {
    return this.httpClient.delete<void>(`${this.url}/${id}`);
  }
}
