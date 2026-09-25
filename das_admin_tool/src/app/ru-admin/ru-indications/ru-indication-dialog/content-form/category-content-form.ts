import { Component, computed, effect, input, signal } from '@angular/core';
import { FieldTree, form, FormField } from '@angular/forms/signals';
import { SbbAutocompleteModule } from '@sbb-esta/lyne-angular/autocomplete';
import { SbbFormFieldModule } from '@sbb-esta/lyne-angular/form-field';
import { SbbOptionModule } from '@sbb-esta/lyne-angular/option';
import { RuIndicationContent } from '~ru-admin/ru-admin-api';
import {
  RuIndicationContentForm,
  RuIndicationContentWithCategoryData,
} from '~ru-admin/ru-indication-content-form/ru-indication-content-form.component';
import { RuIndicationDialogData } from '~ru-admin/ru-indications/ru-indication.service';

@Component({
  selector: 'app-category-content-form',
  imports: [
    FormField,
    SbbAutocompleteModule,
    SbbFormFieldModule,
    SbbOptionModule,
    RuIndicationContentForm,
  ],
  templateUrl: './category-content-form.html',
  styleUrl: './category-content-form.css',
})
export class CategoryContentForm {
  readonly form = input.required<FieldTree<RuIndicationContentWithCategoryData>>();
  readonly dialogData = input.required<RuIndicationDialogData>();

  protected templateField = form(signal<RuIndicationContent | null>(null));

  protected readonly searchTerm = signal<string>('');

  protected readonly filteredTemplates = computed(() => {
    const searchTerm = this.searchTerm();
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
        this.templateField().value.update((current) => ({ ...current, category }));
      }
    });
    effect(() => {
      const selected = this.templateField().value();
      if (selected) {
        this.form()().value.update((current) => ({
          ...current,
          ...selected,
          de: {
            ...current.de,
            ...selected.de,
          },
          fr: {
            ...current.fr,
            ...selected.fr,
          },
          it: {
            ...current.it,
            ...selected.it,
          },
        }));
      }
    });
  }

  protected displayWith: (value: RuIndicationContent | undefined) => string = (value) =>
    value?.category ?? '';

  protected onType(event: Event) {
    const input = event.target as HTMLInputElement;
    this.searchTerm.set(input.value);
  }
}
