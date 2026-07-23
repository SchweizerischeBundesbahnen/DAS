import { Component, computed, inject } from '@angular/core';
import { RouterLink, RouterLinkActive, RouterOutlet } from '@angular/router';
import { SbbLoadingIndicatorCircleModule } from '@sbb-esta/lyne-angular/loading-indicator-circle';
import { SbbTabsModule } from '@sbb-esta/lyne-angular/tabs';
import { SbbTitleModule } from '@sbb-esta/lyne-angular/title';
import { CompanyService } from '~shared/companies-input/company.service';
import { LocationService } from './ru-indications/ru-indication-dialog/locations-input/location.service';

@Component({
  selector: 'app-ru-admin',
  imports: [
    SbbTitleModule,
    SbbTabsModule,
    SbbLoadingIndicatorCircleModule,
    RouterOutlet,
    RouterLink,
    RouterLinkActive,
  ],
  templateUrl: './ru-admin.html',
  styleUrl: './ru-admin.css',
})
export class RuAdmin {
  private readonly companyService = inject(CompanyService);
  private readonly locationService = inject(LocationService);

  protected readonly referenceDataReady = computed(
    () => this.companyService.loaded() && this.locationService.loaded(),
  );
}
