import { Component, inject } from '@angular/core';
import { SbbSecondaryButton } from '@sbb-esta/lyne-angular/button/secondary-button';
import { SbbLoadingIndicatorCircle } from '@sbb-esta/lyne-angular/loading-indicator-circle';
import { SbbTitle } from '@sbb-esta/lyne-angular/title';
import { ExternalLinksTable } from './external-links-table/external-links-table';
import { ExternalLinksService } from './external-links.service';

@Component({
  selector: 'app-external-links',
  imports: [SbbTitle, SbbSecondaryButton, ExternalLinksTable, SbbLoadingIndicatorCircle],
  templateUrl: './external-links.html',
  styleUrl: './external-links.css',
})
export class ExternalLinks {
  protected readonly externalLinksService = inject(ExternalLinksService);
}
