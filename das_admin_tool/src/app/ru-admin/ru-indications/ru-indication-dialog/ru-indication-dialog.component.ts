import {
  Component,
  computed,
  effect,
  inject,
  signal,
  viewChild,
  viewChildren,
} from '@angular/core';
import { form, hidden } from '@angular/forms/signals';
import { SbbActionGroupModule } from '@sbb-esta/lyne-angular/action-group';
import { SbbAutocompleteModule } from '@sbb-esta/lyne-angular/autocomplete';
import { SbbButtonModule } from '@sbb-esta/lyne-angular/button';
import { SBB_OVERLAY_DATA } from '@sbb-esta/lyne-angular/core';
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
import {
  contentFormValue,
  createContentFormTree,
  RuIndicationContentWithCategoryData,
} from '~ru-admin/ru-indication-content-form/ru-indication-content-form.component';
import { Audit } from '~shared/audit/audit';
import { CompaniesInputComponent } from '~shared/companies-input/companies-input.component';
import { arrayRequired, languageRequired, oneLanguageRequired } from '~shared/form-validators.util';
import { RuIndicationDialogData } from '../ru-indication.service';
import { CategoryContentForm } from './content-form/category-content-form';
import { LocationsInput } from './locations-input/locations-input.component';
import { PeriodsInput } from './periods-input/periods-input';
import { TrainNumberInput } from './train-number-input/train-number-input';

export interface OperationalTrainNumber {
  mode: 'all' | 'filtered';
  filters: RuIndicationTrainNumberFilter[];
}

interface RuIndicationScope {
  companies: string[];
  operationalTrainNumber: OperationalTrainNumber;
  tafTapLocationReferences: string[];
}

export interface RuIndicationData {
  content: RuIndicationContentWithCategoryData;
  scope: RuIndicationScope;
  periods: RuIndicationPeriod[];
}

@Component({
  selector: 'app-ru-indication-dialog',
  imports: [
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
  protected readonly dialogData = inject<RuIndicationDialogData>(SBB_OVERLAY_DATA);

  protected readonly dialogTitle: string;

  protected readonly isEdit: boolean;

  protected readonly ruIndicationModel = signal<RuIndicationData>({
    content: {
      ...createContentFormTree(),
    },
    scope: {
      companies: [],
      operationalTrainNumber: {
        mode: 'all',
        filters: [],
      },
      tafTapLocationReferences: [],
    },
    periods: [],
  });
  protected readonly ruIndicationForm = form(this.ruIndicationModel, (ruIndication) => {
    oneLanguageRequired(ruIndication.content, {
      message: $localize`:@@ru_indications_form_one_language_error:Mindestens eine Sprache muss erfasst werden`,
    });

    languageRequired(ruIndication.content.de, {
      message: $localize`:@@form_field_error_required:Feld darf nicht leer sein`,
    });
    languageRequired(ruIndication.content.fr, {
      message: $localize`:@@form_field_error_required:Feld darf nicht leer sein`,
    });
    languageRequired(ruIndication.content.it, {
      message: $localize`:@@form_field_error_required:Feld darf nicht leer sein`,
    });

    arrayRequired(ruIndication.scope.companies, {
      message: $localize`:@@form_field_error_required:Feld darf nicht leer sein`,
    });

    arrayRequired(ruIndication.scope.operationalTrainNumber.filters, {
      message: $localize`:@@ru_indications_form_train_filter_required_error:Mindestens eine Zugnummer bzw. Bereich muss hinzugefügt werden`,
      when: (context) =>
        context.valueOf(ruIndication.scope.operationalTrainNumber.mode) === 'filtered',
    });
    hidden(ruIndication.scope.operationalTrainNumber.filters, {
      when: (context) => context.valueOf(ruIndication.scope.operationalTrainNumber.mode) === 'all',
    });

    arrayRequired(ruIndication.scope.tafTapLocationReferences, {
      message: $localize`:@@form_field_error_required:Feld darf nicht leer sein`,
    });
  });

  protected readonly stepchange = signal<SbbStepChangeEvent | undefined>(undefined);

  private readonly stepper = viewChild.required(SbbStepper);
  private readonly steps = viewChildren(SbbStep);

  protected readonly isLastStep = computed(() => {
    const selectedIndex = this.stepchange()?.selectedIndex;
    const lastStep = this.steps().length - 1;
    return selectedIndex === lastStep;
  });
  protected readonly isStepDisabled = computed(() => {
    const step = this.stepchange()?.selectedIndex;
    if (step === 0) {
      return this.ruIndicationForm.content().invalid();
    } else if (step === 1) {
      return this.ruIndicationForm.scope().invalid();
    } else {
      return false;
    }
  });

  constructor() {
    this.isEdit = this.dialogData.ruIndication?.id !== undefined;
    this.dialogTitle = this.isEdit
      ? $localize`:@@ru_indications_dialog_title_edit:Hinweis bearbeiten`
      : $localize`:@@ru_indications_dialog_title_create:Hinweis erfassen`;

    if (this.isEdit && this.dialogData.ruIndication) {
      const ruIndication = this.dialogData.ruIndication;
      this.ruIndicationModel.update((initial) => ({
        content: {
          category: ruIndication.content.category ?? initial.content.category,
          de: {
            title: ruIndication.content.de?.title ?? initial.content.de.title,
            text: ruIndication.content.de?.text ?? initial.content.de.text,
          },
          fr: {
            title: ruIndication.content.fr?.title ?? initial.content.fr.title,
            text: ruIndication.content.fr?.text ?? initial.content.fr.text,
          },
          it: {
            title: ruIndication.content.it?.title ?? initial.content.it.title,
            text: ruIndication.content.it?.text ?? initial.content.it.text,
          },
        },
        scope: {
          companies: ruIndication.scope.companies ?? initial.scope.companies,
          operationalTrainNumber: {
            mode:
              ruIndication.scope.operationalTrainNumberFilters
              && ruIndication.scope.operationalTrainNumberFilters.length > 0
                ? 'filtered'
                : 'all',
            filters:
              ruIndication.scope.operationalTrainNumberFilters
              ?? initial.scope.operationalTrainNumber.filters,
          },
          tafTapLocationReferences:
            ruIndication.scope.tafTapLocationReferences ?? initial.scope.tafTapLocationReferences,
        },
        periods: ruIndication.periods,
      }));
    }

    effect(() => {
      const filterMode = this.ruIndicationForm.scope.operationalTrainNumber.mode().value();
      if (filterMode === 'all') {
        this.ruIndicationForm.scope.operationalTrainNumber.filters().value.set([]);
      }
    });
  }

  protected next() {
    this.stepper().next();
  }

  get formValue(): RuIndication {
    const formValue = this.ruIndicationModel();
    return {
      content: contentFormValue(formValue.content),
      scope: {
        companies: formValue.scope.companies,
        operationalTrainNumberFilters: formValue.scope.operationalTrainNumber.filters,
        tafTapLocationReferences: formValue.scope.tafTapLocationReferences,
      },
      periods: formValue.periods,
    };
  }
}
