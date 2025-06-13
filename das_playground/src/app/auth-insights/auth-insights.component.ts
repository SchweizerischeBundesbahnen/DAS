import { Component, inject } from '@angular/core';
import { CommonModule } from "@angular/common";
import { map } from "rxjs";
import { OidcSecurityService } from "angular-auth-oidc-client";

@Component({
  selector: 'app-auth-insights',
  imports: [
    CommonModule,
  ],
  templateUrl: './auth-insights.component.html',
  styleUrl: './auth-insights.component.scss'
})
export class AuthInsightsComponent {
  private oidcSecurityService = inject(OidcSecurityService);


  get claims() {
    return this.oidcSecurityService.getUserData();
  }

  get scopes() {
    return this.oidcSecurityService.getAuthenticationResult().pipe(map((data) => data?.scope));
  }
}
