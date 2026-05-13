import {Component} from '@angular/core';
import {SbbTitleModule} from '@sbb-esta/lyne-angular/title';
import {SbbTabsModule} from '@sbb-esta/lyne-angular/tabs';
import {NoticeTemplates} from './notice-templates/notice-templates';

@Component({
  selector: 'app-ru-admin',
  imports: [
    SbbTitleModule,
    SbbTabsModule,
    NoticeTemplates
  ],
  templateUrl: './ru-admin.html',
  styleUrl: './ru-admin.css',
})
export class RuAdmin {
}
