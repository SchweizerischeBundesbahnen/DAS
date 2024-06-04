import { AuthConfig } from "angular-oauth2-oidc";

export interface Environment {
  production: boolean;
  label: string;
  oauthProfile: string;
  authConfig: AuthConfig;
}
