import { Component, CUSTOM_ELEMENTS_SCHEMA } from '@angular/core';
import { AuthService } from "../auth.service";
import { CommonModule } from "@angular/common";
import { FormControl, ReactiveFormsModule } from "@angular/forms";
import { firstValueFrom, map } from "rxjs";
import { OidcSecurityService } from "angular-auth-oidc-client";
import { SbbFormFieldDirective } from "@sbb-esta/lyne-angular/form-field/form-field";

@Component({
    selector: 'app-auth-insights',
    imports: [
        CommonModule,
        ReactiveFormsModule,
      SbbFormFieldDirective
    ],
    templateUrl: './auth-insights.component.html',
    styleUrl: './auth-insights.component.scss'
})
export class AuthInsightsComponent {

  ruControl = new FormControl('1088', {nonNullable: true});
  trainControl = new FormControl(new Date().toISOString().split('T')[0] + '_9232', {nonNullable: true});
  roleControl = new FormControl('read-only', {nonNullable: true});

  exchangeClaims?: string;

  get claims() {
    return this.oidcSecurityService.getUserData();
  }

  get scopes() {
    return this.oidcSecurityService.getAuthenticationResult().pipe(map((data) => data?.scope));
  }

  constructor(private oidcSecurityService: OidcSecurityService, private authService: AuthService) {
  }

  async exchange() {
    const token = await firstValueFrom(this.authService.exchange(this.ruControl.value, this.trainControl.value, this.roleControl.value))
    this.exchangeClaims = JSON.parse(atob(token.split('.')[1]));
  }
}
