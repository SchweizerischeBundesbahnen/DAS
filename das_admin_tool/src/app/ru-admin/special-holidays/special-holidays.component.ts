import { Component, inject } from '@angular/core';
import { SbbSecondaryButton } from '@sbb-esta/lyne-angular/button/secondary-button';
import { SbbLoadingIndicatorCircle } from '@sbb-esta/lyne-angular/loading-indicator-circle';
import { SbbTitle } from '@sbb-esta/lyne-angular/title';
import { SpecialHolidayService } from './special-holiday.service';
import { SpecialHolidaysTable } from './special-holidays-table/special-holidays-table.component';

@Component({
  selector: 'app-special-holidays',
  imports: [SpecialHolidaysTable, SbbLoadingIndicatorCircle, SbbSecondaryButton, SbbTitle],
  templateUrl: './special-holidays.component.html',
  styleUrl: './special-holidays.component.css',
})
export class SpecialHolidays {
  protected readonly specialHolidayService = inject(SpecialHolidayService);
  protected readonly specialHolidays = this.specialHolidayService.specialHolidaysResource;
}
