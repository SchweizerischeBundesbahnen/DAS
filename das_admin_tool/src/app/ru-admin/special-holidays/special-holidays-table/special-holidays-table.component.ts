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
import { SCHEDULE_TYPE_LABELS, ScheduleType, SpecialHoliday } from '~ru-admin/ru-admin-api';
import { CompanyService } from '~shared/companies-input/company.service';
import { TableBottomBar } from '~shared/table-bottom-bar/table-bottom-bar';
import { TableSearchHeader } from '~shared/table-search-header/table-search-header';
import { SpecialHolidayService } from '../special-holiday.service';

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
  private readonly specialHolidayService = inject(SpecialHolidayService);
  private readonly companyService = inject(CompanyService);

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

  protected readonly filterModel = signal({ search: '' });
  protected readonly filterForm = form(this.filterModel);

  private readonly bottomBar = viewChild.required(TableBottomBar);
  private readonly sort = viewChild.required<SbbSort>(SbbSort);

  constructor() {
    effect(() => {
      if (this.specialHolidayService.specialHolidaysResource.hasValue()) {
        this.dataSource.data = this.specialHolidayService.specialHolidaysResource.value().data;
      }
    });
    afterNextRender(() => {
      this.dataSource.paginator = this.bottomBar().paginator();
      this.dataSource.sort = this.sort();
    });
    this.dataSource.filterPredicate = (data: SpecialHoliday, filter: SpecialHolidayFilter) =>
      this.searchFilter(filter, data);
    effect(() => {
      this.dataSource.filter = this.filterModel();
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
    return SCHEDULE_TYPE_LABELS().find((label) => label.value === type)?.label ?? '';
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
