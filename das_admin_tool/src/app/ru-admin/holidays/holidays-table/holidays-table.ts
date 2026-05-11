import {Component, computed, effect, inject, viewChild} from '@angular/core';
import {SbbSort, SbbTableDataSource, SbbTableModule} from '@sbb-esta/lyne-angular/table';
import {SbbSecondaryButton} from '@sbb-esta/lyne-angular/button/secondary-button';
import {SbbCompactPaginator} from '@sbb-esta/lyne-angular/paginator/compact-paginator';
import {SbbMiniButton} from '@sbb-esta/lyne-angular/button/mini-button';
import {SelectionModel} from '@angular/cdk/collections';
import {SbbCheckboxModule} from '@sbb-esta/lyne-angular/checkbox';
import {SbbFormFieldModule} from '@sbb-esta/lyne-angular/form-field';
import {SbbIconModule} from '@sbb-esta/lyne-angular/icon';
import {ReactiveFormsModule} from '@angular/forms';
import {SbbTransparentButton} from '@sbb-esta/lyne-angular/button/transparent-button';
import {Holiday, HOLIDAY_TYPE_LABELS, HolidayType} from '../../ru-admin-api';
import {HolidayService} from '../holiday.service';
import {DatePipe} from '@angular/common';
import {CompaniesApi} from '../../../shared/companies-input/companies-api.service';

@Component({
  selector: 'app-holidays-table',
  imports: [
    SbbTableModule,
    SbbSecondaryButton,
    SbbTransparentButton,
    SbbCompactPaginator,
    SbbMiniButton,
    SbbCheckboxModule,
    SbbFormFieldModule,
    SbbIconModule,
    ReactiveFormsModule,
    DatePipe,
  ],
  templateUrl: './holidays-table.html',
  styleUrl: './holidays-table.css',
})
export class HolidaysTable {
  protected dataSource = new SbbTableDataSource<Holiday>();
  protected columns = ['select', 'name', 'validAt', 'type', 'companies', 'action'];
  protected selection = new SelectionModel<Holiday>(true, []);
  protected readonly PAGE_SIZE = 20;

  private readonly holidayService = inject(HolidayService);
  private readonly companiesApi = inject(CompaniesApi);
  private readonly companyNamesByCode = computed(() => {
    if (!this.companiesApi.companies.hasValue()) {
      return new Map<string, string>();
    }

    return new Map(this.companiesApi.companies.value().data.map((company) => [company.code, company.name]));
  });
  private readonly paginator = viewChild.required<SbbCompactPaginator>(SbbCompactPaginator);
  private readonly sort = viewChild.required<SbbSort>(SbbSort);

  constructor() {
    effect(() => {
      if (this.holidayService.holidaysResource.hasValue()) {
        this.dataSource.data = this.holidayService.holidaysResource.value().data;
      }
      this.dataSource.paginator = this.paginator();
      this.dataSource.sort = this.sort();
    });
  }

  protected async edit(holiday: Holiday): Promise<void> {
    await this.holidayService.edit(holiday);
  }

  protected async add(): Promise<void> {
    await this.holidayService.add();
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

  protected async deleteSelected(): Promise<void> {
    await this.holidayService.deleteAll(this.selection.selected);
    this.selection.clear();
  }

  protected typeLabel(type: HolidayType) {
    return HOLIDAY_TYPE_LABELS.find((label) => label.value === type)?.label ?? ''
  }

  protected companiesValue(companyCodes: string[]) {
    return companyCodes.map((companyCode) => this.companyNamesByCode().get(companyCode) ?? companyCode).sort().join(', ');
  }
}
