import { Environment } from "./environment.model";
import { AuthConfig } from "angular-oauth2-oidc";

const authConfig: AuthConfig = {
  // This is the issuer URL for the SBB Azure AD organization
  issuer: 'https://login.microsoftonline.com/2cda5d11-f0ac-46b3-967d-af1b2e1bd01a/v2.0',
  // This is required, since Azure AD uses different domains in their issuer configuration
  strictDiscoveryDocumentValidation: false,
  clientId: '6025180f-123b-4f2f-9703-16e08fc221f0',
  // clientId: 'ccd6f4f5-709a-450e-aeff-1625d5b00525',
  redirectUri: location.origin,
  responseType: 'code',
  scope: `openid profile email offline_access 6025180f-123b-4f2f-9703-16e08fc221f0/.default`,
};

export const environment: Environment = {
  production: false,
  label: 'dev',
  oauthProfile: 'azureAd',
  authConfig,
};

/*
 * For easier debugging in development mode, you can import the following file
 * to ignore zone related error stack frames such as `zone.run`, `zoneDelegate.invokeTask`.
 *
 * This import should be commented out in production mode because it will have a negative impact
 * on performance if an error is thrown.
 */
// import 'zone.js/plugins/zone-error';  // Included with Angular CLI.
