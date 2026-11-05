import { Component, inject } from '@angular/core';
import { SbbLoadingIndicatorCircleModule } from '@sbb-esta/lyne-angular/loading-indicator-circle';
import { PageHeader } from '~shared/components/page-header/page-header';
import { RuIndicationService } from './ru-indication.service';
import { RuIndicationsTable } from './ru-indications-table/ru-indications-table';

@Component({
  selector: 'app-ru-indications',
  imports: [PageHeader, SbbLoadingIndicatorCircleModule, RuIndicationsTable],
  templateUrl: './ru-indications.html',
  styleUrl: './ru-indications.css',
})
export class RuIndications {
  protected readonly ruIndicationService = inject(RuIndicationService);

  protected readonly title = $localize`:@@ru_indications_title:Hinweise`;
  protected readonly ruIndicationsResource = this.ruIndicationService.ruIndicationsResource;
}
