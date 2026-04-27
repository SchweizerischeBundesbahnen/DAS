import {inject, Injectable} from '@angular/core';
import {HttpClient, httpResource} from '@angular/common/http';
import {environment} from '../../environments/environment';
import {Observable} from 'rxjs';
import {ApiResponse} from '../shared/locations-input/api-response';

export interface NoticeTemplateContent {
  title: string;
  text?: string;

  [key: string]: string | undefined;
}

export interface NoticeTemplate {
  id?: number;
  category: string;
  de?: NoticeTemplateContent;
  fr?: NoticeTemplateContent;
  it?: NoticeTemplateContent;
  lastModifiedBy?: string;

  [key: string]: string | number | NoticeTemplateContent | undefined;
}

export type NoticeTemplateApiResponse = ApiResponse<NoticeTemplate[]>;

@Injectable({
  providedIn: 'root',
})
export class RuAdminApi {
  private readonly httpClient = inject(HttpClient);
  private readonly url = `${environment.backendUrl}/v1/notice-templates`;

  noticeTemplates = httpResource<NoticeTemplateApiResponse>(() => this.url);

  postNoticeTemplate(noticeTemplate: NoticeTemplate): Observable<NoticeTemplateApiResponse> {
    return this.httpClient.post<NoticeTemplateApiResponse>(this.url, noticeTemplate);
  }

  putNoticeTemplate(id: number, noticeTemplate: NoticeTemplate): Observable<NoticeTemplateApiResponse> {
    return this.httpClient.put<NoticeTemplateApiResponse>(`${this.url}/${id}`, noticeTemplate);
  }

  deleteNoticeTemplate(id: number): Observable<void> {
    return this.httpClient.delete<void>(`${this.url}/${id}`);
  }

  deleteAllNoticeTemplate(ids: number[]): Observable<void> {
    return this.httpClient.delete<void>(this.url, {body: {ids}});
  }
}
