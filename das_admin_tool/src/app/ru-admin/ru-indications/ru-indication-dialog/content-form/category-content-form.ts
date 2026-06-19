import { Component, computed, effect, input, signal } from '@angular/core';
import { FormControl, FormGroup, ReactiveFormsModule } from '@angular/forms';
import {
  contentFormValue,
  LanguageContentForm,
  RuIndicationContentForm,
} from '../../../ru-indication-content-form/ru-indication-content-form.component';
import { SbbAutocompleteModule } from '@sbb-esta/lyne-angular/autocomplete';
import { SbbFormFieldModule } from '@sbb-esta/lyne-angular/form-field';
import { SbbOptionModule } from '@sbb-esta/lyne-angular/option';
import { RuIndicationContent } from '../../../ru-admin-api';
import { toSignal } from '@angular/core/rxjs-interop';
import { RuIndicationDialogData } from '../../ru-indication.service';

export interface CategoryContentFormGroup extends LanguageContentForm {
  category: FormControl<string>;
}

interface CategoryContent {
  category: string;
}

@Component({
  selector: 'app-category-content-form',
  imports: [
    ReactiveFormsModule,
    SbbAutocompleteModule,
    SbbFormFieldModule,
    SbbOptionModule,
    RuIndicationContentForm,
  ],
  templateUrl: './category-content-form.html',
  styleUrl: './category-content-form.css',
})
export class CategoryContentForm {
  readonly form = input.required<FormGroup<CategoryContentFormGroup>>();
  readonly dialogData = input.required<RuIndicationDialogData>();

  protected templateControl = new FormControl<CategoryContent | null>(null);
  protected readonly searchTerm = signal<string>('');
  private readonly templateValue = toSignal(this.templateControl.valueChanges, {
    initialValue: null,
  });
  protected readonly filteredTemplates = computed(() => {
    const searchTerm = this.searchTerm();
    const selected = this.templateValue();
    if (selected) {
      this.form().patchValue(selected);
    }
    if (typeof searchTerm === 'string') {
      return this.dialogData().templates.filter((val) =>
        val.category.toLowerCase().includes(searchTerm.toLowerCase()),
      );
    }
    return this.dialogData().templates;
  });

  constructor() {
    effect(() => {
      const category = this.dialogData().ruIndication?.content?.category;
      if (category) {
        this.templateControl.patchValue({ category });
      }
    });
  }

  get formValue(): RuIndicationContent {
    return {
      category: this.templateControl.value?.category,
      ...contentFormValue(this.languageContentForm),
    };
  }

  protected get languageContentForm(): FormGroup<LanguageContentForm> {
    return new FormGroup({
      de: this.form().controls.de,
      fr: this.form().controls.fr,
      it: this.form().controls.it,
    });
  }

  protected displayWith: (value: CategoryContent | undefined) => string = (value) =>
    value?.category ?? '';

  protected onType(event: Event) {
    const input = event.target as HTMLInputElement;
    this.searchTerm.set(input.value);
  }
}
