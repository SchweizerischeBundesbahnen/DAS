import { formatDate } from '@angular/common';
import { Component, effect, inject, input, signal, untracked } from '@angular/core';
import {
  disabled,
  FieldTree,
  form,
  FormField,
  PathKind,
  required,
  SchemaPath,
  SchemaPathRules,
  validate,
} from '@angular/forms/signals';
import { SbbButtonModule } from '@sbb-esta/lyne-angular/button';
import { SbbCheckboxModule } from '@sbb-esta/lyne-angular/checkbox';
import { SbbChipModule } from '@sbb-esta/lyne-angular/chip';
import { SbbDatepickerModule } from '@sbb-esta/lyne-angular/datepicker';
import { SbbFormFieldModule } from '@sbb-esta/lyne-angular/form-field';
import { SbbToggleCheckModule } from '@sbb-esta/lyne-angular/toggle-check';
import { DayOfWeek, RuIndicationPeriod } from '~ru-admin/ru-admin-api';
import { toUtcDateOnly } from '~shared/date-util';
import { LanguageProvider } from '~shared/language-provider';

export function displayPeriod(period: RuIndicationPeriod, localeId = 'de-CH'): string {
  const from = formatDate(period.validFrom, 'shortDate', localeId);
  const to = formatDate(period.validTo, 'shortDate', localeId);
  if (from === to) {
    return from;
  }

  const days = period.weekdays ?? [];
  const weekdayLabels = days
    .map((weekday) => weekdays().find((candidate) => candidate.value === weekday)?.label ?? weekday)
    .join(', ');

  return weekdayLabels ? `${from} - ${to} (${weekdayLabels})` : `${from} - ${to}`;
}

const weekdays = (): { value: DayOfWeek; label: string }[] => [
  { value: 'MONDAY', label: $localize`:@@weekday_monday:Mo` },
  { value: 'TUESDAY', label: $localize`:@@weekday_tuesday:Di` },
  { value: 'WEDNESDAY', label: $localize`:@@weekday_wednesday:Mi` },
  { value: 'THURSDAY', label: $localize`:@@weekday_thursday:Do` },
  { value: 'FRIDAY', label: $localize`:@@weekday_friday:Fr` },
  { value: 'SATURDAY', label: $localize`:@@weekday_saturday:Sa` },
  { value: 'SUNDAY', label: $localize`:@@weekday_sunday:So` },
];

function periodValid<TValue extends PeriodsData, TPathKind extends PathKind = PathKind.Root>(
  path: SchemaPath<TValue, SchemaPathRules.Supported, TPathKind>,
  config?: {
    message: {
      validToRequired?: string;
      dateRangeInvalid?: string;
    };
  },
): void {
  validate(path, ({ value }) => {
    const tree = value();
    if (!tree.isRange) {
      return null;
    }

    if (!tree.validTo) {
      return { kind: 'validToRequired', message: config?.message.validToRequired };
    }

    if (!tree.validFrom) {
      return null;
    }

    if (new Date(tree.validFrom) >= new Date(tree.validTo)) {
      return { kind: 'dateRangeInvalid', message: config?.message.dateRangeInvalid };
    }

    return null;
  });
}

function noDraft<TValue extends PeriodsData, TPathKind extends PathKind = PathKind.Root>(
  path: SchemaPath<TValue, SchemaPathRules.Supported, TPathKind>,
  config?: {
    message?: string;
  },
): void {
  validate(path, ({ value }) => {
    const tree = value();
    if (tree.validFrom || (tree.isRange && tree.validTo) || tree.weekdays.length > 0) {
      return { kind: 'draftInvalid', message: config?.message };
    }
    return null;
  });
}

export interface PeriodsData {
  validFrom: Date | null;
  validTo: Date | null;
  weekdays: DayOfWeek[];
  isRange: boolean;
}

@Component({
  selector: 'app-periods-input',
  imports: [
    FormField,
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
  private readonly languageProvider = inject(LanguageProvider);

  readonly field = input.required<FieldTree<RuIndicationPeriod[]>>();

  private readonly default: PeriodsData = {
    validFrom: null,
    validTo: null,
    weekdays: [],
    isRange: false,
  };
  protected readonly periodModel = signal(this.default);
  protected readonly periodForm = form(this.periodModel, (period) => {
    periodValid(period, {
      message: {
        validToRequired: $localize`:@@ru_indications_form_period_valid_to_required_error:Für eine Zeitspanne muss "Bis" gesetzt werden`,
        dateRangeInvalid: $localize`:@@ru_indications_form_period_date_range_error:"Von" muss vor "Bis" liegen`,
      },
    });
    noDraft(period, {
      message: $localize`:@@ru_indications_form_period_draft_error:Nicht gespeicherte Eingabe - bitte zur Auswahl hinzufügen oder leeren`,
    });

    required(period.validFrom, {
      message: $localize`:@@ru_indications_form_period_date_error:"Von" muss gesetzt werden`,
      when: ({ valueOf }) => !!valueOf(period.validTo),
    });

    disabled(period.validTo, { when: ({ valueOf }) => !valueOf(period.isRange) });
    disabled(period.weekdays, { when: ({ valueOf }) => !valueOf(period.isRange) });
  });

  protected readonly weekdays = weekdays();
  private readonly localeId = this.languageProvider.currentLanguage.localeId;

  protected readonly displayPeriod = (period: RuIndicationPeriod) =>
    displayPeriod(period, this.localeId);

  constructor() {
    effect(() => {
      if (!untracked(() => this.periodForm.isRange().value())) {
        this.periodForm.validTo().value.set(this.periodForm.validFrom().value());
      }
    });

    effect(() => {
      const isRange = this.periodForm.isRange().value();
      if (isRange) {
        this.periodForm.validTo().value.set(null);
      } else {
        this.periodForm.validTo().value.set(this.periodForm.validFrom().value());
        this.periodForm.weekdays().value.set([]);
      }
    });
  }

  protected addPeriod(): void {
    if (
      this.periodForm()
        .errorSummary()
        .some((e) => e.kind !== 'draftInvalid')
    ) {
      return;
    }

    const form = this.periodModel();
    const validFrom = form.validFrom;
    if (!validFrom) {
      return;
    }

    const isRange = form.isRange;
    const validToDraft = form.validTo;
    const validTo = isRange && validToDraft ? validToDraft : validFrom;
    const weekdays = isRange ? form.weekdays : [];

    // add period
    const periods = this.field()();
    periods.value.set([
      ...periods.value(),
      {
        validFrom: toUtcDateOnly(new Date(validFrom)),
        validTo: toUtcDateOnly(new Date(validTo)),
        weekdays,
      },
    ]);
    periods.markAsTouched();
    periods.markAsDirty();

    this.periodForm().reset(this.default);
  }

  protected isWeekdaySelected(weekday: DayOfWeek): boolean {
    return this.periodModel().weekdays.includes(weekday);
  }

  protected onWeekdayChange(weekday: DayOfWeek, event: Event): void {
    const checked =
      (event.target as HTMLInputElement | null)?.checked ?? !this.isWeekdaySelected(weekday);
    const current = this.periodModel().weekdays;

    this.periodForm
      .weekdays()
      .value.set(
        checked
          ? [...new Set([...current, weekday])]
          : current.filter((value) => value !== weekday),
      );
  }
}
