import { Component, effect, inject, viewChild } from '@angular/core';
import {
  SbbSort,
  SbbTableDataSource,
  SbbTableFilter,
  SbbTableModule,
} from '@sbb-esta/lyne-angular/table';
import { RuIndicationTemplate } from '../../ru-admin-api';
import { takeUntilDestroyed } from '@angular/core/rxjs-interop';
import { startWith } from 'rxjs';
import { RuIndicationTemplateService } from '../ru-indication-template.service';
import { SbbMiniButton } from '@sbb-esta/lyne-angular/button/mini-button';
import { SbbCheckboxModule } from '@sbb-esta/lyne-angular/checkbox';
import { SelectionModel } from '@angular/cdk/collections';
import { FormControl, FormGroup } from '@angular/forms';
import { LanguageCode, LanguageProvider } from '../../../shared/language-provider';
import { DatePipe } from '@angular/common';
import { TableBottomBar } from '../../../shared/table-bottom-bar/table-bottom-bar';
import { TableSearchHeader } from '../../../shared/table-search-header/table-search-header';

interface RuIndicationTemplateFilter extends SbbTableFilter {
  search: string;
  language: LanguageCode;
}

@Component({
  selector: 'app-ru-indication-templates-table',
  imports: [
    SbbTableModule,
    SbbMiniButton,
    SbbCheckboxModule,
    DatePipe,
    TableBottomBar,
    TableSearchHeader,
  ],
  templateUrl: './ru-indication-templates-table.html',
  styleUrl: './ru-indication-templates-table.css',
})
export class RuIndicationTemplatesTable {
  protected dataSource = new SbbTableDataSource<RuIndicationTemplate, RuIndicationTemplateFilter>();
  protected columns = [
    'select',
    'category',
    'title',
    'text',
    'lastModifiedAt',
    'lastModifiedBy',
    'action',
  ];
  protected selection = new SelectionModel<RuIndicationTemplate>(true, []);
  protected isDeleting = false;
  private readonly languageProvider = inject(LanguageProvider);
  protected form = new FormGroup({
    search: new FormControl('', { nonNullable: true }),
    language: new FormControl(this.languageProvider.currentLanguage.path, { nonNullable: true }),
  });
  private readonly ruIndicationTemplateService = inject(RuIndicationTemplateService);
  private readonly bottomBar = viewChild.required(TableBottomBar);
  private readonly sort = viewChild.required<SbbSort>(SbbSort);

  constructor() {
    effect(() => {
      if (this.ruIndicationTemplateService.ruIndicationTemplatesResource.hasValue()) {
        this.dataSource.data =
          this.ruIndicationTemplateService.ruIndicationTemplatesResource.value().data;
      }
      this.dataSource.paginator = this.bottomBar().paginator();
      this.dataSource.sort = this.sort();
    });
    this.dataSource.filterPredicate = (
      data: RuIndicationTemplate,
      filter: RuIndicationTemplateFilter,
    ) => this.searchFilter(filter, data);
    this.dataSource.sortingDataAccessor = (data: RuIndicationTemplate, column: string) => {
      if (column === 'title' || column === 'text') {
        return this.currentLanguage(data)?.[column] ?? '';
      }
      return data[column as keyof RuIndicationTemplate] as string;
    };
    this.form.valueChanges
      .pipe(startWith(this.form.value), takeUntilDestroyed())
      .subscribe((form) => {
        this.dataSource.filter = form as RuIndicationTemplateFilter;
      });
  }

  protected currentLanguage(ruIndicationTemplate: RuIndicationTemplate) {
    return ruIndicationTemplate[this.form.controls.language.value];
  }

  protected async edit(ruIndicationTemplate: RuIndicationTemplate) {
    await this.ruIndicationTemplateService.edit(ruIndicationTemplate);
  }

  protected async add() {
    await this.ruIndicationTemplateService.add();
  }

  protected isAllSelected() {
    return this.selection.selected.length === this.dataSource.filteredData.length;
  }

  protected parentToggle() {
    if (this.isAllSelected()) {
      this.selection.clear();
    } else {
      this.dataSource.filteredData.forEach((row) => this.selection.select(row));
    }
  }

  protected async deleteSelected() {
    if (this.isDeleting) return;
    this.isDeleting = true;
    try {
      await this.ruIndicationTemplateService.deleteAll(this.selection.selected);
      this.selection.clear();
    } finally {
      this.isDeleting = false;
    }
  }

  private searchFilter(filter: RuIndicationTemplateFilter, data: RuIndicationTemplate) {
    const language = filter.language;
    if (language && !data[language]?.title) {
      return false;
    }
    const search = filter.search.toLowerCase();
    if (!search) return true;
    return (
      ((this.currentLanguage(data)?.title ?? '').toLowerCase().includes(search)
        || (this.currentLanguage(data)?.text ?? '').toLowerCase().includes(search)
        || data.category.toLowerCase().includes(search)
        || (data.lastModifiedBy ?? '').toLowerCase().includes(search)
        || (data.lastModifiedAt ?? '').toString().toLowerCase().includes(search))
      ?? true
    );
  }
}
