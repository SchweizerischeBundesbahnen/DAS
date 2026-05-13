import {Component, inject} from '@angular/core';
import {NoticeTemplatesTable} from './notice-templates-table/notice-templates-table';
import {SbbLoadingIndicatorCircle} from '@sbb-esta/lyne-angular/loading-indicator-circle';
import {SbbSecondaryButton} from '@sbb-esta/lyne-angular/button/secondary-button';
import {SbbTitle} from '@sbb-esta/lyne-angular/title';
import {NoticeTemplateService} from './notice-template.service';

@Component({
  selector: 'app-notice-templates',
  imports: [
    NoticeTemplatesTable,
    SbbLoadingIndicatorCircle,
    SbbSecondaryButton,
    SbbTitle
  ],
  templateUrl: './notice-templates.html',
  styleUrl: './notice-templates.css',
})
export class NoticeTemplates {

  protected readonly noticeTemplatesService = inject(NoticeTemplateService);
  protected readonly noticeTemplates = this.noticeTemplatesService.noticeTemplatesResource;
}
