import { Component, inject, input } from '@angular/core';
import {
  AbstractControl,
  FormControl,
  FormGroup,
  ReactiveFormsModule,
  ValidationErrors,
  Validators
} from '@angular/forms';
import { SbbDatepickerModule } from '@sbb-esta/lyne-angular/datepicker';
import { SbbFormFieldModule } from '@sbb-esta/lyne-angular/form-field';
import { DayOfWeek, RuIndicationPeriod } from '../../../ru-admin-api';
import { SbbToggleCheckModule } from '@sbb-esta/lyne-angular/toggle-check';
import { SbbCheckboxModule } from '@sbb-esta/lyne-angular/checkbox';
import { SbbChipModule } from '@sbb-esta/lyne-angular/chip';
import { SbbButtonModule } from '@sbb-esta/lyne-angular/button';
import { toUtcDateOnly } from '../../../../shared/date-util';
import { formatDate } from '@angular/common';
import { LanguageProvider } from '../../../../shared/language-provider';

export function displayPeriod(period: RuIndicationPeriod, localeId = 'de-CH'): string {
  const from = formatDate(period.validFrom, 'shortDate', localeId);
  const to = formatDate(period.validTo, 'shortDate', localeId);
  const days = period.weekdays ?? [];
  if (from === to) {
    return from;
  }

  const weekdayLabels = days
    .map((weekday) => weekdays.find((candidate) => candidate.value === weekday)?.label ?? weekday)
    .join(', ');

  return weekdayLabels ? `${from} - ${to} (${weekdayLabels})` : `${from} - ${to}`;
}

const weekdays: { value: DayOfWeek; label: string }[] = [
  {value: 'MONDAY', label: $localize`:@@weekday_monday:Mo`},
  {value: 'TUESDAY', label: $localize`:@@weekday_tuesday:Di`},
  {value: 'WEDNESDAY', label: $localize`:@@weekday_wednesday:Mi`},
  {value: 'THURSDAY', label: $localize`:@@weekday_thursday:Do`},
  {value: 'FRIDAY', label: $localize`:@@weekday_friday:Fr`},
  {value: 'SATURDAY', label: $localize`:@@weekday_saturday:Sa`},
  {value: 'SUNDAY', label: $localize`:@@weekday_sunday:So`},
];

function periodFormValidator(control: AbstractControl): ValidationErrors | null {
  const isRange = control.get('isRange')?.value === true;
  const validFrom = control.get('validFrom')?.value as Date | null;
  const validTo = control.get('validTo')?.value as Date | null;

  if (!isRange) {
    return null;
  }

  if (!validTo) {
    return {validToRequired: true};
  }

  if (!validFrom) {
    return null;
  }

  if (new Date(validFrom) >= new Date(validTo)) {
    return {dateRangeInvalid: true};
  }

  return null;
}

@Component({
  selector: 'app-periods-input',
  imports: [
    ReactiveFormsModule,
    SbbFormFieldModule,
    SbbDatepickerModule,
    SbbToggleCheckModule,
    SbbCheckboxModule,
    SbbChipModule,
    SbbButtonModule,
  ],
  templateUrl: './periods-input.html',
  styleUrl: './periods-input.css',
})
export class PeriodsInput {
  control = input.required<FormControl<RuIndicationPeriod[]>>();
  protected periodForm = new FormGroup({
    validFrom: new FormControl<Date | null>(null, {validators: [Validators.required]}),
    validTo: new FormControl<Date | null>(null),
    weekdays: new FormControl<DayOfWeek[]>([], {nonNullable: true}),
    isRange: new FormControl(false, {nonNullable: true}),
  }, {validators: periodFormValidator});
  protected readonly weekdays = weekdays;
  private readonly localeId = inject(LanguageProvider).currentLanguage?.localeId;

  constructor() {
    this.applyRangeState(this.periodForm.controls.isRange.value);
    this.periodForm.controls.validFrom.valueChanges.subscribe((validFrom) => {
      if (!this.periodForm.controls.isRange.value) {
        this.periodForm.controls.validTo.setValue(validFrom, {emitEvent: false});
      }
      this.updateValidationState();
    });
    this.periodForm.controls.isRange.valueChanges.subscribe((isRange) => {
      const wasRange = this.periodForm.controls.validTo.enabled;
      if (isRange && !wasRange) {
        this.periodForm.patchValue({
          validTo: null,
          weekdays: [],
        }, {emitEvent: false});
      }
      this.applyRangeState(isRange);
      this.updateValidationState();
    });

    this.periodForm.valueChanges.subscribe(() => this.updateValidationState());
  }

  protected addPeriod(): void {
    if (this.periodForm.invalid) {
      this.control().markAsTouched();
      this.periodForm.markAllAsTouched();
      this.updateValidationState();
      return;
    }

    const validFrom = this.periodForm.controls.validFrom.value;
    const validToDraft = this.periodForm.controls.validTo.value;
    const isRange = this.periodForm.controls.isRange.value;
    if (!validFrom) {
      return;
    }

    const validTo = isRange && validToDraft ? validToDraft : validFrom;
    const weekdays = isRange ? this.periodForm.controls.weekdays.value : [];

    const next: RuIndicationPeriod[] = [
      ...(this.control().value ?? []),
      {
        validFrom: toUtcDateOnly(new Date(validFrom)),
        validTo: toUtcDateOnly(new Date(validTo)),
        weekdays,
      },
    ];

    this.control().setValue(next);
    this.control().markAsTouched();

    this.periodForm.reset({
      validFrom: null,
      validTo: null,
      weekdays: [],
      isRange: false,
    });

    this.applyRangeState(false);
    this.updateValidationState();
  }

  protected isWeekdaySelected(weekday: DayOfWeek): boolean {
    return this.periodForm.controls.weekdays.value.includes(weekday);
  }

  protected onWeekdayChange(weekday: DayOfWeek, event: Event): void {
    const checked = (event.target as HTMLInputElement | null)?.checked ?? !this.isWeekdaySelected(weekday);
    const current = this.periodForm.controls.weekdays.value;
    const next = checked
      ? Array.from(new Set([...current, weekday]))
      : current.filter((value) => value !== weekday);

    this.periodForm.controls.weekdays.setValue(next);
    this.periodForm.controls.weekdays.markAsTouched();
  }

  protected readonly displayPeriod = (period: RuIndicationPeriod) => displayPeriod(period, this.localeId);

  private applyRangeState(isRange: boolean): void {
    if (isRange) {
      this.periodForm.controls.validTo.enable({emitEvent: false});
      this.periodForm.controls.weekdays.enable({emitEvent: false});
      return;
    }

    this.periodForm.controls.validTo.setValue(this.periodForm.controls.validFrom.value, {emitEvent: false});
    this.periodForm.controls.weekdays.setValue([], {emitEvent: false});
    this.periodForm.controls.validTo.disable({emitEvent: false});
    this.periodForm.controls.weekdays.disable({emitEvent: false});
  }

  private updateValidationState(): void {
    const control = this.control();
    control.updateValueAndValidity({onlySelf: true, emitEvent: false});

    const errors: ValidationErrors = control.errors ? {...control.errors} : {};
    if (this.hasDraftValue()) {
      errors['draftInvalid'] = true;
    } else {
      delete errors['draftInvalid'];
    }

    control.setErrors(Object.keys(errors).length > 0 ? errors : null);
    control.markAsTouched();
  }

  private hasDraftValue(): boolean {
    const {validFrom, validTo, weekdays, isRange} = this.periodForm.controls;
    return validFrom.value !== null
      || (isRange.value && validTo.value !== null)
      || weekdays.value.length > 0;
  }
}
