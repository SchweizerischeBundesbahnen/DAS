import 'angular-server-side-configuration/process';
import { APP_INITIALIZER, ApplicationConfig, importProvidersFrom } from '@angular/core';
import { provideRouter } from '@angular/router';
import { routes } from './app.routes';
import { MqttModule } from "ngx-mqtt";
import { provideHttpClient, withInterceptors, withInterceptorsFromDi } from "@angular/common/http";
import { provideAnimationsAsync } from '@angular/platform-browser/animations/async';
import { authInterceptor, OidcSecurityService, provideAuth } from 'angular-auth-oidc-client';
import { environment } from "../environments/environment";
import { SbbNotificationToastModule } from "@sbb-esta/angular/notification-toast";

function appInitializerAuthCheck() {
  return {
    provide: APP_INITIALIZER,
    useFactory: (oidcSecurityService: OidcSecurityService) => () =>
      oidcSecurityService.checkAuthMultiple(),
    multi: true,
    deps: [OidcSecurityService],
  };
}

/**
 * How to use angular-server-side-configuration:
 *
 * Use process.env['NAME_OF_YOUR_ENVIRONMENT_VARIABLE']
 *
 * const stringValue = process.env['STRING_VALUE'];
 * const stringValueWithDefault = process.env['STRING_VALUE'] || 'defaultValue';
 * const numberValue = Number(process.env['NUMBER_VALUE']);
 * const numberValueWithDefault = Number(process.env['NUMBER_VALUE'] || 10);
 * const booleanValue = process.env['BOOLEAN_VALUE'] === 'true';
 * const booleanValueInverted = process.env['BOOLEAN_VALUE_INVERTED'] !== 'false';
 * const complexValue = JSON.parse(process.env['COMPLEX_JSON_VALUE]);
 *
 * Please note that process.env[variable] cannot be resolved. Please directly use strings.
 */
export const appConfig: ApplicationConfig = {
  providers: [
    provideRouter(routes),
    provideAnimationsAsync(),
    provideAuth(environment.authConfig),
    appInitializerAuthCheck(),
    provideHttpClient(withInterceptorsFromDi(), withInterceptors([authInterceptor()])),
    importProvidersFrom(MqttModule.forRoot(environment.mqttServiceOptions)),
    importProvidersFrom(SbbNotificationToastModule)
  ],

};
