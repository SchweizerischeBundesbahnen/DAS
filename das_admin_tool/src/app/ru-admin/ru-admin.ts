import {Component} from '@angular/core';
import {RouterLink, RouterLinkActive, RouterOutlet} from '@angular/router';
import {SbbTitleModule} from '@sbb-esta/lyne-angular/title';
import {CommonModule} from '@angular/common';
import {SbbTabsModule} from '@sbb-esta/lyne-angular/tabs';

@Component({
  selector: 'app-ru-admin',
  imports: [
    SbbTitleModule,
    SbbTabsModule,
    RouterOutlet,
    RouterLink,
    CommonModule,
    RouterLinkActive
  ],
  templateUrl: './ru-admin.html',
  styleUrl: './ru-admin.css',
})
export class RuAdmin {
}
