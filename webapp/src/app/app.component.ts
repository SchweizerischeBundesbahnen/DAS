import { Component, CUSTOM_ELEMENTS_SCHEMA, signal, Signal } from '@angular/core';
import { Router, RouterModule } from "@angular/router";
import { environment } from "../environment/environment";
import packageJson from '../../package.json';
import { AuthService, Tenant } from "./auth.service";
import { OidcSecurityService } from "angular-auth-oidc-client";
import { toSignal } from "@angular/core/rxjs-interop";
import '@sbb-esta/lyne-elements/menu.js';
import '@sbb-esta/lyne-elements/navigation.js';
import '@sbb-esta/lyne-elements/header.js';
import '@sbb-esta/lyne-elements/link.js';

@Component({
  selector: 'app-root',
  standalone: true,
  imports: [
    RouterModule,
  ],
  schemas: [CUSTOM_ELEMENTS_SCHEMA],
  templateUrl: './app.component.html',
  styleUrl: './app.component.scss',
})
export class AppComponent {
  version = packageJson.version;
  environmentLabel = environment.label;
  title = 'DAS playground';

  readonly userData = this.oidcSecurityService.userData;
  readonly organisation: Signal<Tenant | undefined> = signal(undefined);

  constructor(
    private oidcSecurityService: OidcSecurityService,
    private authService: AuthService,
    private router: Router,
  ) {
    if (this.userData().userData) {
      this.organisation = toSignal(this.authService.tenant());
    }
  }

  login() {
    this.oidcSecurityService.authorize();
  }

  logout() {
    this.oidcSecurityService.logoffLocalMultiple();
    return this.router.navigate(['/unauthorized']);
  }
}
