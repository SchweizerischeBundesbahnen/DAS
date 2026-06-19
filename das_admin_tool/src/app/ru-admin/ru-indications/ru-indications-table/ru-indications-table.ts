import { Component, effect, inject, viewChild } from '@angular/core';
import {
  SbbSort,
  SbbTableDataSource,
  SbbTableFilter,
  SbbTableModule,
} from '@sbb-esta/lyne-angular/table';
import { SbbMiniButton } from '@sbb-esta/lyne-angular/button/mini-button';
import { SbbFormFieldModule } from '@sbb-esta/lyne-angular/form-field';
import { FormControl, FormGroup, ReactiveFormsModule } from '@angular/forms';
import { RuIndicationService } from '../ru-indication.service';
import { takeUntilDestroyed } from '@angular/core/rxjs-interop';
import { startWith } from 'rxjs';
import { LanguageCode, LanguageProvider } from '../../../shared/language-provider';
import { CompanyService } from '../../../shared/companies-input/company.service';
import { LocationService } from '../ru-indication-dialog/locations-input/location.service';
import { displayTrainNumberFilter } from '../ru-indication-dialog/train-number-input/train-number-input';
import { DatePipe } from '@angular/common';
import { displayPeriod } from '../ru-indication-dialog/periods-input/periods-input';
import { RU_INDICATION_STATUS_LABELS, RuIndication } from '../../ru-admin-api';
import { SbbCheckbox } from '@sbb-esta/lyne-angular/checkbox';
import { SelectionModel } from '@angular/cdk/collections';
import { TableBottomBar } from '../../../shared/table-bottom-bar/table-bottom-bar';
import { TableSearchHeader } from '../../../shared/table-search-header/table-search-header';

export interface RuIndicationFilter extends SbbTableFilter {
  search: string;
  language: LanguageCode;
  category: string;
  companies: string;
  trainNumbers: string;
  locations: string;
  periods: string;
}

@Component({
  selector: 'app-ru-indications-table',
  imports: [
    SbbTableModule,
    SbbMiniButton,
    SbbFormFieldModule,
    ReactiveFormsModule,
    DatePipe,
    SbbCheckbox,
    TableBottomBar,
    TableSearchHeader,
  ],
  templateUrl: './ru-indications-table.html',
  styleUrl: './ru-indications-table.css',
})
export class RuIndicationsTable {
  protected readonly companyService = inject(CompanyService);
  protected readonly locationService = inject(LocationService);
  protected dataSource = new SbbTableDataSource<RuIndication, RuIndicationFilter>();
  protected columns = [
    'select',
    'title',
    'text',
    'category',
    'status',
    'companies',
    'trainNumbers',
    'locations',
    'periods',
    'lastModifiedAt',
    'lastModifiedBy',
    'action',
  ];
  protected filterColumns = [
    'empty',
    'empty',
    'empty',
    'filter-category',
    'empty',
    'filter-companies',
    'filter-train-numbers',
    'filter-locations',
    'filter-periods',
    'empty',
    'empty',
    'empty',
  ];
  protected readonly selection = new SelectionModel<RuIndication>(true, []);
  protected isDeleting = false;
  private readonly languageProvider = inject(LanguageProvider);
  protected form = new FormGroup({
    search: new FormControl('', { nonNullable: true }),
    language: new FormControl(this.languageProvider.currentLanguage.path, { nonNullable: true }),
    category: new FormControl('', { nonNullable: true }),
    companies: new FormControl('', { nonNullable: true }),
    trainNumbers: new FormControl('', { nonNullable: true }),
    locations: new FormControl('', { nonNullable: true }),
    periods: new FormControl('', { nonNullable: true }),
  });
  private readonly ruIndicationService = inject(RuIndicationService);
  private readonly bottomBar = viewChild.required(TableBottomBar);
  private readonly sort = viewChild.required<SbbSort>(SbbSort);

  constructor() {
    effect(() => {
      if (this.ruIndicationService.ruIndicationsResource.hasValue()) {
        this.dataSource.data = this.ruIndicationService.ruIndicationsResource.value().data;
      }
      this.dataSource.paginator = this.bottomBar().paginator();
      this.dataSource.sort = this.sort();
    });
    this.dataSource.filterPredicate = (data: RuIndication, filter: RuIndicationFilter) =>
      this.searchFilter(filter, data);
    this.dataSource.sortingDataAccessor = (data, col) => this.getSortValue(data, col);
    this.form.valueChanges
      .pipe(startWith(this.form.value), takeUntilDestroyed())
      .subscribe((form) => {
        this.dataSource.filter = form as RuIndicationFilter;
      });
  }

