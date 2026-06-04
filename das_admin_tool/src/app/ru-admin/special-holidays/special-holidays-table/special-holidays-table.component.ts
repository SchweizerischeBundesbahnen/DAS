import { Component, effect, inject, viewChild } from '@angular/core';
import { SbbSort, SbbTableDataSource, SbbTableModule } from '@sbb-esta/lyne-angular/table';
import { SbbSecondaryButton } from '@sbb-esta/lyne-angular/button/secondary-button';
import { SbbCompactPaginator } from '@sbb-esta/lyne-angular/paginator/compact-paginator';
import { SbbMiniButton } from '@sbb-esta/lyne-angular/button/mini-button';
import { SelectionModel } from '@angular/cdk/collections';
import { SbbCheckboxModule } from '@sbb-esta/lyne-angular/checkbox';
import { SbbFormFieldModule } from '@sbb-esta/lyne-angular/form-field';
import { ReactiveFormsModule } from '@angular/forms';
import { SbbTransparentButton } from '@sbb-esta/lyne-angular/button/transparent-button';
import { SCHEDULE_TYPE_LABELS, ScheduleType, SpecialHoliday } from '../../ru-admin-api';
import { SpecialHolidayService } from '../special-holiday.service';
import { DatePipe } from '@angular/common';
import { CompanyService } from '../../../shared/companies-input/company.service';

@Component({
  selector: 'app-special-holidays-table',
  imports: [
    SbbTableModule,
    SbbSecondaryButton,
    SbbTransparentButton,
    SbbCompactPaginator,
    SbbMiniButton,
    SbbCheckboxModule,
    SbbFormFieldModule,
    ReactiveFormsModule,
    DatePipe,
  ],
  templateUrl: './special-holidays-table.component.html',
  styleUrl: './special-holidays-table.component.css',
})
export class SpecialHolidaysTable {
  protected dataSource = new SbbTableDataSource<SpecialHoliday>();
  protected columns = ['select', 'name', 'date', 'scheduleType', 'companies', 'lastModifiedAt', 'lastModifiedBy', 'action'];
  protected selection = new SelectionModel<SpecialHoliday>(true, []);
  protected readonly PAGE_SIZE = 20;
  protected isDeleting = false;

  private readonly specialHolidayService = inject(SpecialHolidayService);
  private readonly companyService = inject(CompanyService);

  private readonly paginator = viewChild.required<SbbCompactPaginator>(SbbCompactPaginator);
  private readonly sort = viewChild.required<SbbSort>(SbbSort);

  constructor() {
    effect(() => {
      if (this.specialHolidayService.specialHolidaysResource.hasValue()) {
        this.dataSource.data = this.specialHolidayService.specialHolidaysResource.value().data;
      }
      this.dataSource.paginator = this.paginator();
      this.dataSource.sort = this.sort();
    });
  }

  protected async edit(holiday: SpecialHoliday): Promise<void> {
    await this.specialHolidayService.edit(holiday);
  }

  protected async add(): Promise<void> {
    await this.specialHolidayService.add();
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
    return SCHEDULE_TYPE_LABELS.find((label) => label.value === type)?.label ?? ''
  }

  protected companiesValue(companyCodes: string[]) {
    return companyCodes
      .map((companyCode) => this.companyService.getName(companyCode) ?? companyCode)
      .sort((a, b) => a.localeCompare(b))
      .join(', ');
  }
}
