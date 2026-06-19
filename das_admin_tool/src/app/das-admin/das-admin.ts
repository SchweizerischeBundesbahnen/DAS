import { Component } from '@angular/core';
import { SbbTabsModule } from '@sbb-esta/lyne-angular/tabs';
import { SbbTitleModule } from '@sbb-esta/lyne-angular/title';
import { AppVersions } from './app-versions/app-versions';

@Component({
  selector: 'app-das-admin',
  imports: [SbbTitleModule, SbbTabsModule, AppVersions],
  templateUrl: './das-admin.html',
  styleUrl: './das-admin.css',
})
export class DasAdmin {}
