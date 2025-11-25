import {Routes} from '@angular/router';
import {autoLoginPartialRoutesGuard} from 'angular-auth-oidc-client';

export const routes: Routes = [
  {
    path: '',
    canActivateChild: [autoLoginPartialRoutesGuard],
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
