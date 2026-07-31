import { Component, inject } from '@angular/core';
import { SbbButtonModule } from '@sbb-esta/lyne-angular/button';
import { SbbLoadingIndicatorCircleModule } from '@sbb-esta/lyne-angular/loading-indicator-circle';
import { SbbTitleModule } from '@sbb-esta/lyne-angular/title';
import { RuFeatureTogglesTable } from './ru-feature-toggles-table/ru-feature-toggles-table.component';
import { RuFeatureService } from './ru-feature.service';

@Component({
  selector: 'app-ru-feature-toggles',
  imports: [
    RuFeatureTogglesTable,
    SbbLoadingIndicatorCircleModule,
    SbbButtonModule,
    SbbTitleModule,
  ],
  templateUrl: './ru-feature-toggles.component.html',
  styleUrl: './ru-feature-toggles.component.css',
})
export class RuFeatureToggles {
  protected readonly ruFeatureService = inject(RuFeatureService);
  protected readonly ruFeatures = this.ruFeatureService.ruFeaturesResource;
}
