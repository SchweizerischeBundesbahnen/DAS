import { SelectionModel } from '@angular/cdk/collections';
import { DatePipe } from '@angular/common';
import { Component, effect, inject, viewChild } from '@angular/core';
import { takeUntilDestroyed } from '@angular/core/rxjs-interop';
import { FormControl, FormGroup, ReactiveFormsModule } from '@angular/forms';
import { SbbMiniButton } from '@sbb-esta/lyne-angular/button/mini-button';
import { SbbSecondaryButton } from '@sbb-esta/lyne-angular/button/secondary-button';
import { SbbTransparentButton } from '@sbb-esta/lyne-angular/button/transparent-button';
import { SbbCheckboxModule } from '@sbb-esta/lyne-angular/checkbox';
import { SbbFormFieldModule } from '@sbb-esta/lyne-angular/form-field';
import { SbbIconModule } from '@sbb-esta/lyne-angular/icon';
import { SbbCompactPaginator } from '@sbb-esta/lyne-angular/paginator/compact-paginator';
import { SbbSelectModule } from '@sbb-esta/lyne-angular/select';
import {
  SbbSort,
  SbbTableDataSource,
  SbbTableFilter,
  SbbTableModule,
} from '@sbb-esta/lyne-angular/table';
import { RuIndicationTemplate } from '~ru-admin/ru-admin-api';
import { CompanyService } from '~shared/companies-input/company.service';
import { LanguageCode, LanguageProvider } from '~shared/language-provider';
import { RuIndicationTemplateService } from '../ru-indication-template.service';

interface RuIndicationTemplateFilter extends SbbTableFilter {
  search: string;
  language: LanguageCode;
}

@Component({
  selector: 'app-ru-indication-templates-table',
  imports: [
    SbbTableModule,
    SbbSecondaryButton,
    SbbTransparentButton,
    SbbCompactPaginator,
    SbbMiniButton,
    SbbCheckboxModule,
    SbbFormFieldModule,
    SbbIconModule,
    SbbSelectModule,
    ReactiveFormsModule,
    DatePipe,
  ],
  templateUrl: './ru-indication-templates-table.html',
  styleUrl: './ru-indication-templates-table.css',
})
export class RuIndicationTemplatesTable {
  protected readonly languageProvider = inject(LanguageProvider);
  protected readonly companyService = inject(CompanyService);
  protected dataSource = new SbbTableDataSource<RuIndicationTemplate, RuIndicationTemplateFilter>();
  protected columns = [
    'select',
    'category',
    'title',
    'text',
    'companies',
    'lastModifiedAt',
    'lastModifiedBy',
    'action',
  ];
  protected selection = new SelectionModel<RuIndicationTemplate>(true, []);
  protected form = new FormGroup({
    search: new FormControl('', { nonNullable: true }),
    language: new FormControl(this.languageProvider.currentLanguage.path, { nonNullable: true }),
  });
  protected isDeleting = false;
  protected readonly PAGE_SIZE = 20;
  private readonly ruIndicationTemplateService = inject(RuIndicationTemplateService);
  private readonly paginator = viewChild.required<SbbCompactPaginator>(SbbCompactPaginator);
  private readonly sort = viewChild.required<SbbSort>(SbbSort);

  constructor() {
    effect(() => {
      if (this.ruIndicationTemplateService.ruIndicationTemplatesResource.hasValue()) {
        this.dataSource.data =
          this.ruIndicationTemplateService.ruIndicationTemplatesResource.value().data;
      }
      this.dataSource.paginator = this.paginator();
      this.dataSource.sort = this.sort();
    });
    this.dataSource.filterPredicate = (
      data: RuIndicationTemplate,
      filter: RuIndicationTemplateFilter,
    ) => this.searchFilter(filter, data);
    this.dataSource.sortingDataAccessor = (data, col) => this.getValue(data, col) ?? '';
    this.form.valueChanges.pipe(takeUntilDestroyed()).subscribe((form) => {
      this.dataSource.filter = form as RuIndicationTemplateFilter;
    });
  }

  protected getValue(row: RuIndicationTemplate, column: string) {
    switch (column) {
      case 'title':
      case 'text':
        return row[this.form.get('language')!.value]?.[column] ?? '';

      case 'companies':
        return this.companiesValue(row.companies);

      default:
        return row[column as keyof RuIndicationTemplate] as string;
    }
  }

  protected async edit(ruIndicationTemplate: RuIndicationTemplate) {
    await this.ruIndicationTemplateService.edit(ruIndicationTemplate);
  }

  protected async add() {
    await this.ruIndicationTemplateService.add();
  }

  protected isAllSelected() {
    const numSelected = this.selection.selected.length;
    const numRows = this.dataSource.filteredData.length;
    return numSelected === numRows;
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

  protected companiesValue(companies: string[]) {
    return this.companyService.formatCompanies(companies);
  }

  private searchFilter(filter: RuIndicationTemplateFilter, data: RuIndicationTemplate) {
    const search = filter.search.toLowerCase();
    return (
      (this.getValue(data, 'title')?.toLowerCase().includes(search)
        || this.getValue(data, 'text')?.toLowerCase().includes(search)
        || this.companiesValue(data.companies).toLowerCase().includes(search)
        || data.category.toLowerCase().includes(search)
        || data.lastModifiedBy?.toLowerCase().includes(search))
      ?? data.lastModifiedAt?.toString().toLowerCase().includes(search)
      ?? true
    );
  }
}
