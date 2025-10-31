import {Environment} from "./environment.model";
import {PassedInitialConfig} from "angular-auth-oidc-client";
import {IMqttServiceOptions} from "ngx-mqtt";

const backendUrl = 'http://localhost:8081';
const customTopicPrefix = 'dev/';

const authConfig: PassedInitialConfig = {
  config: {
    authority: 'https://login.microsoftonline.com/common/v2.0',
    redirectUrl: window.location.origin,
    clientId: 'ded405bf-22e0-478e-9963-2467ea1fd539',
    scope: 'openid profile email offline_access api://8f16d52b-c6df-4a94-a132-da4956579a48/.default',
    silentRenew: true,
    useRefreshToken: true,
    maxIdTokenIatOffsetAllowedInSeconds: 600,
    issValidationOff: true,
    autoUserInfo: false,
    secureRoutes: [],
    customParamsAuthRequest: {
      prompt: 'select_account',
    },
    strictIssuerValidationOnWellKnownRetrievalOff: true
  }
}

const mqttServiceOptions: IMqttServiceOptions = {
  hostname: 'das-poc.messaging.solace.cloud',
  port: 8443,
  clean: true, // Retain session
  connectTimeout: 4000, // Timeout period
  reconnectPeriod: 4000, // Reconnect period
  clientId: crypto.randomUUID(),
  protocol: 'wss',
  connectOnCreate: false
}

export const environment: Environment = {
  production: false,
  label: 'dev',
  oauthProfile: 'azureAdDev',
  customTopicPrefix,
  backendUrl,
  authConfig,
  mqttServiceOptions,
};

/*
 * For easier debugging in development mode, you can import the following file
 * to ignore zone related error stack frames such as `zone.run`, `zoneDelegate.invokeTask`.
 *
 * This import should be commented out in production mode because it will have a negative impact
 * on performance if an error is thrown.
 */
// import 'zone.js/plugins/zone-error';  // Included with Angular CLI.
