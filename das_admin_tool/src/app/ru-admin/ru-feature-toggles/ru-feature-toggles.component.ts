import {Component, inject} from '@angular/core';
import {SbbLoadingIndicatorCircle} from '@sbb-esta/lyne-angular/loading-indicator-circle';
import {SbbSecondaryButton} from '@sbb-esta/lyne-angular/button/secondary-button';
import {SbbTitle} from '@sbb-esta/lyne-angular/title';
import {RuFeatureTogglesTable} from './ru-feature-toggles-table/ru-feature-toggles-table.component';
import {RuFeatureService} from './ru-feature.service';

@Component({
  selector: 'app-ru-feature-toggles',
  imports: [
    RuFeatureTogglesTable,
    SbbLoadingIndicatorCircle,
    SbbSecondaryButton,
    SbbTitle
  ],
  templateUrl: './ru-feature-toggles.component.html',
  styleUrl: './ru-feature-toggles.component.css',
})
export class RuFeatureToggles {
  protected readonly ruFeatureService = inject(RuFeatureService);
  protected readonly ruFeatures = this.ruFeatureService.ruFeaturesResource;
}
