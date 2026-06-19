import { inject, Injectable } from '@angular/core';
import { HttpClient, httpResource } from '@angular/common/http';
import { environment } from '../../environments/environment';
import { Observable } from 'rxjs';
import { ApiResponse } from '../shared/api-response';
import { Auditable } from '../shared/audit/auditable';

export interface RuIndicationLanguageContent {
  title: string;
  text?: string;

  [key: string]: string | undefined;
}

export interface RuIndicationTemplate extends Auditable {
  id?: number;
  category: string;
  de?: RuIndicationLanguageContent;
  fr?: RuIndicationLanguageContent;
  it?: RuIndicationLanguageContent;
  companies: string[];

  [key: string]: string | string[] | number | Date | RuIndicationLanguageContent | undefined;
}

export type TrainNumberParity = 'ANY' | 'EVEN' | 'ODD';

export interface RuIndicationTrainNumberFilter {
  expression: string;
  parity: TrainNumberParity;
}

export type DayOfWeek =
  | 'MONDAY'
  | 'TUESDAY'
  | 'WEDNESDAY'
  | 'THURSDAY'
  | 'FRIDAY'
  | 'SATURDAY'
  | 'SUNDAY';

export interface RuIndicationPeriod {
  validFrom: Date | string;
  validTo: Date | string;
  weekdays?: DayOfWeek[];
}

export interface RuIndicationScope {
  companies: string[];
  operationalTrainNumberFilters?: RuIndicationTrainNumberFilter[];
  tafTapLocationReferences?: string[];
}

export interface RuIndicationContent {
  category?: string;
  de?: RuIndicationLanguageContent;
  fr?: RuIndicationLanguageContent;
  it?: RuIndicationLanguageContent;
}

export interface RuIndication extends Auditable {
  id?: number;
  status?: RuIndicationStatus;
  content: RuIndicationContent;
  scope: RuIndicationScope;
  periods: RuIndicationPeriod[];
}

export type RuIndicationStatus = 'INACTIVE' | 'ACTIVE' | 'EXPIRED';

export const RU_INDICATION_STATUS_LABELS: { value: RuIndicationStatus; label: string }[] = [
  { value: 'ACTIVE', label: $localize`:@@ru_indication_status_label_active:Aktiv` },
  { value: 'INACTIVE', label: $localize`:@@ru_indication_status_label_inactive:Inaktiv` },
  { value: 'EXPIRED', label: $localize`:@@ru_indication_status_label_expired:Abgelaufen` },
];
export type RuIndicationApiResponse = ApiResponse<RuIndication>;

export type RuIndicationTemplateApiResponse = ApiResponse<RuIndicationTemplate>;

export type ScheduleType = 'SUNDAY_SCHEDULE' | 'MONDAY_SCHEDULE';

export const SCHEDULE_TYPE_LABELS: { value: ScheduleType; label: string }[] = [
  { value: 'SUNDAY_SCHEDULE', label: $localize`:@@special_holidays_schedule_type_sunday:Sonntag` },
  { value: 'MONDAY_SCHEDULE', label: $localize`:@@special_holidays_schedule_type_monday:Montag` },
];

export interface SpecialHoliday extends Auditable {
  id?: number;
  name: string;
  date: Date;
  scheduleType: ScheduleType;
  companies: string[];
}

export type SpecialHolidayApiResponse = ApiResponse<SpecialHoliday>;

interface ExternalLinkContent {
  title: string;
  link: string;
}

export interface ExternalLink extends Auditable {
  id?: number;
  companies: string[];
  de?: ExternalLinkContent;
  fr?: ExternalLinkContent;
  it?: ExternalLinkContent;
}

export type ExternalLinkApiResponse = ApiResponse<ExternalLink>;

@Injectable({ providedIn: 'root' })
export class RuAdminApi {
  private readonly httpClient = inject(HttpClient);
  private readonly ruIndicationsUrl = `${environment.backendUrl}/v1/ruindications`;
  readonly ruIndications = httpResource<RuIndicationApiResponse>(() => this.ruIndicationsUrl);
  private readonly ruIndicationTemplatesUrl = `${environment.backendUrl}/v1/ruindication-templates`;
  readonly ruIndicationTemplates = httpResource<RuIndicationTemplateApiResponse>(
    () => this.ruIndicationTemplatesUrl,
  );
  private readonly specialHolidaysUrl = `${environment.backendUrl}/v1/special-holidays`;
  readonly specialHolidays = httpResource<SpecialHolidayApiResponse>(() => this.specialHolidaysUrl);
  private readonly externalLinksUrl = `${environment.backendUrl}/v1/external-links`;
  readonly externalLinks = httpResource<ExternalLinkApiResponse>(() => this.externalLinksUrl);

  postRuIndicationTemplate(
    ruIndicationTemplate: RuIndicationTemplate,
  ): Observable<RuIndicationTemplateApiResponse> {
    return this.httpClient.post<RuIndicationTemplateApiResponse>(
      this.ruIndicationTemplatesUrl,
      ruIndicationTemplate,
    );
  }

  putRuIndicationTemplate(
    id: number,
    ruIndicationTemplate: RuIndicationTemplate,
  ): Observable<RuIndicationTemplateApiResponse> {
    return this.httpClient.put<RuIndicationTemplateApiResponse>(
      `${this.ruIndicationTemplatesUrl}/${id}`,
      ruIndicationTemplate,
    );
  }

  deleteAllRuIndicationTemplate(ids: number[]): Observable<void> {
    return this.httpClient.delete<void>(this.ruIndicationTemplatesUrl, { body: { ids } });
  }

  postSpecialHoliday(specialHoliday: SpecialHoliday): Observable<SpecialHolidayApiResponse> {
    return this.httpClient.post<SpecialHolidayApiResponse>(this.specialHolidaysUrl, specialHoliday);
  }

  putSpecialHoliday(
    id: number,
    specialHoliday: SpecialHoliday,
  ): Observable<SpecialHolidayApiResponse> {
    return this.httpClient.put<SpecialHolidayApiResponse>(
      `${this.specialHolidaysUrl}/${id}`,
      specialHoliday,
    );
  }

  deleteAllSpecialHolidays(ids: number[]): Observable<void> {
    return this.httpClient.delete<void>(this.specialHolidaysUrl, { body: { ids } });
  }

  postRuIndication(ruIndication: RuIndication): Observable<RuIndicationApiResponse> {
    return this.httpClient.post<RuIndicationApiResponse>(this.ruIndicationsUrl, ruIndication);
  }

  putRuIndication(id: number, ruIndication: RuIndication): Observable<RuIndicationApiResponse> {
    return this.httpClient.put<RuIndicationApiResponse>(
      `${this.ruIndicationsUrl}/${id}`,
      ruIndication,
    );
  }

  deleteAllRuIndications(ids: number[]) {
    return this.httpClient.delete<void>(this.ruIndicationsUrl, { body: { ids } });
  }

  postExternalLink(externalLink: ExternalLink): Observable<ExternalLinkApiResponse> {
    return this.httpClient.post<ExternalLinkApiResponse>(this.externalLinksUrl, externalLink);
  }

  putExternalLink(id: number, externalLink: ExternalLink): Observable<ExternalLinkApiResponse> {
    return this.httpClient.put<ExternalLinkApiResponse>(
      `${this.externalLinksUrl}/${id}`,
      externalLink,
    );
  }

  deleteExternalLinksByIds(ids: number[]): Observable<void> {
    return this.httpClient.delete<void>(this.externalLinksUrl, { body: { ids } });
  }
}