  protected titleValue(row: RuIndication): string {
    const language = this.form.controls.language.value ?? 'de';
    return row.content?.[language]?.title ?? '';
  }

  protected textValue(row: RuIndication): string {
    const language = this.form.controls.language.value ?? 'de';
    return row.content?.[language]?.text ?? '';
  }

  protected statusValue(row: RuIndication): string {
    return RU_INDICATION_STATUS_LABELS.find((label) => label.value === row.status)?.label ?? '';
  }

  protected companiesValue(companyCodes: string[]) {
    return this.companyService.formatCompanies(companyCodes);
  }

  protected locationsValue(row: RuIndication): string {
    return (
      row.scope.tafTapLocationReferences
        ?.map(
          (locationCode) =>
            this.locationService.getLocation(locationCode)?.locationAbbreviation ?? locationCode,
        )
        .sort((a, b) => a.localeCompare(b))
        .join(', ') ?? ''
    );
  }

  protected trainNumbersValue(row: RuIndication): string {
    return row.scope.operationalTrainNumberFilters?.map(displayTrainNumberFilter).join(', ') ?? '';
  }

  protected periodsValue(row: RuIndication): string {
    return row.periods
      .map((period) => displayPeriod(period, this.languageProvider.currentLanguage.localeId))
      .join(', ');
  }

  protected async edit(ruIndication: RuIndication): Promise<void> {
    await this.ruIndicationService.edit(ruIndication);
  }

  protected async add(): Promise<void> {
    await this.ruIndicationService.add();
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
      await this.ruIndicationService.deleteAll(this.selection.selected);
      this.selection.clear();
    } finally {
      this.isDeleting = false;
    }
  }

  private getSortValue(row: RuIndication, column: string): string {
    switch (column) {
      case 'title':
        return this.titleValue(row);

      case 'text':
        return this.textValue(row);

      case 'category':
        return row.content.category ?? '';

      case 'status':
        return this.statusValue(row);

      case 'companies':
        return this.companiesValue(row.scope.companies);

      case 'trainNumbers':
        return this.trainNumbersValue(row);

      case 'locations':
        return this.locationsValue(row);

      case 'periods':
        return this.periodsValue(row);

      default:
        return row[column as keyof RuIndication] as string;
    }
  }

  private searchFilter(filter: RuIndicationFilter, data: RuIndication) {
    const language = filter.language;
    if (language && !data.content?.[language]?.title) {
      return false;
    }
    return (this.filterGlobally(filter, data) && this.filterProperties(filter, data)) ?? false;
  }

  private filterGlobally(filter: RuIndicationFilter, data: RuIndication) {
    const search = filter.search.toLowerCase();

    return (
      this.titleValue(data).toLowerCase().includes(search)
      || this.textValue(data).toLowerCase().includes(search)
      || (data.content.category ?? '').toLowerCase().includes(search)
      || this.statusValue(data).toLowerCase().includes(search)
      || this.companiesValue(data.scope.companies).toLowerCase().includes(search)
      || this.trainNumbersValue(data).toLowerCase().includes(search)
      || this.locationsValue(data).toLowerCase().includes(search)
      || this.periodsValue(data).toLowerCase().includes(search)
      || (data.lastModifiedAt ?? '').toString().toLowerCase().includes(search)
      || (data.lastModifiedBy ?? '').toLowerCase().includes(search)
    );
  }

  private filterProperties(filter: RuIndicationFilter, data: RuIndication) {
    const category = filter.category.toLowerCase();
    const companies = filter.companies.toLowerCase();
    const trainNumbers = filter.trainNumbers.toLowerCase();
    const locations = filter.locations.toLowerCase();
    const periods = filter.periods.toLowerCase();

    return (
      (data.content.category ?? '').toLowerCase().includes(category)
      && this.companiesValue(data.scope.companies).toLowerCase().includes(companies)
      && this.trainNumbersValue(data).toLowerCase().includes(trainNumbers)
      && this.locationsValue(data).toLowerCase().includes(locations)
      && this.periodsValue(data).toLowerCase().includes(periods)
    );
  }
}
