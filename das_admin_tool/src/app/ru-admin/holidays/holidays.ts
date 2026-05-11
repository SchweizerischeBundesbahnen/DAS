import {Component, inject} from '@angular/core';
import {SbbLoadingIndicatorCircle} from '@sbb-esta/lyne-angular/loading-indicator-circle';
import {SbbSecondaryButton} from '@sbb-esta/lyne-angular/button/secondary-button';
import {SbbTitle} from '@sbb-esta/lyne-angular/title';
import {HolidaysTable} from './holidays-table/holidays-table';
import {HolidayService} from './holiday.service';

@Component({
  selector: 'app-holidays',
  imports: [
    HolidaysTable,
    SbbLoadingIndicatorCircle,
    SbbSecondaryButton,
    SbbTitle
  ],
  templateUrl: './holidays.html',
  styleUrl: './holidays.css',
})
export class Holidays {
  protected readonly holidayService = inject(HolidayService);
  protected readonly holidays = this.holidayService.holidaysResource;
}

