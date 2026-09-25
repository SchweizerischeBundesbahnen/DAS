import { SelectionModel } from '@angular/cdk/collections';
import { DatePipe } from '@angular/common';
import { afterNextRender, Component, effect, inject, signal, viewChild } from '@angular/core';
import { form } from '@angular/forms/signals';
import { SbbMiniButton } from '@sbb-esta/lyne-angular/button';
import { SbbCheckboxModule } from '@sbb-esta/lyne-angular/checkbox';
import {
  SbbSort,
  SbbTableDataSource,
  SbbTableFilter,
  SbbTableModule,
} from '@sbb-esta/lyne-angular/table';
import { RuIndicationTemplate } from '~ru-admin/ru-admin-api';
import { LanguageCode, LanguageProvider } from '~shared/language-provider';
import { TableBottomBar } from '~shared/table-bottom-bar/table-bottom-bar';
import { TableSearchHeader } from '~shared/table-search-header/table-search-header';
import { RuIndicationTemplateService } from '../ru-indication-template.service';

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
  private readonly languageProvider = inject(LanguageProvider);
  private readonly ruIndicationTemplateService = inject(RuIndicationTemplateService);

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

  protected readonly filterModel = signal({
    search: '',
    language: this.languageProvider.currentLanguage.path,
  });
  protected readonly filterForm = form(this.filterModel);

  private readonly bottomBar = viewChild.required(TableBottomBar);
  private readonly sort = viewChild.required<SbbSort>(SbbSort);

  constructor() {
    effect(() => {
      if (this.ruIndicationTemplateService.ruIndicationTemplatesResource.hasValue()) {
        this.dataSource.data =
          this.ruIndicationTemplateService.ruIndicationTemplatesResource.value().data;
      }
    });
    afterNextRender(() => {
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
    effect(() => {
      this.dataSource.filter = this.filterModel();
    });
  }

  protected currentLanguage(ruIndicationTemplate: RuIndicationTemplate) {
    return ruIndicationTemplate[this.filterModel().language];
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
