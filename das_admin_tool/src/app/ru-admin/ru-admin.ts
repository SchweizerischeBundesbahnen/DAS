import { Component, computed, inject } from '@angular/core';
import { RouterLink, RouterLinkActive, RouterOutlet } from '@angular/router';
import { SbbLoadingIndicatorCircleModule } from '@sbb-esta/lyne-angular/loading-indicator-circle';
import { SbbTabsModule } from '@sbb-esta/lyne-angular/tabs';
import { SbbTitleModule } from '@sbb-esta/lyne-angular/title';
import { CompanyApi } from '~shared/services/company.api';
import { LocationApi } from './location.api';

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
  private readonly companyApi = inject(CompanyApi);
  private readonly locationApi = inject(LocationApi);

  protected readonly referenceDataReady = computed(
    () => this.companyApi.loaded() && this.locationApi.loaded(),
  );
}
