import { PassedInitialConfig } from "angular-auth-oidc-client";
import { IMqttServiceOptions } from "ngx-mqtt";

export interface Environment {
  production: boolean;
  label: string;
  oauthProfile: string;
  backendUrl: string;
  authConfig:PassedInitialConfig ;
  mqttServiceOptions:IMqttServiceOptions;
}
