import {inject, Injectable} from '@angular/core';
import {HttpClient, httpResource} from '@angular/common/http';
import {environment} from '../../environments/environment';
import {Observable} from 'rxjs';
import {ApiResponse} from '../shared/api-response';

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

export type ScheduleType = 'SUNDAY_SCHEDULE' | 'MONDAY_SCHEDULE';

export const SCHEDULE_TYPE_LABELS: { value: ScheduleType, label: string } [] = [
  {
    value: 'SUNDAY_SCHEDULE',
    label: $localize`:@@special_holidays_schedule_type_sunday:Sonntag`
  },
  {
    value: 'MONDAY_SCHEDULE',
    label: $localize`:@@special_holidays_schedule_type_monday:Montag`
  }];


export interface SpecialHoliday {
  id?: number;
  name: string;
  date: Date;
  scheduleType: ScheduleType;
  companies: string[];
}

export type SpecialHolidayApiResponse = ApiResponse<SpecialHoliday[]>;

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
  private readonly specialHolidaysUrl = `${environment.backendUrl}/v1/special-holidays`;
  readonly specialHolidays = httpResource<SpecialHolidayApiResponse>(() => this.specialHolidaysUrl);

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

  postSpecialHoliday(specialHoliday: SpecialHoliday): Observable<SpecialHolidayApiResponse> {
    return this.httpClient.post<SpecialHolidayApiResponse>(this.specialHolidaysUrl, specialHoliday);
  }

  putSpecialHoliday(id: number, specialHoliday: SpecialHoliday): Observable<SpecialHolidayApiResponse> {
    return this.httpClient.put<SpecialHolidayApiResponse>(`${this.specialHolidaysUrl}/${id}`, specialHoliday);
  }

  deleteSpecialHoliday(id: number): Observable<void> {
    return this.httpClient.delete<void>(`${this.specialHolidaysUrl}/${id}`);
  }

  deleteAllSpecialHolidays(ids: number[]): Observable<void> {
    return this.httpClient.delete<void>(this.specialHolidaysUrl, {body: {ids}});
  }
}
