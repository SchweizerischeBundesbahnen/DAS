import { Component, inject } from '@angular/core';
import { SbbButtonModule } from '@sbb-esta/lyne-angular/button';
import { SbbLoadingIndicatorCircleModule } from '@sbb-esta/lyne-angular/loading-indicator-circle';
import { SbbTitleModule } from '@sbb-esta/lyne-angular/title';
import { RuIndicationService } from './ru-indication.service';
import { RuIndicationsTable } from './ru-indications-table/ru-indications-table';

@Component({
  selector: 'app-ru-indications',
  imports: [SbbTitleModule, SbbButtonModule, SbbLoadingIndicatorCircleModule, RuIndicationsTable],
  templateUrl: './ru-indications.html',
  styleUrl: './ru-indications.css',
})
export class RuIndications {
  protected readonly ruIndicationService = inject(RuIndicationService);
  protected readonly ruIndicationsResource = this.ruIndicationService.ruIndicationsResource;
}
