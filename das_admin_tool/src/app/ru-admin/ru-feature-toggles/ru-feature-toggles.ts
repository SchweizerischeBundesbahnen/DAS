import { Component, inject } from '@angular/core';
import { SbbLoadingIndicatorCircleModule } from '@sbb-esta/lyne-angular/loading-indicator-circle';
import { PageHeader } from '~shared/components/page-header/page-header';
import { RuFeatureToggleService } from './ru-feature-toggle.service';
import { RuFeatureTogglesTable } from './ru-feature-toggles-table/ru-feature-toggles-table';

@Component({
  selector: 'app-ru-feature-toggles',
  imports: [PageHeader, RuFeatureTogglesTable, SbbLoadingIndicatorCircleModule],
  templateUrl: './ru-feature-toggles.html',
  styleUrl: './ru-feature-toggles.css',
})
export class RuFeatureToggles {
  protected readonly ruFeatureToggleService = inject(RuFeatureToggleService);

  protected readonly title = $localize`:@@ru_feature_toggles_title:DAS Mobile Features`;
  protected readonly ruFeatures = this.ruFeatureToggleService.ruFeaturesResource;
}
