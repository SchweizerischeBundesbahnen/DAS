import { Component, inject } from '@angular/core';
import { SbbSecondaryButton } from '@sbb-esta/lyne-angular/button';
import { SbbLoadingIndicatorCircleModule } from '@sbb-esta/lyne-angular/loading-indicator-circle';
import { SbbTitleModule } from '@sbb-esta/lyne-angular/title';
import { AppVersionService } from './app-version.service';
import { AppVersionsTable } from './app-versions-table/app-versions-table';

@Component({
  selector: 'app-app-versions',
  imports: [SbbTitleModule, SbbSecondaryButton, AppVersionsTable, SbbLoadingIndicatorCircleModule],
  templateUrl: './app-versions.html',
  styleUrl: './app-versions.css',
})
export class AppVersions {
  protected readonly appVersionService = inject(AppVersionService);
  protected readonly appVersions = this.appVersionService.appVersionsResource;
}
