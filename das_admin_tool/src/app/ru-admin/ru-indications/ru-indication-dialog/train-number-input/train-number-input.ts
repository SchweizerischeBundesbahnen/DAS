import { Component, input, signal } from '@angular/core';
import {
  FieldTree,
  form,
  FormField,
  PathKind,
  SchemaPath,
  SchemaPathRules,
  validate,
} from '@angular/forms/signals';
import { SbbButtonModule } from '@sbb-esta/lyne-angular/button';
import { SbbChipModule } from '@sbb-esta/lyne-angular/chip';
import { SbbFormFieldModule } from '@sbb-esta/lyne-angular/form-field';
import { SbbRadioButtonModule } from '@sbb-esta/lyne-angular/radio-button';
import { SbbTooltipModule } from '@sbb-esta/lyne-angular/tooltip';
import { RuIndicationTrainNumberFilter, TrainNumberParity } from '~ru-admin/ru-admin-api';
import { OperationalTrainNumber } from '../ru-indication-dialog.component';

export function displayTrainNumberFilter(value: RuIndicationTrainNumberFilter): string {
  let parity;
  if (value.parity === 'EVEN') {
    parity = $localize`:@@ru_indication_form_parity_even_value:Gerade`;
  } else if (value.parity === 'ODD') {
    parity = $localize`:@@ru_indication_form_parity_odd_value:Ungerade`;
  }
  return value.expression + (parity ? ` (${parity})` : '');
}

function numberRangeValid<TValue extends string, TPathKind extends PathKind = PathKind.Root>(
  path: SchemaPath<TValue, SchemaPathRules.Supported, TPathKind>,
  config?: {
    message: {
      invalidFormat?: string;
      rangeInvalid?: string;
    };
  },
): void {
  validate(path, ({ value }) => {
    if (!value()) {
      return null;
    }

    const regex = /^\d+(-\d+)?$/;
    if (!regex.test(value())) {
      return { kind: 'invalidFormat', message: config?.message.invalidFormat };
    }

    const [first, second] = value().split('-').map(Number);

    if (first >= second) {
      return { kind: 'rangeInvalid', message: config?.message.rangeInvalid };
    }

    return null;
  });
}

function noDraft<TValue extends TrainNumberData, TPathKind extends PathKind = PathKind.Root>(
  path: SchemaPath<TValue, SchemaPathRules.Supported, TPathKind>,
  config?: {
    message?: string;
  },
): void {
  validate(path, ({ value }) => {
    const tree = value();
    if (tree.trainNumber.trim().length > 0) {
      return { kind: 'draftInvalid', message: config?.message };
    }
    return null;
  });
}

export interface TrainNumberData {
  trainNumber: string;
  parity: TrainNumberParity;
}

@Component({
  selector: 'app-train-number-input',
  imports: [
    FormField,
    SbbFormFieldModule,
    SbbRadioButtonModule,
    SbbButtonModule,
    SbbChipModule,
    SbbTooltipModule,
  ],
  templateUrl: './train-number-input.html',
  styleUrl: './train-number-input.css',
})
export class TrainNumberInput {
  public readonly form = input.required<FieldTree<OperationalTrainNumber>>();

  private readonly default: TrainNumberData = {
    trainNumber: '',
    parity: 'ANY',
  };
  protected readonly trainNumberModel = signal(this.default);
  protected readonly trainNumberForm = form(this.trainNumberModel, (trainNumber) => {
    numberRangeValid(trainNumber.trainNumber, {
      message: {
        invalidFormat: $localize`:@@ru_indications_form_train_filter_draft_error:Format stimmt nicht`,
        rangeInvalid: $localize`:@@ru_indications_form_train_filter_draft_error:Bereich stimmt nicht`,
      },
    });
    noDraft(trainNumber, {
      message: $localize`:@@ru_indications_form_train_filter_draft_error:Nicht gespeicherte Eingabe - bitte zur Auswahl hinzufügen oder leeren`,
    });
  });

  protected readonly displayTrainNumberFilter = displayTrainNumberFilter;

  protected isTrainNumberRange(): boolean {
    return (
      this.trainNumberForm.trainNumber().valid()
      && this.trainNumberModel().trainNumber.includes('-')
    );
  }

  protected addTrainNumberFilter(): void {
    if (
      this.trainNumberForm()
        .errorSummary()
        .some((e) => e.kind !== 'draftInvalid')
    ) {
      return;
    }

    // add train number filter
    const filters = this.form().filters();
    filters.value.set([
      ...filters.value(),
      {
        expression: this.trainNumberModel().trainNumber,
        parity: this.trainNumberModel().parity,
      },
    ]);
    filters.markAsTouched();
    filters.markAsDirty();

    this.trainNumberForm().reset(this.default);
  }
}
