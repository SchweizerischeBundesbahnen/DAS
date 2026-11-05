import { DatePipe } from '@angular/common';
import {
  afterNextRender,
  Component,
  effect,
  inject,
  input,
  signal,
  viewChild,
} from '@angular/core';
import { form } from '@angular/forms/signals';
import { SbbMiniButton } from '@sbb-esta/lyne-angular/button';
import {
  SbbSort,
  SbbTableDataSource,
  SbbTableFilter,
  SbbTableModule,
} from '@sbb-esta/lyne-angular/table';
import { SbbToggleCheckModule } from '@sbb-esta/lyne-angular/toggle-check';
import { AppVersion } from '~app/das-admin/das-admin.api';
import { PageHeader } from '~shared/components/page-header/page-header';
import { TableBottomBar } from '~shared/components/table-bottom-bar/table-bottom-bar';
import { TableSearchHeader } from '~shared/components/table-search-header/table-search-header';
import { AppVersionService } from '../app-version.service';

interface AppVersionFilter extends SbbTableFilter {
  search: string;
}

@Component({
  selector: 'app-versions-table',
  imports: [
    SbbTableModule,
    DatePipe,
    SbbToggleCheckModule,
    SbbMiniButton,
    PageHeader,
    TableBottomBar,
    TableSearchHeader,
  ],
  templateUrl: './app-versions-table.html',
  styleUrl: './app-versions-table.css',
})
export class AppVersionsTable {
  private readonly appVersionService = inject(AppVersionService);

  readonly title = input.required<string>();

  protected dataSource = new SbbTableDataSource<AppVersion, AppVersionFilter>();
  protected columns = [
    'version',
    'minimalVersion',
    'expiryDate',
    'lastModifiedAt',
    'lastModifiedBy',
    'action',
  ];

  protected readonly filterModel = signal({ search: '' });
  protected readonly filterForm = form(this.filterModel);

  private readonly bottomBar = viewChild.required(TableBottomBar);
  private readonly sort = viewChild.required<SbbSort>(SbbSort);

  constructor() {
    effect(() => {
      if (this.appVersionService.appVersionsResource.hasValue()) {
        this.dataSource.data = this.appVersionService.appVersionsResource.value().data;
      }
    });
    afterNextRender(() => {
      this.dataSource.paginator = this.bottomBar().paginator();
      this.dataSource.sort = this.sort();
    });
    this.dataSource.filterPredicate = (data: AppVersion, filter: AppVersionFilter) =>
      this.searchFilter(filter, data);
    effect(() => {
      this.dataSource.filter = this.filterModel();
    });
  }

  protected async edit(appVersion: AppVersion) {
    await this.appVersionService.edit(appVersion);
  }

  protected async add() {
    await this.appVersionService.add();
  }

  private searchFilter(filter: AppVersionFilter, data: AppVersion): boolean {
    const search = filter.search.toLowerCase();
    if (!search) return true;
    return (
      data.version.toLowerCase().includes(search)
      || (data.expiryDate ?? '').toLowerCase().includes(search)
      || (data.lastModifiedBy ?? '').toLowerCase().includes(search)
      || (data.lastModifiedAt ?? '').toString().toLowerCase().includes(search)
    );
  }
}
