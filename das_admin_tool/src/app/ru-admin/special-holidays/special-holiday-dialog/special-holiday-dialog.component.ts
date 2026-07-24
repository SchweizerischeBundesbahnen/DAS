import { Component, inject } from '@angular/core';
import { FormControl, FormGroup, ReactiveFormsModule, Validators } from '@angular/forms';
import { SBB_OVERLAY_DATA } from '@sbb-esta/lyne-angular/core';
import { SbbDatepickerModule } from '@sbb-esta/lyne-angular/datepicker';
import { SbbFormFieldModule } from '@sbb-esta/lyne-angular/form-field';
import { SbbRadioButtonModule } from '@sbb-esta/lyne-angular/radio-button';
import { SbbTitleModule } from '@sbb-esta/lyne-angular/title';
import { SCHEDULE_TYPE_LABELS, ScheduleType, SpecialHoliday } from '~ru-admin/ru-admin-api';
import { BaseDialog } from '~shared/base-dialog/base-dialog.component';
import { CompaniesInputComponent } from '~shared/companies-input/companies-input.component';
import { toUtcDateOnly } from '~shared/date-util';

export type SpecialHolidayDialogEditResult = SpecialHoliday | 'delete';

@Component({
  selector: 'app-special-holiday-dialog',
  imports: [
    ReactiveFormsModule,
    SbbTitleModule,
    SbbFormFieldModule,
    SbbDatepickerModule,
    SbbRadioButtonModule,
    BaseDialog,
    CompaniesInputComponent,
  ],
  templateUrl: './special-holiday-dialog.component.html',
  styleUrl: './special-holiday-dialog.component.css',
})
export class SpecialHolidayDialog {
  protected readonly dialogData =
    inject<SpecialHoliday>(SBB_OVERLAY_DATA, { optional: true }) ?? undefined;

  protected readonly title: string;
  protected readonly minDate = new Date();

  protected specialHolidayForm = new FormGroup({
    name: new FormControl('', { nonNullable: true, validators: [Validators.required] }),
    date: new FormControl<Date | null>(null, { validators: [Validators.required] }),
    scheduleType: new FormControl<ScheduleType>('SUNDAY_SCHEDULE', {
      nonNullable: true,
      validators: [Validators.required],
    }),
    companies: new FormControl<string[]>([], {
      nonNullable: true,
      validators: [Validators.required],
    }),
  });
  protected readonly scheduleTypes = SCHEDULE_TYPE_LABELS();

  constructor() {
    const isEdit = this.dialogData?.id !== undefined;
    this.title = isEdit
      ? $localize`:@@special_holidays_dialog_title_edit:Speziellen Feiertag bearbeiten`
      : $localize`:@@special_holidays_dialog_title_create:Speziellen Feiertag erfassen`;

    if (isEdit && this.dialogData) {
      this.specialHolidayForm.patchValue({
        name: this.dialogData.name,
        date: new Date(this.dialogData.date),
        scheduleType: this.dialogData.scheduleType,
        companies: this.dialogData.companies,
      });
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
