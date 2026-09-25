import { Component, inject, input } from '@angular/core';
import { FieldTree, FormField } from '@angular/forms/signals';
import { SbbFormFieldModule } from '@sbb-esta/lyne-angular/form-field';
import { SbbIconModule } from '@sbb-esta/lyne-angular/icon';
import { SbbSelectModule } from '@sbb-esta/lyne-angular/select';
import { LanguageProvider } from '../language-provider';

@Component({
  selector: 'app-table-search-header',
  imports: [FormField, SbbFormFieldModule, SbbIconModule, SbbSelectModule],
  templateUrl: './table-search-header.html',
  styleUrl: './table-search-header.css',
})
export class TableSearchHeader {
  protected readonly languageProvider = inject(LanguageProvider);

  readonly searchField = input.required<FieldTree<string>>();
  readonly languageField = input<FieldTree<string>>();
  readonly searchPlaceholder = input($localize`:@@table_search_placeholder:Suchen`);
}
