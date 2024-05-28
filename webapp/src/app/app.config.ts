import 'angular-server-side-configuration/process';
import { ApplicationConfig, importProvidersFrom } from '@angular/core';
import { provideRouter } from '@angular/router';
import { routes } from './app.routes';
import { MQTT_SERVICE_OPTIONS, MqttModule } from "ngx-mqtt";
import { provideOAuthClient } from "angular-oauth2-oidc";
import { provideHttpClient, withInterceptorsFromDi } from "@angular/common/http";
import { provideAnimationsAsync } from '@angular/platform-browser/animations/async';


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
  providers: [provideRouter(routes),
    provideHttpClient(withInterceptorsFromDi()),
    provideOAuthClient(),
    importProvidersFrom(MqttModule.forRoot(MQTT_SERVICE_OPTIONS)), provideAnimationsAsync(),
  ],

};
