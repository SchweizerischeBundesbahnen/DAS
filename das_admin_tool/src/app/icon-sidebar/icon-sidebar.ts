import {Component, inject} from '@angular/core';
import {SbbSidebarContainer, SbbSidebarContent} from '@sbb-esta/lyne-angular/sidebar';
import {SbbTooltipDirective} from '@sbb-esta/lyne-angular/tooltip';
import {
  SbbIconSidebar,
  SbbIconSidebarButton,
  SbbIconSidebarContainer,
  SbbIconSidebarContent,
  SbbIconSidebarLink
} from '@sbb-esta/lyne-angular/icon-sidebar';
import {OidcSecurityService} from 'angular-auth-oidc-client';

@Component({
  selector: 'app-icon-sidebar',
  imports: [
    SbbIconSidebarContainer,
    SbbIconSidebar,
    SbbIconSidebarLink,
    SbbIconSidebarContent,
    SbbSidebarContent,
    SbbSidebarContainer,
    SbbIconSidebarButton,
    SbbTooltipDirective,

  ],
  templateUrl: './icon-sidebar.html',
  styleUrl: './icon-sidebar.css',
})
export class IconSidebar {
  protected oidcSecurityService = inject(OidcSecurityService);
}
