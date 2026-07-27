import { Component, inject, input } from '@angular/core';
import { FormControl, ReactiveFormsModule } from '@angular/forms';
import { SbbFormFieldModule } from '@sbb-esta/lyne-angular/form-field';
import { SbbIconModule } from '@sbb-esta/lyne-angular/icon';
import { SbbSelectModule } from '@sbb-esta/lyne-angular/select';
import { LanguageProvider } from '../language-provider';

@Component({
  selector: 'app-table-search-header',
  imports: [ReactiveFormsModule, SbbFormFieldModule, SbbIconModule, SbbSelectModule],
  templateUrl: './table-search-header.html',
  styleUrl: './table-search-header.css',
})
export class TableSearchHeader {
  protected readonly languageProvider = inject(LanguageProvider);

  readonly searchControl = input.required<FormControl<string>>();
  readonly languageControl = input<FormControl<string>>();
  readonly searchPlaceholder = input($localize`:@@table_search_placeholder:Suchen`);
}
