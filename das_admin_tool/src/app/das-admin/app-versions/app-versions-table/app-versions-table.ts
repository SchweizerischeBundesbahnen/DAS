import {Component, effect, inject, viewChild} from '@angular/core';
import {SbbSort, SbbTableDataSource, SbbTableModule} from "@sbb-esta/lyne-angular/table";
import {SbbSecondaryButton} from "@sbb-esta/lyne-angular/button/secondary-button";
import {AppVersion} from '../../das-admin-api';
import {SbbCompactPaginator} from '@sbb-esta/lyne-angular/paginator/compact-paginator';
import {DatePipe} from '@angular/common';
import {SbbToggleCheckModule} from '@sbb-esta/lyne-angular/toggle-check';
import {AppVersionsService} from '../app-versions.service';
import {SbbMiniButton} from '@sbb-esta/lyne-angular/button/mini-button';

@Component({
  selector: 'app-app-versions-table',
  imports: [
    SbbTableModule,
    SbbSecondaryButton,
    SbbCompactPaginator,
    DatePipe,
    SbbToggleCheckModule,
    SbbMiniButton
  ],
  templateUrl: './app-versions-table.html',
  styleUrl: './app-versions-table.css',
})
export class AppVersionsTable {
  protected readonly PAGE_SIZE = 20;

  protected dataSource = new SbbTableDataSource<AppVersion>();
  protected columns = ['version', 'minimalVersion', 'expiryDate', 'action'];
  private readonly appVersionsService = inject(AppVersionsService);

  private readonly paginator = viewChild.required<SbbCompactPaginator>(SbbCompactPaginator);
  private readonly sort = viewChild.required<SbbSort>(SbbSort);

  constructor() {
    effect(() => {
      if (this.appVersionsService.appVersionsResource.hasValue()) {
        this.dataSource.data = this.appVersionsService.appVersionsResource.value().data;
      }
      this.dataSource.paginator = this.paginator();
      this.dataSource.sort = this.sort();
    });
  }

  protected async edit(appVersion: AppVersion) {
    await this.appVersionsService.edit(appVersion);
  }

  protected async add() {
    await this.appVersionsService.add();
  }
}
