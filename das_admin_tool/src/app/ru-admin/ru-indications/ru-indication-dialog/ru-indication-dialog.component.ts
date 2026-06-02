import { Component, computed, inject, signal, viewChild } from '@angular/core';
import { SbbDialogModule } from '@sbb-esta/lyne-angular/dialog';
import { SbbTitleModule } from '@sbb-esta/lyne-angular/title';
import { SbbFormFieldModule } from '@sbb-esta/lyne-angular/form-field';
import { FormControl, FormGroup, ReactiveFormsModule, Validators } from '@angular/forms';
import { SbbTabsModule } from '@sbb-esta/lyne-angular/tabs';
import {
  RuIndication,
  RuIndicationPeriod,
  RuIndicationTrainNumberFilter
} from '../../ru-admin-api';
import { SBB_OVERLAY_DATA } from '@sbb-esta/lyne-angular/core/overlay';
import { CompaniesInputComponent } from '../../../shared/companies-input/companies-input.component';
import { LocationsInput } from './locations-input/locations-input.component';
import { SbbStepper, SbbStepperModule } from '@sbb-esta/lyne-angular/stepper';
import { SbbAutocompleteModule } from '@sbb-esta/lyne-angular/autocomplete';
import { RuIndicationDialogData } from '../ru-indication.service';
import { toSignal } from '@angular/core/rxjs-interop';
import { SbbStepChangeEvent } from '@sbb-esta/lyne-elements/stepper.js';
import { TrainNumberInput } from './train-number-input/train-number-input';
import { SbbButtonModule } from '@sbb-esta/lyne-angular/button';
import { PeriodsInput } from './periods-input/periods-input';
import { DatePipe } from '@angular/common';
import {
  createContentFormGroup
} from '../../ru-indication-content-form/ru-indication-content-form.component';
import { CategoryContentForm } from './content-form/category-content-form';
import { SbbActionGroup } from '@sbb-esta/lyne-angular/action-group';

@Component({
  selector: 'app-ru-indication-dialog',
  imports: [
    ReactiveFormsModule,
    DatePipe,
    SbbDialogModule,
    SbbFormFieldModule,
    SbbTitleModule,
    SbbTabsModule,
    SbbButtonModule,
    SbbAutocompleteModule,
    SbbStepperModule,
    LocationsInput,
    TrainNumberInput,
    PeriodsInput,
    CompaniesInputComponent,
    CategoryContentForm,
    SbbActionGroup,
  ],
  templateUrl: './ru-indication-dialog.component.html',
  styleUrl: './ru-indication-dialog.component.css',
})
export class RuIndicationDialog {
  protected readonly title: string;
  protected readonly isEdit: boolean;
  protected ruIndicationForm = new FormGroup({
    content: createContentFormGroup(),
    scope: new FormGroup({
      companies: new FormControl<string[]>([], {
        nonNullable: true,
        validators: [Validators.required]
      }),
      operationalTrainNumberFilters: new FormControl<RuIndicationTrainNumberFilter[]>([], {nonNullable: true}),
      tafTapLocationReferences: new FormControl<string[]>([], {
        nonNullable: true,
        validators: [Validators.required]
      }),
    }),
    periods: new FormControl<RuIndicationPeriod[]>([], {nonNullable: true}),
  });
  protected stepchange = signal<SbbStepChangeEvent | undefined>(undefined);
  protected readonly dialogData = inject<RuIndicationDialogData>(SBB_OVERLAY_DATA);

  protected readonly isLastStep = computed(() => {
    const selectedIndex = this.stepchange()?.selectedIndex;
    const lastIndex = this.isEdit ? 3 : 2;
    return selectedIndex === lastIndex;
  });
  private readonly stepper = viewChild.required(SbbStepper);
  private readonly contentComponent = viewChild.required(CategoryContentForm);

  private readonly contentFormStatus = toSignal(this.ruIndicationForm.controls.content.statusChanges);
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
        operationalTrainNumberFilters: this.ruIndicationForm.controls.scope.controls.operationalTrainNumberFilters.value,
        tafTapLocationReferences: this.ruIndicationForm.controls.scope.controls.tafTapLocationReferences.value,
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
