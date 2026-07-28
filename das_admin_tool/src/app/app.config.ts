import { provideHttpClient, withInterceptors } from '@angular/common/http';
import { ApplicationConfig, ErrorHandler, provideAppInitializer } from '@angular/core';
import { provideRouter } from '@angular/router';
import {
  authInterceptor,
  provideAuth,
  withAppInitializerAuthCheck,
} from 'angular-auth-oidc-client';
import { environment } from '~src/environments/environment';
import { routes } from './app.routes';
import { ReportToInstanaErrorHandler } from './error-handler';
import { setupInstana } from './instana-setup.util';

const initApp = (): void => {
  setupInstana();
};

export const appConfig: ApplicationConfig = {
  providers: [
    { provide: ErrorHandler, useClass: ReportToInstanaErrorHandler },
    provideRouter(routes),
    provideAuth(environment.authConfig, withAppInitializerAuthCheck()),
    provideHttpClient(withInterceptors([authInterceptor()])),
    provideAppInitializer(initApp),
  ],
};
