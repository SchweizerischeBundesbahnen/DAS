import {Component, effect, inject, viewChild} from '@angular/core';
import {
  SbbSort,
  SbbTableDataSource,
  SbbTableFilter,
  SbbTableModule
} from '@sbb-esta/lyne-angular/table';
import {SbbMiniButton} from '@sbb-esta/lyne-angular/button/mini-button';
import {SbbToggleCheckModule} from '@sbb-esta/lyne-angular/toggle-check';
import {RU_FEATURE_KEY_LABELS, RuFeature, RuFeatureKey} from '../../ru-admin-api';
import {RuFeatureService} from '../ru-feature.service';
import {DatePipe} from '@angular/common';
import {CompanyService} from '../../../shared/companies-input/company.service';
import {TableBottomBar} from '../../../shared/table-bottom-bar/table-bottom-bar';
import {TableSearchHeader} from '../../../shared/table-search-header/table-search-header';
import {FormControl} from '@angular/forms';
import {takeUntilDestroyed} from '@angular/core/rxjs-interop';
import {startWith} from 'rxjs';

interface RuFeatureFilter extends SbbTableFilter {
  search: string;
}

@Component({
  selector: 'app-ru-feature-toggles-table',
  imports: [
    SbbTableModule,
    SbbMiniButton,
    SbbToggleCheckModule,
    DatePipe,
    TableBottomBar,
    TableSearchHeader,
  ],
  templateUrl: './ru-feature-toggles-table.component.html',
  styleUrl: './ru-feature-toggles-table.component.css',
})
export class RuFeatureTogglesTable {
  protected dataSource = new SbbTableDataSource<RuFeature, RuFeatureFilter>();
  protected columns = ['companyCode', 'key', 'enabled', 'lastModifiedAt', 'lastModifiedBy', 'action'];
  protected readonly searchControl = new FormControl('', {nonNullable: true});

  private readonly ruFeatureService = inject(RuFeatureService);
  private readonly companyService = inject(CompanyService);

  private readonly bottomBar = viewChild.required(TableBottomBar);
  private readonly sort = viewChild.required<SbbSort>(SbbSort);

  constructor() {
    effect(() => {
      if (this.ruFeatureService.ruFeaturesResource.hasValue()) {
        this.dataSource.data = this.ruFeatureService.ruFeaturesResource.value().data;
      }
      this.dataSource.paginator = this.bottomBar().paginator();
      this.dataSource.sort = this.sort();
    });
    this.dataSource.filterPredicate = (data: RuFeature, filter: RuFeatureFilter) => this.searchFilter(filter, data);
    this.searchControl.valueChanges
      .pipe(startWith(this.searchControl.value), takeUntilDestroyed())
      .subscribe((search) => {
        this.dataSource.filter = {search} as RuFeatureFilter;
      });
  }

  protected async edit(ruFeature: RuFeature): Promise<void> {
    await this.ruFeatureService.edit(ruFeature);
  }

  protected async add(): Promise<void> {
    await this.ruFeatureService.add();
  }

  protected companyName(companyCode: string): string {
    return this.companyService.getName(companyCode) ?? companyCode;
  }

  protected featureKeyLabel(key: RuFeatureKey): string {
    return RU_FEATURE_KEY_LABELS.find((label) => label.value === key)?.label ?? key;
  }

  private searchFilter(filter: RuFeatureFilter, data: RuFeature): boolean {
    const search = filter.search.toLowerCase();
    if (!search) return true;
    return (
      this.companyName(data.companyCode).toLowerCase().includes(search) ||
      data.companyCode.toLowerCase().includes(search) ||
      this.featureKeyLabel(data.key).toLowerCase().includes(search) ||
      data.lastModifiedBy?.toLowerCase().includes(search) ||
      data.lastModifiedAt?.toString().toLowerCase().includes(search)
    ) ?? false;
  }
}
