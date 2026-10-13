import { DatePipe } from '@angular/common';
import { afterNextRender, Component, effect, inject, viewChild } from '@angular/core';
import { SbbMiniButton } from '@sbb-esta/lyne-angular/button';
import { SbbSort, SbbTableDataSource, SbbTableModule } from '@sbb-esta/lyne-angular/table';
import { SbbToggleCheckModule } from '@sbb-esta/lyne-angular/toggle-check';
import { AppVersion } from '~app/das-admin/das-admin.api';
import { TableBottomBar } from '~shared/components/table-bottom-bar/table-bottom-bar';
import { AppVersionService } from '../app-version.service';

@Component({
  selector: 'app-app-versions-table',
  imports: [SbbTableModule, DatePipe, SbbToggleCheckModule, SbbMiniButton, TableBottomBar],
  templateUrl: './app-versions-table.html',
  styleUrl: './app-versions-table.css',
})
export class AppVersionsTable {
  private readonly appVersionService = inject(AppVersionService);

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
  }

  protected async edit(appVersion: AppVersion) {
    await this.appVersionService.edit(appVersion);
  }

  protected async add() {
    await this.appVersionService.add();
  }
}
