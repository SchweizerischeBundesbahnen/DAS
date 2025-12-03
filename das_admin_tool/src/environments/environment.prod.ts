import 'angular-server-side-configuration/process';

import {Environment} from './environment.model';
import {PassedInitialConfig} from 'angular-auth-oidc-client';

/**
 * How to use angular-server-side-configuration:
 *
 * Use process.env.NAME_OF_YOUR_ENVIRONMENT_VARIABLE
 *
 * export const environment = {
 *   stringValue: process.env.STRING_VALUE,
 *   stringValueWithDefault: process.env.STRING_VALUE || 'defaultValue',
 *   numberValue: Number(process.env.NUMBER_VALUE),
 *   numberValueWithDefault: Number(process.env.NUMBER_VALUE || 10),
 *   booleanValue: Boolean(process.env.BOOLEAN_VALUE),
 *   booleanValueInverted: process.env.BOOLEAN_VALUE_INVERTED !== 'false',
 * };
 */

const backendUrl = process.env.BACKEND_URL;

const authConfig: PassedInitialConfig = {
  config: {
    authority: 'https://login.microsoftonline.com/common/v2.0',
    redirectUrl: location.origin + location.pathname.substring(0, location.pathname.indexOf('/', 1) + 1),
    clientId: 'ded405bf-22e0-478e-9963-2467ea1fd539',
    scope: 'openid profile email offline_access api://8f16d52b-c6df-4a94-a132-da4956579a48/.default',
    strictIssuerValidationOnWellKnownRetrievalOff: true,
    responseType: 'code',
    silentRenew: true,
    useRefreshToken: true,
    maxIdTokenIatOffsetAllowedInSeconds: 600,
    ignoreNonceAfterRefresh: true, // see https://github.com/damienbod/angular-auth-oidc-client/issues/1947
    secureRoutes: [backendUrl],
    issValidationOff: true,
    autoUserInfo: false,
  }
}

export const environment: Environment = {
  production: process.env.PRODUCTION !== 'false',
  stage: process.env.STAGE,
  backendUrl,
  authConfig,
};
