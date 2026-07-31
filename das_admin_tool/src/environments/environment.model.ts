import { PassedInitialConfig } from 'angular-auth-oidc-client';

export interface Environment {
  production: boolean;
  stage: string;
  backendUrl: string;
  adminTenantId: string;
  allowedTenantIds: string[];
  authConfig: PassedInitialConfig;
  instanaKey?: string;
}
