import { Component } from '@angular/core';
import { CommonModule } from "@angular/common";
import { SbbButtonModule } from "@sbb-esta/angular/button";
import { FormControl, ReactiveFormsModule } from "@angular/forms";
import { map } from "rxjs";
import { OidcSecurityService } from "angular-auth-oidc-client";
import { SbbInputModule } from "@sbb-esta/angular/input";

@Component({
  selector: 'app-auth-insights',
  standalone: true,
  imports: [
    CommonModule,
    ReactiveFormsModule,
    SbbButtonModule,
    SbbInputModule,
  ],
  templateUrl: './auth-insights.component.html',
  styleUrl: './auth-insights.component.scss'
})
export class AuthInsightsComponent {

  ruControl = new FormControl('1088', {nonNullable: true});
  trainControl = new FormControl(new Date().toISOString().split('T')[0] + '_9232', {nonNullable: true});
  roleControl = new FormControl('read-only', {nonNullable: true});

  get claims() {
    return this.oidcSecurityService.getUserData();
  }

  get scopes() {
    return this.oidcSecurityService.getAuthenticationResult().pipe(map((data) => data?.scope));
  }

  constructor(private oidcSecurityService: OidcSecurityService) {
  }
}
