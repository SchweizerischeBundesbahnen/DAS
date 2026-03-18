import {Component} from '@angular/core';
import {SbbTitle} from '@sbb-esta/lyne-angular/title';
import {SbbTab, SbbTabGroup, SbbTabLabel} from '@sbb-esta/lyne-angular/tabs';
import {AppVersions} from './app-versions/app-versions';


@Component({
  selector: 'app-das-admin',
  imports: [
    SbbTitle,
    SbbTab,
    SbbTabLabel,
    SbbTabGroup,
    AppVersions
  ],
  templateUrl: './das-admin.html',
  styleUrl: './das-admin.css',
})
export class DasAdmin {
}
