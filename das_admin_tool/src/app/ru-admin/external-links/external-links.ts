import { Component, inject } from '@angular/core';
import { SbbSecondaryButton } from '@sbb-esta/lyne-angular/button';
import { SbbLoadingIndicatorCircle } from '@sbb-esta/lyne-angular/loading-indicator-circle';
import { SbbTitle } from '@sbb-esta/lyne-angular/title';
import { ExternalLinkService } from './external-link.service';
import { ExternalLinksTable } from './external-links-table/external-links-table';

@Component({
  selector: 'app-external-links',
  imports: [SbbTitle, SbbSecondaryButton, ExternalLinksTable, SbbLoadingIndicatorCircle],
  templateUrl: './external-links.html',
  styleUrl: './external-links.css',
})
export class ExternalLinks {
  protected readonly externalLinkService = inject(ExternalLinkService);
}
