import { Component } from '@angular/core';
import { SbbHeaderLeanModule, } from "@sbb-esta/angular/header-lean";
import { SbbIconModule } from "@sbb-esta/angular/icon";
import { SbbUsermenuModule } from "@sbb-esta/angular/usermenu";
import { SbbSidebarModule } from "@sbb-esta/angular/sidebar";
import { SbbMenuModule } from "@sbb-esta/angular/menu";
import { SbbButtonModule } from "@sbb-esta/angular/button";
import { Router, RouterModule } from "@angular/router";
import { environment } from "../environments/environment";
import packageJson from '../../package.json';
import { OidcSecurityService } from "angular-auth-oidc-client";

@Component({
  selector: 'app-root',
  standalone: true,
  imports: [
    RouterModule,
    SbbButtonModule,
    SbbHeaderLeanModule,
    SbbIconModule,
    SbbMenuModule,
    SbbSidebarModule,
    SbbUsermenuModule,
  ],
  templateUrl: './app.component.html',
  styleUrl: './app.component.scss',
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
