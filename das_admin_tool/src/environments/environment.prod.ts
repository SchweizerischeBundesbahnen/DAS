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
    clientId: process.env.AUTH_CLIENT_ID,
    scope: `openid profile email offline_access ${process.env.AUTH_SCOPE}`,
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
