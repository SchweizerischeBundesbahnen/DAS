import { Component, input, OnInit } from '@angular/core';
import {
  AbstractControl,
  FormControl,
  FormGroup,
  ReactiveFormsModule,
  ValidationErrors,
  Validators,
} from '@angular/forms';
import { SbbFormFieldModule } from '@sbb-esta/lyne-angular/form-field';
import { SbbRadioButtonModule } from '@sbb-esta/lyne-angular/radio-button';
import { SbbButtonModule } from '@sbb-esta/lyne-angular/button';
import { SbbChipModule } from '@sbb-esta/lyne-angular/chip';
import { RuIndicationTrainNumberFilter, TrainNumberParity } from '../../../ru-admin-api';
import { SbbTooltipModule } from '@sbb-esta/lyne-angular/tooltip';

type TrainFilterMode = 'all' | 'filtered';

export function displayTrainNumberFilter(value: RuIndicationTrainNumberFilter): string {
  let parity;
  if (value.parity === 'EVEN') {
    parity = $localize`:@@ru_indication_form_parity_even_value:Gerade`;
  }
  if (value.parity === 'ODD') {
    parity = $localize`:@@ru_indication_form_parity_odd_value:Ungerade`;
  }
  return value.expression + (parity ? ` (${parity})` : '');
}

function numberRangeValidator(control: AbstractControl): ValidationErrors | null {
  const value = (control as FormControl<string>).value;
  if (!value) {
    return null;
  }

  const regex = /^\d+(-\d+)?$/;
  if (!regex.test(value)) {
    return { invalidFormat: true };
  }

  const [first, second] = value.split('-').map(Number);

  if (first >= second) {
    return { rangeInvalid: true };
  }

  return null;
}

@Component({
  selector: 'app-train-number-input',
  imports: [
    ReactiveFormsModule,
    SbbFormFieldModule,
    SbbRadioButtonModule,
    SbbButtonModule,
    SbbChipModule,
    SbbTooltipModule,
  ],
  templateUrl: './train-number-input.html',
  styleUrl: './train-number-input.css',
})
export class TrainNumberInput implements OnInit {
  readonly control = input.required<FormControl<RuIndicationTrainNumberFilter[]>>();

  protected trainFilterModeControl = new FormControl<TrainFilterMode>('all', { nonNullable: true });
  protected trainNumberFilterForm = new FormGroup({
    trainNumber: new FormControl('', {
      nonNullable: true,
      validators: [Validators.required, numberRangeValidator],
    }),
    parity: new FormControl<TrainNumberParity>('ANY', { nonNullable: true }),
  });
  protected readonly displayTrainNumberFilter = displayTrainNumberFilter;

  ngOnInit(): void {
    this.initializeTrainFilterMode();

    this.trainFilterModeControl.valueChanges.subscribe((mode) => {
      if (mode === 'all') {
        this.control().setValue([]);
        this.trainNumberFilterForm.reset();
      } else {
        this.control().markAsTouched();
      }
      this.updateValidationState();
    });

    // make sure value changes from outside are also considered for validation
    this.control().parent?.valueChanges.subscribe(() => {
      this.updateValidationState();
    });

    this.trainNumberFilterForm.valueChanges.subscribe(() => this.updateValidationState());
    this.updateValidationState();
  }

  protected isTrainNumberRange(): boolean {
    return (
      this.trainNumberFilterForm.valid
      && this.trainNumberFilterForm.controls.trainNumber.value.includes('-')
    );
  }

  protected addTrainNumberFilter(): void {
    if (this.trainNumberFilterForm.invalid) {
      this.control().markAsTouched();
      this.updateValidationState();
      return;
    }

    const current = this.control().value ?? [];
    const next: RuIndicationTrainNumberFilter[] = [
      ...current,
      {
        expression: this.trainNumberFilterForm.controls.trainNumber.value,
        parity: this.trainNumberFilterForm.controls.parity.value,
      },
    ];
    this.control().setValue(next);
    this.control().markAsTouched();
    this.trainNumberFilterForm.reset();
    this.updateValidationState();
  }

  private initializeTrainFilterMode(): void {
    if ((this.control().value ?? []).length > 0) {
      this.trainFilterModeControl.setValue('filtered', { emitEvent: false });
    } else {
      this.trainFilterModeControl.setValue('all', { emitEvent: false });
    }
  }

  private updateValidationState(): void {
    if (this.trainFilterModeControl.value === 'all') {
      this.control().setErrors(null);
      return;
    }

    const hasCommittedFilters = (this.control().value ?? []).length > 0;
    const hasDraftValue = this.trainNumberFilterForm.controls.trainNumber.value.trim().length > 0;
    const errors: ValidationErrors = {};
    if (!hasCommittedFilters) errors['required'] = true;
    if (hasDraftValue) errors['draftInvalid'] = true;
    this.control().setErrors(Object.keys(errors).length > 0 ? errors : null);
  }
}
