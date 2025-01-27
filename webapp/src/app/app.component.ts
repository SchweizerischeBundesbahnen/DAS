import { Component, CUSTOM_ELEMENTS_SCHEMA, signal, Signal } from '@angular/core';
import { Router, RouterModule } from "@angular/router";
import { environment } from "../environment/environment";
import packageJson from '../../package.json';
import { OidcSecurityService } from "angular-auth-oidc-client";
import { SbbMenuDirective } from "@sbb-esta/lyne-angular/menu/menu";
import { SbbNavigationDirective } from "@sbb-esta/lyne-angular/navigation/navigation";
import { SbbHeaderDirective } from "@sbb-esta/lyne-angular/header/header";
import { SbbLinkDirective } from "@sbb-esta/lyne-angular/link/link";
import { SbbMenuButtonDirective } from "@sbb-esta/lyne-angular/menu/menu-button";
import { SbbHeaderButtonDirective } from "@sbb-esta/lyne-angular/header/header-button";
import { SbbMenuLinkDirective } from "@sbb-esta/lyne-angular/menu/menu-link";
import { SbbNavigationMarkerDirective } from "@sbb-esta/lyne-angular/navigation/navigation-marker";
import { SbbHeaderLinkDirective } from "@sbb-esta/lyne-angular/header/header-link";

@Component({
    selector: 'app-root',
    imports: [
        RouterModule,
      SbbMenuDirective,
      SbbNavigationDirective,
      SbbHeaderDirective,
      SbbMenuButtonDirective,
      SbbHeaderButtonDirective,
      SbbMenuLinkDirective,
      SbbNavigationMarkerDirective,
      SbbHeaderLinkDirective

    ],
    templateUrl: './app.component.html',
    styleUrl: './app.component.scss'
})
export class AppComponent {
  version = packageJson.version;
  environmentLabel = environment.label;
  title = 'DAS playground';

  readonly userData = this.oidcSecurityService.userData;

  constructor(
    private oidcSecurityService: OidcSecurityService,
    private router: Router,
  ) {
  }

  login() {
    this.oidcSecurityService.authorize();
  }

  logout() {
    this.oidcSecurityService.logoffLocalMultiple();
    return this.router.navigate(['/unauthorized']);
  }
}
