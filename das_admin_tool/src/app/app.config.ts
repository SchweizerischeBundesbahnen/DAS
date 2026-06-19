import { ApplicationConfig, ErrorHandler } from '@angular/core';
import { provideRouter } from '@angular/router';

import { routes } from './app.routes';
import {
  authInterceptor,
  provideAuth,
  withAppInitializerAuthCheck,
} from 'angular-auth-oidc-client';
import { provideHttpClient, withInterceptors } from '@angular/common/http';
import { environment } from '../environments/environment';
import { ReportToInstanaErrorHandler } from './errorHandler';

export const appConfig: ApplicationConfig = {
  providers: [
    { provide: ErrorHandler, useClass: ReportToInstanaErrorHandler },
    provideRouter(routes),
    provideAuth(environment.authConfig, withAppInitializerAuthCheck()),
    provideHttpClient(withInterceptors([authInterceptor()])),
  ],
};
