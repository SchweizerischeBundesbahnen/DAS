import { Component, computed, input, signal, viewChild, viewChildren } from '@angular/core';
import { SbbStep, SbbStepper, SbbStepperModule } from '@sbb-esta/lyne-angular/stepper';
import { CommonModule } from '@angular/common';
import { SbbStepChangeEvent } from '@sbb-esta/lyne-elements/stepper.js';
import { SbbTitleModule } from '@sbb-esta/lyne-angular/title';
import { ReactiveFormsModule } from '@angular/forms';
import { SbbDialogModule } from '@sbb-esta/lyne-angular/dialog';
import { SbbButtonModule } from '@sbb-esta/lyne-angular/button';
import { Audit } from '../audit/audit';
import { Auditable } from '../audit/auditable';
import { SbbActionGroup } from '@sbb-esta/lyne-angular/action-group';

@Component({
  selector: 'app-base-dialog',
  standalone: true,
  imports: [
    CommonModule,
    SbbStepperModule,
    SbbTitleModule,
    ReactiveFormsModule,
    SbbButtonModule,
    SbbDialogModule,
    SbbActionGroup,
    Audit,
  ],
  templateUrl: './base-dialog.component.html',
  styleUrl: './base-dialog.component.css',
})
export class BaseDialog {
  dialogTitle = input.required<string>();
  stepLabel = input.required<string>();
  data = input<Auditable>();
  saveDisabled = input.required<boolean>();
  dialogClose = input.required();
  isEdit = computed(() => !!this.data());
  steps = viewChildren(SbbStep);
  protected stepchange = signal<SbbStepChangeEvent | undefined>(undefined);
  protected readonly isLastStep = computed(() => {
    const selectedIndex = this.stepchange()?.selectedIndex;
    if (selectedIndex === undefined) return true;
    const lastStep = this.steps().length - 1;
    return selectedIndex === lastStep;
  });
  protected readonly isStepDisabled = computed(() => {
    const step = this.stepchange()?.selectedIndex;
    if (step === 0) {
      return this.saveDisabled();
    } else {
      return false;
    }
  });
  private readonly stepper = viewChild.required(SbbStepper);

  next(): void {
    this.stepper().next();
  }
}
