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

export type HolidayType = 'SUNDAY' | 'MONDAY';

export const HOLIDAY_TYPE_LABELS: { value: HolidayType, label: string } [] = [
  {
    value: 'SUNDAY',
    label: $localize`:@@holidays_type_sunday:Sonntag`
  },
  {
    value: 'MONDAY',
    label: $localize`:@@holidays_type_monday:Montag`
  }];


export interface Holiday {
  id?: number;
  name: string;
  validAt: Date;
  type: HolidayType;
  companies: string[];
}

export type HolidayApiResponse = ApiResponse<Holiday[]>;

export interface Company {
  name: string;
  code: string;
}

export type CompanyApiResponse = ApiResponse<Company[]>;

@Injectable({
  providedIn: 'root',
})
export class RuAdminApi {
  private readonly httpClient = inject(HttpClient);
  private readonly noticeTemplatesUrl = `${environment.backendUrl}/v1/notice-templates`;
  readonly noticeTemplates = httpResource<NoticeTemplateApiResponse>(() => this.noticeTemplatesUrl);
  private readonly holidaysUrl = `${environment.backendUrl}/v1/holidays`;
  readonly holidays = httpResource<HolidayApiResponse>(() => this.holidaysUrl);
  private readonly companiesUrl = `${environment.backendUrl}/v1/companies`;
  readonly companies = httpResource<CompanyApiResponse>(() => this.companiesUrl);

  postNoticeTemplate(noticeTemplate: NoticeTemplate): Observable<NoticeTemplateApiResponse> {
    return this.httpClient.post<NoticeTemplateApiResponse>(this.noticeTemplatesUrl, noticeTemplate);
  }

  putNoticeTemplate(id: number, noticeTemplate: NoticeTemplate): Observable<NoticeTemplateApiResponse> {
    return this.httpClient.put<NoticeTemplateApiResponse>(`${this.noticeTemplatesUrl}/${id}`, noticeTemplate);
  }

  deleteNoticeTemplate(id: number): Observable<void> {
    return this.httpClient.delete<void>(`${this.noticeTemplatesUrl}/${id}`);
  }

  deleteAllNoticeTemplate(ids: number[]): Observable<void> {
    return this.httpClient.delete<void>(this.noticeTemplatesUrl, {body: {ids}});
  }

  postHoliday(holiday: Holiday): Observable<HolidayApiResponse> {
    return this.httpClient.post<HolidayApiResponse>(this.holidaysUrl, holiday);
  }

  putHoliday(id: number, holiday: Holiday): Observable<HolidayApiResponse> {
    return this.httpClient.put<HolidayApiResponse>(`${this.holidaysUrl}/${id}`, holiday);
  }

  deleteHoliday(id: number): Observable<void> {
    return this.httpClient.delete<void>(`${this.holidaysUrl}/${id}`);
  }

  deleteAllHolidays(ids: number[]): Observable<void> {
    return this.httpClient.delete<void>(this.holidaysUrl, {body: {ids}});
  }
}
