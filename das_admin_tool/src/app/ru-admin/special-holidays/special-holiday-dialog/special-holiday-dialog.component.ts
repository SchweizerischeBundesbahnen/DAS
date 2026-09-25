import { Component, inject, signal } from '@angular/core';
import { form, FormField, required } from '@angular/forms/signals';
import { SBB_OVERLAY_DATA } from '@sbb-esta/lyne-angular/core';
import { SbbDatepickerModule } from '@sbb-esta/lyne-angular/datepicker';
import { SbbFormFieldModule } from '@sbb-esta/lyne-angular/form-field';
import { SbbRadioButtonModule } from '@sbb-esta/lyne-angular/radio-button';
import { SbbTitleModule } from '@sbb-esta/lyne-angular/title';
import { SCHEDULE_TYPE_LABELS, ScheduleType, SpecialHoliday } from '~ru-admin/ru-admin-api';
import { BaseDialog } from '~shared/base-dialog/base-dialog.component';
import { CompaniesInputComponent } from '~shared/companies-input/companies-input.component';
import { toUtcDateOnly } from '~shared/date-util';
import { arrayRequired } from '~shared/form-validators.util';

interface SpecialHolidayData {
  name: string;
  date: Date | null;
  scheduleType: ScheduleType;
  companies: string[];
}

export type SpecialHolidayDialogEditResult = SpecialHoliday | 'delete';

@Component({
  selector: 'app-special-holiday-dialog',
  imports: [
    FormField,
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

  protected readonly dialogTitle: string;

  protected readonly specialHolidayModel = signal<SpecialHolidayData>({
    name: '',
    date: null,
    scheduleType: 'SUNDAY_SCHEDULE',
    companies: [],
  });
  protected readonly specialHolidayForm = form(this.specialHolidayModel, (specialHoliday) => {
    required(specialHoliday.name, {
      message: $localize`:@@form_field_error_required:Feld darf nicht leer sein`,
    });

    required(specialHoliday.date, {
      message: $localize`:@@form_field_error_required:Feld darf nicht leer sein`,
    });

    required(specialHoliday.scheduleType, {
      message: $localize`:@@form_field_error_required:Feld darf nicht leer sein`,
    });

    arrayRequired(specialHoliday.companies, {
      message: $localize`:@@form_field_error_required:Feld darf nicht leer sein`,
    });
  });

  protected readonly minDate = new Date();

  protected readonly scheduleTypes = SCHEDULE_TYPE_LABELS();

  constructor() {
    const isEdit = this.dialogData?.id !== undefined;
    this.dialogTitle = isEdit
      ? $localize`:@@special_holidays_dialog_title_edit:Speziellen Feiertag bearbeiten`
      : $localize`:@@special_holidays_dialog_title_create:Speziellen Feiertag erfassen`;

    if (isEdit && this.dialogData) {
      this.specialHolidayModel.update(() => ({
        name: this.dialogData!.name,
        date: new Date(this.dialogData!.date),
        scheduleType: this.dialogData!.scheduleType,
        companies: this.dialogData!.companies,
      }));
    }
  }

  get formValue(): SpecialHoliday {
    const formValue = this.specialHolidayModel();
    return {
      ...formValue,
      date: toUtcDateOnly(formValue.date ?? new Date()).toJSON(),
    };
  }
}
