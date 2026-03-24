import {Component, inject} from '@angular/core';
import {OidcSecurityService} from 'angular-auth-oidc-client';
import {SbbIconSidebarModule} from '@sbb-esta/lyne-angular/icon-sidebar';
import {SbbTooltipModule} from '@sbb-esta/lyne-angular/tooltip';

@Component({
  selector: 'app-icon-sidebar',
  imports: [
    SbbIconSidebarModule,
    SbbTooltipModule
  ],
  templateUrl: './icon-sidebar.html',
  styleUrl: './icon-sidebar.css',
})
export class IconSidebar {
  protected oidcSecurityService = inject(OidcSecurityService);
}
