import {Router, Routes} from '@angular/router';
import {autoLoginPartialRoutesGuard, OidcSecurityService} from 'angular-auth-oidc-client';
import {inject} from '@angular/core';
import {map, take} from 'rxjs';

const isAdmin = () => {
  const oidcSecurityService = inject(OidcSecurityService);
  const router = inject(Router);

  return oidcSecurityService.userData$.pipe(
    take(1),
    map(userData => {
      const roles = userData?.userData?.roles || [];
      if (roles.includes('admin') || roles.includes('ru_admin')) {
        return true;
      }
      return router.parseUrl('/unauthorized');
    })
  );
};

export const routes: Routes = [
  {
    path: '',
    canActivateChild: [autoLoginPartialRoutesGuard, isAdmin],
    children: [
      {
        path: '',
        loadComponent: () => import('./home/home').then(m => m.Home)
      },
      {
        path: 'page',
        loadComponent: () => import('./page/page').then(m => m.Page)
      },
    ]
  },
  {
    path: 'unauthorized',
    loadComponent: () => import('./unauthorized/unauthorized').then(m => m.Unauthorized)
  }
];
