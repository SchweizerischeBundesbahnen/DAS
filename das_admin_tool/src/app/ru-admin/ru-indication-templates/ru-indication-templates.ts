import { Component, inject } from '@angular/core';
import { SbbLoadingIndicatorCircle } from '@sbb-esta/lyne-angular/loading-indicator-circle';
import { PageHeader } from '~shared/components/page-header/page-header';
import { RuIndicationTemplateService } from './ru-indication-template.service';
import { RuIndicationTemplatesTable } from './ru-indication-templates-table/ru-indication-templates-table';

@Component({
  selector: 'app-ru-indication-templates',
  imports: [PageHeader, RuIndicationTemplatesTable, SbbLoadingIndicatorCircle],
  templateUrl: './ru-indication-templates.html',
  styleUrl: './ru-indication-templates.css',
})
export class RuIndicationTemplates {
  protected readonly ruIndicationTemplatesService = inject(RuIndicationTemplateService);

  protected readonly title = $localize`:@@ru_indication_templates_title:Titel und Texte`;
  protected readonly ruIndicationTemplates =
    this.ruIndicationTemplatesService.ruIndicationTemplatesResource;
}
