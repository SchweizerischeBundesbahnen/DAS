import {Component, inject} from '@angular/core';
import {SbbTitle} from '@sbb-esta/lyne-angular/title';
import {SbbSecondaryButton} from '@sbb-esta/lyne-angular/button/secondary-button';
import {AppVersionsTable} from './app-versions-table/app-versions-table';
import {AppVersionsService} from './app-versions.service';
import {SbbLoadingIndicatorCircle} from '@sbb-esta/lyne-angular/loading-indicator-circle';


@Component({
  selector: 'app-app-versions',
  imports: [
    SbbTitle,
    SbbSecondaryButton,
    AppVersionsTable,
    SbbLoadingIndicatorCircle,
  ],
  templateUrl: './app-versions.html',
  styleUrl: './app-versions.css',
})
export class AppVersions {
  protected readonly appVersionsService = inject(AppVersionsService);
  protected readonly appVersions = this.appVersionsService.appVersionsResource;
}
