import { inject } from '@angular/core';
import { Routes } from '@angular/router';
import { autoLoginPartialRoutesGuard } from 'angular-auth-oidc-client';
import { AuthService } from '~shared/auth-service';

const isAdmin = () => {
  const authService = inject(AuthService);
  return authService.isAdmin() ?? authService.navigateToUnauthorized();
};

const isRuAdmin = () => {
  const authService = inject(AuthService);
  return authService.isRuAdmin() ?? authService.navigateToUnauthorized();
};

export const routes: Routes = [
  {
    path: '',
    canActivateChild: [autoLoginPartialRoutesGuard, isRuAdmin],
    children: [
      { path: '', redirectTo: 'ru-admin', pathMatch: 'full' },
      {
        path: 'das-admin',
        canActivate: [isAdmin],
        loadComponent: () => import('./das-admin/das-admin').then((m) => m.DasAdmin),
      },
      {
        path: 'ru-admin',
        canActivate: [isRuAdmin],
        loadChildren: () => import('./ru-admin/ru-admin.routes').then((m) => m.routes),
      },
    ],
  },
  {
    path: 'unauthorized',
    loadComponent: () => import('./unauthorized/unauthorized').then((m) => m.Unauthorized),
  },
];
