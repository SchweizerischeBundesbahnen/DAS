import { Component, inject } from '@angular/core';
import { SbbLoadingIndicatorCircleModule } from '@sbb-esta/lyne-angular/loading-indicator-circle';
import { PageHeader } from '~shared/components/page-header/page-header';
import { AppVersionService } from './app-version.service';
import { AppVersionsTable } from './app-versions-table/app-versions-table';

@Component({
  selector: 'app-versions',
  imports: [PageHeader, AppVersionsTable, SbbLoadingIndicatorCircleModule],
  templateUrl: './app-versions.html',
  styleUrl: './app-versions.css',
})
export class AppVersions {
  protected readonly appVersionService = inject(AppVersionService);

  protected readonly title = $localize`:@@app_versions_title:Blockierte App Versionen`;
  protected readonly appVersions = this.appVersionService.appVersionsResource;
}
