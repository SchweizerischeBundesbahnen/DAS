import { Component, computed, inject, signal, viewChild, viewChildren } from '@angular/core';
import { toSignal } from '@angular/core/rxjs-interop';
import { FormControl, FormGroup, ReactiveFormsModule, Validators } from '@angular/forms';
import { SbbActionGroupModule } from '@sbb-esta/lyne-angular/action-group';
import { SbbAutocompleteModule } from '@sbb-esta/lyne-angular/autocomplete';
import { SbbButtonModule } from '@sbb-esta/lyne-angular/button';
import { SBB_OVERLAY_DATA } from '@sbb-esta/lyne-angular/core/overlay';
import { SbbDialogModule } from '@sbb-esta/lyne-angular/dialog';
import { SbbFormFieldModule } from '@sbb-esta/lyne-angular/form-field';
import { SbbStep, SbbStepper, SbbStepperModule } from '@sbb-esta/lyne-angular/stepper';
import { SbbTabsModule } from '@sbb-esta/lyne-angular/tabs';
import { SbbTitleModule } from '@sbb-esta/lyne-angular/title';
import { SbbStepChangeEvent } from '@sbb-esta/lyne-elements/stepper.js';
import {
  RuIndication,
  RuIndicationPeriod,
  RuIndicationTrainNumberFilter,
} from '~ru-admin/ru-admin-api';
import { createContentFormGroup } from '~ru-admin/ru-indication-content-form/ru-indication-content-form.component';
import { Audit } from '~shared/audit/audit';
import { CompaniesInputComponent } from '~shared/companies-input/companies-input.component';
import { RuIndicationDialogData } from '../ru-indication.service';
import { CategoryContentForm } from './content-form/category-content-form';
import { LocationsInput } from './locations-input/locations-input.component';
import { PeriodsInput } from './periods-input/periods-input';
import { TrainNumberInput } from './train-number-input/train-number-input';

@Component({
  selector: 'app-ru-indication-dialog',
  imports: [
    ReactiveFormsModule,
    SbbDialogModule,
    SbbFormFieldModule,
    SbbTitleModule,
    SbbTabsModule,
    SbbButtonModule,
    SbbAutocompleteModule,
    SbbStepperModule,
    SbbActionGroupModule,
    LocationsInput,
    TrainNumberInput,
    PeriodsInput,
    CompaniesInputComponent,
    CategoryContentForm,
    Audit,
  ],
  templateUrl: './ru-indication-dialog.component.html',
  styleUrl: './ru-indication-dialog.component.css',
})
export class RuIndicationDialog {
  protected readonly title: string;
  protected readonly isEdit: boolean;
  protected ruIndicationForm = new FormGroup({
    content: new FormGroup({
      category: new FormControl('', { nonNullable: true, validators: [Validators.required] }),
      ...createContentFormGroup().controls,
    }),
    scope: new FormGroup({
      companies: new FormControl<string[]>([], {
        nonNullable: true,
        validators: [Validators.required],
      }),
      operationalTrainNumberFilters: new FormControl<RuIndicationTrainNumberFilter[]>([], {
        nonNullable: true,
      }),
      tafTapLocationReferences: new FormControl<string[]>([], {
        nonNullable: true,
        validators: [Validators.required],
      }),
    }),
    periods: new FormControl<RuIndicationPeriod[]>([], { nonNullable: true }),
  });
  protected readonly stepchange = signal<SbbStepChangeEvent | undefined>(undefined);
  protected readonly dialogData = inject<RuIndicationDialogData>(SBB_OVERLAY_DATA);
  private readonly stepper = viewChild.required(SbbStepper);
  private readonly contentComponent = viewChild.required(CategoryContentForm);
  private readonly steps = viewChildren(SbbStep);
  protected readonly isLastStep = computed(() => {
    const selectedIndex = this.stepchange()?.selectedIndex;
    const lastStep = this.steps().length - 1;
    return selectedIndex === lastStep;
  });
  private readonly contentFormStatus = toSignal(
    this.ruIndicationForm.controls.content.statusChanges,
  );
  private readonly scopeFormStatus = toSignal(this.ruIndicationForm.controls.scope.statusChanges);
  protected readonly isStepDisabled = computed(() => {
    const step = this.stepchange()?.selectedIndex;
    if (step === 0) {
      return this.contentFormStatus() === 'INVALID';
    } else if (step === 1) {
      return this.scopeFormStatus() === 'INVALID';
    } else {
      return false;
    }
  });

  constructor() {
    this.isEdit = this.dialogData.ruIndication?.id != null;
    this.title = this.isEdit
      ? $localize`:@@ru_indications_dialog_title_edit:Hinweis bearbeiten`
      : $localize`:@@ru_indications_dialog_title_create:Hinweis erfassen`;
    if (this.isEdit && this.dialogData?.ruIndication) {
      this.patchRuIndication(this.dialogData.ruIndication);
    }
  }

  get formValue(): RuIndication {
    return {
      content: this.contentComponent().formValue,
      scope: {
        companies: this.ruIndicationForm.controls.scope.controls.companies.value,
        operationalTrainNumberFilters:
          this.ruIndicationForm.controls.scope.controls.operationalTrainNumberFilters.value,
        tafTapLocationReferences:
          this.ruIndicationForm.controls.scope.controls.tafTapLocationReferences.value,
      },
      periods: this.ruIndicationForm.controls.periods.value,
    };
  }

  protected next() {
    this.stepper().next();
  }

  private patchRuIndication(ruIndication: RuIndication): void {
    this.ruIndicationForm.patchValue({
      content: {
        de: {
          title: ruIndication.content.de?.title ?? '',
          text: ruIndication.content.de?.text ?? '',
        },
        fr: {
          title: ruIndication.content.fr?.title ?? '',
          text: ruIndication.content.fr?.text ?? '',
        },
        it: {
          title: ruIndication.content.it?.title ?? '',
          text: ruIndication.content.it?.text ?? '',
        },
      },
      scope: {
        companies: ruIndication.scope.companies ?? [],
        operationalTrainNumberFilters: ruIndication.scope.operationalTrainNumberFilters ?? [],
        tafTapLocationReferences: ruIndication.scope.tafTapLocationReferences ?? [],
      },
      periods: ruIndication.periods ?? [],
    });
  }
}
