import {PassedInitialConfig} from 'angular-auth-oidc-client';

export interface Environment {
  production: boolean;
  stage: string;
  backendUrl: string;
  adminTenantId: string;
  authConfig: PassedInitialConfig
}
