import { Component, inject } from '@angular/core';
import { SbbLoadingIndicatorCircle } from '@sbb-esta/lyne-angular/loading-indicator-circle';
import { PageHeader } from '~shared/components/page-header/page-header';
import { SpecialHolidayService } from './special-holiday.service';
import { SpecialHolidaysTable } from './special-holidays-table/special-holidays-table';

@Component({
  selector: 'app-special-holidays',
  imports: [PageHeader, SpecialHolidaysTable, SbbLoadingIndicatorCircle],
  templateUrl: './special-holidays.html',
  styleUrl: './special-holidays.css',
})
export class SpecialHolidays {
  protected readonly specialHolidayService = inject(SpecialHolidayService);

  protected readonly title = $localize`:@@special_holidays_title:Spezielle Feiertage`;
  protected readonly specialHolidays = this.specialHolidayService.specialHolidaysResource;
}
