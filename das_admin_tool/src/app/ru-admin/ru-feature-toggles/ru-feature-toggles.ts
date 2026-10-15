import { Component, inject } from '@angular/core';
import { SbbButtonModule } from '@sbb-esta/lyne-angular/button';
import { SbbLoadingIndicatorCircleModule } from '@sbb-esta/lyne-angular/loading-indicator-circle';
import { SbbTitleModule } from '@sbb-esta/lyne-angular/title';
import { RuFeatureToggleService } from './ru-feature-toggle.service';
import { RuFeatureTogglesTable } from './ru-feature-toggles-table/ru-feature-toggles-table';

@Component({
  selector: 'app-ru-feature-toggles',
  imports: [
    RuFeatureTogglesTable,
    SbbLoadingIndicatorCircleModule,
    SbbButtonModule,
    SbbTitleModule,
  ],
  templateUrl: './ru-feature-toggles.html',
  styleUrl: './ru-feature-toggles.css',
})
export class RuFeatureToggles {
  protected readonly ruFeatureToggleService = inject(RuFeatureToggleService);
  protected readonly ruFeatures = this.ruFeatureToggleService.ruFeaturesResource;
}
