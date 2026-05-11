import {Component, inject} from '@angular/core';
import {SbbButton} from '@sbb-esta/lyne-angular/button/button';
import {SbbSecondaryButton} from '@sbb-esta/lyne-angular/button/secondary-button';
import {SbbTransparentButton} from '@sbb-esta/lyne-angular/button/transparent-button';
import {SbbTitleModule} from '@sbb-esta/lyne-angular/title';
import {SbbDialogModule} from '@sbb-esta/lyne-angular/dialog';
import {SbbFormFieldModule} from '@sbb-esta/lyne-angular/form-field';
import {SBB_OVERLAY_DATA} from '@sbb-esta/lyne-angular/core/overlay';
import {FormControl, FormGroup, ReactiveFormsModule, Validators,} from '@angular/forms';
import {Holiday, HOLIDAY_TYPE_LABELS, HolidayType} from '../../ru-admin-api';
import {SbbSelectModule} from '@sbb-esta/lyne-angular/select';
import {SbbDatepickerModule} from '@sbb-esta/lyne-angular/datepicker';
import {SbbRadioButtonModule} from '@sbb-esta/lyne-angular/radio-button';
import {CompaniesInputComponent} from '../../../shared/companies-input/companies-input.component';
import {toUtcDateOnly} from '../../../shared/date-util';
import {RecentCompaniesStore} from '../../../shared/recent-companies.store';

export type HolidayDialogEditResult = Holiday | 'delete';

@Component({
  selector: 'app-holiday-dialog',
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
  templateUrl: './holiday-dialog.html',
  styleUrl: './holiday-dialog.css',
})
export class HolidayDialog {
  protected readonly title: string;
  protected readonly isEdit: boolean;

  protected holidayForm = new FormGroup({
    name: new FormControl('', {nonNullable: true, validators: [Validators.required]}),
    validAt: new FormControl<Date | null>(null, {
      validators: [Validators.required]
    }),
    type: new FormControl<HolidayType>('SUNDAY', {
      nonNullable: true,
      validators: [Validators.required],
    }),
    companies: new FormControl<string[]>([], {
      nonNullable: true,
      validators: [Validators.required]
    }),
  });
  protected readonly holidayTypes = HOLIDAY_TYPE_LABELS;
  private readonly dialogData = inject<Holiday>(SBB_OVERLAY_DATA, {optional: true}) ?? null;
  private readonly recentCompaniesStore = inject(RecentCompaniesStore);

  constructor() {
    this.isEdit = this.dialogData?.id != null;
    this.title = this.isEdit
      ? $localize`:@@holidays_dialog_title_edit:Speziellen Feiertag bearbeiten`
      : $localize`:@@holidays_dialog_title_create:Speziellen Feiertag erfassen`;

    if (this.isEdit && this.dialogData) {
      this.holidayForm.patchValue({
        name: this.dialogData.name,
        validAt: new Date(this.dialogData.validAt),
        type: this.dialogData.type,
        companies: this.dialogData.companies,
      });
    } else {
      this.holidayForm.patchValue({companies: this.recentCompaniesStore.get()})
    }
  }

  get formValue(): Holiday {
    const companies = this.holidayForm.controls.companies.value
      .map((company) => company.trim())
      .filter((company) => company.length > 0);
    return {
      name: this.holidayForm.value.name ?? '',
      validAt: toUtcDateOnly(this.holidayForm.value.validAt ?? new Date()),
      type: this.holidayForm.value.type ?? 'SUNDAY',
      companies: companies,
    };
  }
}
