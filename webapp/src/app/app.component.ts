import { Component } from '@angular/core';
import { Router, RouterModule } from "@angular/router";
import { environment } from "../environment/environment";
import packageJson from '../../package.json';
import { OidcSecurityService } from "angular-auth-oidc-client";
import { SbbHeader } from "@sbb-esta/lyne-angular/header/header";
import { SbbMenuButton } from "@sbb-esta/lyne-angular/menu/menu-button";
import { SbbMenu } from "@sbb-esta/lyne-angular/menu/menu";
import { SbbHeaderButton } from "@sbb-esta/lyne-angular/header/header-button";
import { SbbMenuLink } from "@sbb-esta/lyne-angular/menu/menu-link";
import { SbbHeaderLink } from "@sbb-esta/lyne-angular/header/header-link";
import { SbbNavigationMarker } from "@sbb-esta/lyne-angular/navigation/navigation-marker";
import { SbbNavigation } from "@sbb-esta/lyne-angular/navigation/navigation";

@Component({
  selector: 'app-root',
  imports: [
    RouterModule,
    SbbHeader,
    SbbMenuButton,
    SbbMenu,
    SbbHeaderButton,
    SbbMenuLink,
    SbbHeaderLink,
    SbbNavigationMarker,
    SbbNavigation
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
