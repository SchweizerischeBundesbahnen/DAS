import {Component} from '@angular/core';
import {SbbTitleModule} from '@sbb-esta/lyne-angular/title';
import {SbbTabsModule} from '@sbb-esta/lyne-angular/tabs';
import {AppVersions} from './app-versions/app-versions';


@Component({
  selector: 'app-das-admin',
  imports: [
    SbbTitleModule,
    SbbTabsModule,
    AppVersions
  ],
  templateUrl: './das-admin.html',
  styleUrl: './das-admin.css',
})
export class DasAdmin {
}
