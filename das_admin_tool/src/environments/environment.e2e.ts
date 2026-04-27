import {Environment} from './environment.model';
import {PassedInitialConfig} from 'angular-auth-oidc-client';

const backendUrl = 'https://das-dev-int.api.sbb.ch';

const authConfig: PassedInitialConfig = {
  config: {
    authority: 'https://login.microsoftonline.com/common/v2.0',
    redirectUrl: window.location.origin,
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
};

export const environment: Environment = {
  production: false,
  stage: 'e2e',
  backendUrl,
  adminTenantId: '2cda5d11-f0ac-46b3-967d-af1b2e1bd01a',
  authConfig
};
