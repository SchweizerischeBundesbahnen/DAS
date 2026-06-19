import { Component, effect, inject, viewChild } from '@angular/core';
import { SbbSort, SbbTableDataSource, SbbTableModule } from '@sbb-esta/lyne-angular/table';
import { AppVersion } from '../../das-admin-api';
import { DatePipe } from '@angular/common';
import { SbbToggleCheckModule } from '@sbb-esta/lyne-angular/toggle-check';
import { AppVersionsService } from '../app-versions.service';
import { SbbMiniButton } from '@sbb-esta/lyne-angular/button/mini-button';
import { TableBottomBar } from '../../../shared/table-bottom-bar/table-bottom-bar';

@Component({
  selector: 'app-app-versions-table',
  imports: [SbbTableModule, DatePipe, SbbToggleCheckModule, SbbMiniButton, TableBottomBar],
  templateUrl: './app-versions-table.html',
  styleUrl: './app-versions-table.css',
})
export class AppVersionsTable {
  protected readonly addLabel = $localize`:@@app_versions_button_create:App Version blockieren`;

  protected dataSource = new SbbTableDataSource<AppVersion>();
  protected columns = [
    'version',
    'minimalVersion',
    'expiryDate',
    'lastModifiedAt',
    'lastModifiedBy',
    'action',
  ];
  private readonly appVersionsService = inject(AppVersionsService);

  private readonly bottomBar = viewChild.required(TableBottomBar);
  private readonly sort = viewChild.required<SbbSort>(SbbSort);

  constructor() {
    effect(() => {
      if (this.appVersionsService.appVersionsResource.hasValue()) {
        this.dataSource.data = this.appVersionsService.appVersionsResource.value().data;
      }
      this.dataSource.paginator = this.bottomBar().paginator();
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
