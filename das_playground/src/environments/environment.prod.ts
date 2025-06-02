import 'angular-server-side-configuration/process';
import { Environment } from "./environment.model";
import { PassedInitialConfig } from "angular-auth-oidc-client";
import { IMqttServiceOptions } from "ngx-mqtt";

const authConfig: PassedInitialConfig = {
  config: {
    authority: 'https://login.microsoftonline.com/common/v2.0',
    redirectUrl: window.location.origin,
    clientId: process.env.AUTH_CLIENT_ID,
    scope: `openid profile email offline_access ${process.env.AUTH_SCOPE}`,
    silentRenew: true,
    useRefreshToken: true,
    maxIdTokenIatOffsetAllowedInSeconds: 600,
    issValidationOff: true,
    autoUserInfo: false,
    secureRoutes: [],
    customParamsAuthRequest: {
      prompt: 'select_account',
    },
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
  production: process.env.PRODUCTION !== 'false',
  label: process.env.ENVIRONMENT_LABEL!,
  oauthProfile: process.env.MQTT_OAUTH_PROFILE!,
  customTopicPrefix: process.env.CUSTOM_TOPIC_PREFIX || '',
  backendUrl: process.env.BACKEND_URL!,
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
