import { Routes } from '@angular/router';
import { autoLoginPartialRoutesGuard } from 'angular-auth-oidc-client';
import { inject } from '@angular/core';
import { AuthService } from './shared/auth-service';

const isTenantAllowed = () => {
  const authService = inject(AuthService);
  if (!authService.isAuthenticated()) return true;
  return authService.isAllowedTenant() || authService.navigateToUnauthorized();
};

const isAdmin = () => {
  const authService = inject(AuthService);
  if (!authService.isAuthenticated()) return true;
  return authService.isAdmin() || authService.navigateToUnauthorized();
};

const isRuAdmin = () => {
  const authService = inject(AuthService);
  if (!authService.isAuthenticated()) return true;
  return authService.isRuAdmin() || authService.navigateToUnauthorized();
};

export const routes: Routes = [
  {
    path: '',
    canActivateChild: [autoLoginPartialRoutesGuard, isTenantAllowed, isRuAdmin],
    children: [
      {
        path: '',
        redirectTo: 'ru-admin',
        pathMatch: 'full'
      },
      {
        path: 'das-admin',
        canActivate: [isAdmin],
        loadComponent: () => import('./das-admin/das-admin').then(m => m.DasAdmin)
      },
      {
        path: 'ru-admin',
        canActivate: [isRuAdmin],
        loadChildren: () => import('./ru-admin/ru-admin.routes').then((m) => m.routes)
      }
    ]
  },
  {
    path: 'unauthorized',
    loadComponent: () => import('./unauthorized/unauthorized').then(m => m.Unauthorized)
  }
];
