import { Component, inject } from '@angular/core';
import { SbbLoadingIndicatorCircle } from '@sbb-esta/lyne-angular/loading-indicator-circle';
import { PageHeader } from '~shared/components/page-header/page-header';
import { ExternalLinkService } from './external-link.service';
import { ExternalLinksTable } from './external-links-table/external-links-table';

@Component({
  selector: 'app-external-links',
  imports: [PageHeader, ExternalLinksTable, SbbLoadingIndicatorCircle],
  templateUrl: './external-links.html',
  styleUrl: './external-links.css',
})
export class ExternalLinks {
  protected readonly externalLinkService = inject(ExternalLinkService);

  protected readonly title = $localize`:@@external_links_title:Externe Absprünge`;
}
