import {Component, effect, inject, viewChild} from '@angular/core';
import {
  SbbCell,
  SbbCellDef,
  SbbColumnDef,
  SbbHeaderCell,
  SbbHeaderCellDef,
  SbbHeaderRow,
  SbbHeaderRowDef,
  SbbRow,
  SbbRowDef,
  SbbSort,
  SbbSortHeader,
  SbbTable,
  SbbTableDataSource,
  SbbTableWrapper
} from "@sbb-esta/lyne-angular/table";
import {SbbIcon} from "@sbb-esta/lyne-angular/icon";
import {SbbSecondaryButton} from "@sbb-esta/lyne-angular/button/secondary-button";
import {AppVersion} from '../../das-admin-api';
import {toObservable} from '@angular/core/rxjs-interop';
import {SbbCompactPaginator} from '@sbb-esta/lyne-angular/paginator/compact-paginator';
import {DatePipe} from '@angular/common';
import {SbbToggleCheck} from '@sbb-esta/lyne-angular/toggle-check';
import {AppVersionsService} from '../app-versions.service';

@Component({
  selector: 'app-app-versions-table',
  imports: [
    SbbCell,
    SbbCellDef,
    SbbColumnDef,
    SbbHeaderCell,
    SbbHeaderRow,
    SbbHeaderRowDef,
    SbbIcon,
    SbbRow,
    SbbRowDef,
    SbbSecondaryButton,
    SbbTable,
    SbbTableWrapper,
    SbbHeaderCellDef,
    SbbCompactPaginator,
    SbbSortHeader,
    DatePipe,
    SbbSort,
    SbbToggleCheck
  ],
  templateUrl: './app-versions-table.html',
  styleUrl: './app-versions-table.css',
})
export class AppVersionsTable {

  protected dataSource = new SbbTableDataSource<AppVersion>();
  protected columns = ['version', 'minimalVersion', 'expiryDate', 'action'];

  private readonly paginator = viewChild.required<SbbCompactPaginator>(SbbCompactPaginator);
  private readonly sort = viewChild.required<SbbSort>(SbbSort);

  protected readonly PAGE_SIZE = 20;
  private readonly appVersionsService = inject(AppVersionsService);

  constructor() {
    effect(() => {
      if (this.appVersionsService.appVersionsResource.hasValue()) {
        this.dataSource.data = this.appVersionsService.appVersionsResource.value().data;
      }
    });
    toObservable(this.paginator).subscribe((paginator) => (this.dataSource.paginator = paginator));
    toObservable(this.sort).subscribe((sort) => (this.dataSource.sort = sort));
  }

  protected async edit(appVersion: AppVersion) {
    await this.appVersionsService.edit(appVersion);
  }

  protected async add() {
    await this.appVersionsService.add();
  }
}
