import {Component, inject} from '@angular/core';
import {SbbButton} from '@sbb-esta/lyne-angular/button/button';
import {SbbSecondaryButton} from '@sbb-esta/lyne-angular/button/secondary-button';
import {SbbTransparentButton} from '@sbb-esta/lyne-angular/button/transparent-button';
import {SbbTitleModule} from '@sbb-esta/lyne-angular/title';
import {SbbDialogModule} from '@sbb-esta/lyne-angular/dialog';
import {SbbFormFieldModule} from '@sbb-esta/lyne-angular/form-field';
import {SBB_OVERLAY_DATA} from '@sbb-esta/lyne-angular/core/overlay';
import {FormControl, FormGroup, ReactiveFormsModule, Validators,} from '@angular/forms';
import {SCHEDULE_TYPE_LABELS, ScheduleType, SpecialHoliday} from '../../ru-admin-api';
import {SbbSelectModule} from '@sbb-esta/lyne-angular/select';
import {SbbDatepickerModule} from '@sbb-esta/lyne-angular/datepicker';
import {SbbRadioButtonModule} from '@sbb-esta/lyne-angular/radio-button';
import {CompaniesInputComponent} from '../../../shared/companies-input/companies-input.component';
import {toUtcDateOnly} from '../../../shared/date-util';
import {RecentCompaniesStore} from '../../../shared/recent-companies.store';

export type SpecialHolidayDialogEditResult = SpecialHoliday | 'delete';

@Component({
  selector: 'app-special-holiday-dialog',
  imports: [
    SbbDialogModule,
    SbbButton,
    SbbSecondaryButton,
    SbbTransparentButton,
    SbbTitleModule,
    SbbFormFieldModule,
    SbbSelectModule,
    ReactiveFormsModule,
    SbbDatepickerModule,
    SbbRadioButtonModule,
    CompaniesInputComponent,
  ],
  templateUrl: './special-holiday-dialog.component.html',
  styleUrl: './special-holiday-dialog.component.css',
})
export class SpecialHolidayDialog {
  protected readonly title: string;
  protected readonly isEdit: boolean;

  protected specialHolidayForm = new FormGroup({
    name: new FormControl('', {nonNullable: true, validators: [Validators.required]}),
    date: new FormControl<Date | null>(null, {
      validators: [Validators.required]
    }),
    scheduleType: new FormControl<ScheduleType>('SUNDAY_SCHEDULE', {
      nonNullable: true,
      validators: [Validators.required],
    }),
    companies: new FormControl<string[]>([], {
      nonNullable: true,
      validators: [Validators.required]
    }),
  });
  protected readonly scheduleTypes = SCHEDULE_TYPE_LABELS;
  private readonly dialogData = inject<SpecialHoliday>(SBB_OVERLAY_DATA, {optional: true}) ?? null;
  private readonly recentCompaniesStore = inject(RecentCompaniesStore);

  constructor() {
    this.isEdit = this.dialogData?.id != null;
    this.title = this.isEdit
      ? $localize`:@@special_holidays_dialog_title_edit:Speziellen Feiertag bearbeiten`
      : $localize`:@@special_holidays_dialog_title_create:Speziellen Feiertag erfassen`;

    if (this.isEdit && this.dialogData) {
      this.specialHolidayForm.patchValue({
        name: this.dialogData.name,
        date: new Date(this.dialogData.date),
        scheduleType: this.dialogData.scheduleType,
        companies: this.dialogData.companies,
      });
    } else {
      this.specialHolidayForm.patchValue({companies: this.recentCompaniesStore.get()})
    }
  }

  get formValue(): SpecialHoliday {
    const companies = this.specialHolidayForm.controls.companies.value
      .map((company) => company.trim())
      .filter((company) => company.length > 0);
    return {
      name: this.specialHolidayForm.value.name ?? '',
      date: toUtcDateOnly(this.specialHolidayForm.value.date ?? new Date()),
      scheduleType: this.specialHolidayForm.value.scheduleType ?? 'SUNDAY_SCHEDULE',
      companies: companies,
    };
  }
}
