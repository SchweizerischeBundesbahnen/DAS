import { Component, inject } from '@angular/core';
import { SbbSecondaryButton } from '@sbb-esta/lyne-angular/button/secondary-button';
import { SbbLoadingIndicatorCircle } from '@sbb-esta/lyne-angular/loading-indicator-circle';
import { SbbTitle } from '@sbb-esta/lyne-angular/title';
import { RuIndicationTemplateService } from './ru-indication-template.service';
import { RuIndicationTemplatesTable } from './ru-indication-templates-table/ru-indication-templates-table';

@Component({
  selector: 'app-ru-indication-templates',
  imports: [RuIndicationTemplatesTable, SbbLoadingIndicatorCircle, SbbSecondaryButton, SbbTitle],
  templateUrl: './ru-indication-templates.html',
  styleUrl: './ru-indication-templates.css',
})
export class RuIndicationTemplates {
  protected readonly ruIndicationTemplatesService = inject(RuIndicationTemplateService);
  protected readonly ruIndicationTemplates =
    this.ruIndicationTemplatesService.ruIndicationTemplatesResource;
}
