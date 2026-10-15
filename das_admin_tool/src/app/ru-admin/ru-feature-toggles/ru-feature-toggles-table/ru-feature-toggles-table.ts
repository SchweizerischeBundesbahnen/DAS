import { DatePipe } from '@angular/common';
import { afterNextRender, Component, effect, inject, signal, viewChild } from '@angular/core';
import { form } from '@angular/forms/signals';
import { SbbButtonModule } from '@sbb-esta/lyne-angular/button';
import {
  SbbSort,
  SbbTableDataSource,
  SbbTableFilter,
  SbbTableModule,
} from '@sbb-esta/lyne-angular/table';
import { SbbToggleCheckModule } from '@sbb-esta/lyne-angular/toggle-check';
import { RU_FEATURE_KEY_LABELS, RuFeature, RuFeatureKey } from '~ru-admin/ru-admin.api';
import { TableBottomBar } from '~shared/components/table-bottom-bar/table-bottom-bar';
import { TableSearchHeader } from '~shared/components/table-search-header/table-search-header';
import { CompanyApi } from '~shared/services/company.api';
import { RuFeatureToggleService } from '../ru-feature-toggle.service';

interface RuFeatureFilter extends SbbTableFilter {
  search: string;
}

@Component({
  selector: 'app-ru-feature-toggles-table',
  imports: [
    SbbTableModule,
    SbbButtonModule,
    SbbToggleCheckModule,
    DatePipe,
    TableBottomBar,
    TableSearchHeader,
  ],
  templateUrl: './ru-feature-toggles-table.html',
  styleUrl: './ru-feature-toggles-table.css',
})
export class RuFeatureTogglesTable {
  private readonly ruFeatureToggleService = inject(RuFeatureToggleService);
  private readonly companyApi = inject(CompanyApi);

  protected dataSource = new SbbTableDataSource<RuFeature, RuFeatureFilter>();
  protected columns = [
    'companyCode',
    'key',
    'enabled',
    'lastModifiedAt',
    'lastModifiedBy',
    'action',
  ];

  protected readonly filterModel = signal({
    search: '',
  });
  protected readonly filterForm = form(this.filterModel);

  private readonly bottomBar = viewChild.required(TableBottomBar);
  private readonly sort = viewChild.required<SbbSort>(SbbSort);

  constructor() {
    effect(() => {
      if (this.ruFeatureToggleService.ruFeaturesResource.hasValue()) {
        this.dataSource.data = this.ruFeatureToggleService.ruFeaturesResource.value().data;
      }
    });
    afterNextRender(() => {
      this.dataSource.paginator = this.bottomBar().paginator();
      this.dataSource.sort = this.sort();
    });
    this.dataSource.filterPredicate = (data: RuFeature, filter: RuFeatureFilter) =>
      this.searchFilter(filter, data);
    effect(() => {
      this.dataSource.filter = this.filterModel();
    });
  }

  protected async edit(ruFeature: RuFeature): Promise<void> {
    await this.ruFeatureToggleService.edit(ruFeature);
  }

  protected async add(): Promise<void> {
    await this.ruFeatureToggleService.add();
  }

  protected companyName(companyCode: string): string {
    return this.companyApi.getName(companyCode) ?? companyCode;
  }

  protected featureKeyLabel(key: RuFeatureKey): string {
    return RU_FEATURE_KEY_LABELS().find((label) => label.value === key)?.label ?? key;
  }

  private searchFilter(filter: RuFeatureFilter, data: RuFeature): boolean {
    const search = filter.search.toLowerCase();
    if (!search) return true;
    return (
      (this.companyName(data.companyCode).toLowerCase().includes(search)
        || data.companyCode.toLowerCase().includes(search)
        || this.featureKeyLabel(data.key).toLowerCase().includes(search)
        || (data.lastModifiedBy ?? '').toLowerCase().includes(search)
        || (data.lastModifiedAt ?? '').toString().toLowerCase().includes(search))
      ?? false
    );
  }
}
