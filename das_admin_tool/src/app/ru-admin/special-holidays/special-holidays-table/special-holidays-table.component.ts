import { Component, effect, inject, viewChild } from '@angular/core';
import {
  SbbSort,
  SbbTableDataSource,
  SbbTableFilter,
  SbbTableModule,
} from '@sbb-esta/lyne-angular/table';
import { SbbMiniButton } from '@sbb-esta/lyne-angular/button/mini-button';
import { SbbCheckboxModule } from '@sbb-esta/lyne-angular/checkbox';
import { SelectionModel } from '@angular/cdk/collections';
import { SCHEDULE_TYPE_LABELS, ScheduleType, SpecialHoliday } from '../../ru-admin-api';
import { SpecialHolidayService } from '../special-holiday.service';
import { DatePipe } from '@angular/common';
import { CompanyService } from '../../../shared/companies-input/company.service';
import { TableBottomBar } from '../../../shared/table-bottom-bar/table-bottom-bar';
import { TableSearchHeader } from '../../../shared/table-search-header/table-search-header';
import { FormControl } from '@angular/forms';
import { takeUntilDestroyed } from '@angular/core/rxjs-interop';
import { startWith } from 'rxjs';

interface SpecialHolidayFilter extends SbbTableFilter {
  search: string;
}

@Component({
  selector: 'app-special-holidays-table',
  imports: [
    SbbTableModule,
    SbbMiniButton,
    SbbCheckboxModule,
    DatePipe,
    TableBottomBar,
    TableSearchHeader,
  ],
  templateUrl: './special-holidays-table.component.html',
  styleUrl: './special-holidays-table.component.css',
})
export class SpecialHolidaysTable {
  protected dataSource = new SbbTableDataSource<SpecialHoliday, SpecialHolidayFilter>();
  protected columns = [
    'select',
    'name',
    'date',
    'scheduleType',
    'companies',
    'lastModifiedAt',
    'lastModifiedBy',
    'action',
  ];
  protected selection = new SelectionModel<SpecialHoliday>(true, []);
  protected isDeleting = false;
  protected readonly searchControl = new FormControl('', { nonNullable: true });

  private readonly specialHolidayService = inject(SpecialHolidayService);
  private readonly companyService = inject(CompanyService);

  private readonly bottomBar = viewChild.required(TableBottomBar);
  private readonly sort = viewChild.required<SbbSort>(SbbSort);

  constructor() {
    effect(() => {
      if (this.specialHolidayService.specialHolidaysResource.hasValue()) {
        this.dataSource.data = this.specialHolidayService.specialHolidaysResource.value().data;
      }
      this.dataSource.paginator = this.bottomBar().paginator();
      this.dataSource.sort = this.sort();
    });
    this.dataSource.filterPredicate = (data: SpecialHoliday, filter: SpecialHolidayFilter) =>
      this.searchFilter(filter, data);
    this.searchControl.valueChanges
      .pipe(startWith(this.searchControl.value), takeUntilDestroyed())
      .subscribe((search) => {
        this.dataSource.filter = { search };
      });
  }

  protected async edit(holiday: SpecialHoliday): Promise<void> {
    await this.specialHolidayService.edit(holiday);
  }

  protected async add(): Promise<void> {
    await this.specialHolidayService.add();
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

  protected async deleteSelected(): Promise<void> {
    if (this.isDeleting) return;
    this.isDeleting = true;
    try {
      await this.specialHolidayService.deleteAll(this.selection.selected);
      this.selection.clear();
    } finally {
      this.isDeleting = false;
    }
  }

  protected scheduleTypeLabel(type: ScheduleType) {
    return SCHEDULE_TYPE_LABELS.find((label) => label.value === type)?.label ?? '';
  }

  protected companiesValue(companyCodes: string[]) {
    return this.companyService.formatCompanies(companyCodes);
  }

  private searchFilter(filter: SpecialHolidayFilter, data: SpecialHoliday): boolean {
    const search = filter.search.toLowerCase();
    if (!search) return true;
    return (
      (data.name?.toLowerCase().includes(search)
        || data.date?.toString().toLowerCase().includes(search)
        || this.scheduleTypeLabel(data.scheduleType).toLowerCase().includes(search)
        || this.companiesValue(data.companies).toLowerCase().includes(search)
        || (data.lastModifiedBy ?? '').toLowerCase().includes(search)
        || (data.lastModifiedAt ?? '').toString().toLowerCase().includes(search))
      ?? false
    );
  }
}
