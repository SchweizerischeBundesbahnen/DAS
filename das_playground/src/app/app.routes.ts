import { Routes } from '@angular/router';
import { autoLoginPartialRoutesGuard } from "angular-auth-oidc-client";

export const routes: Routes = [
  {
    path: '',
    canActivate: [autoLoginPartialRoutesGuard],
    children: [
      {
        path: '',
        pathMatch: 'prefix',
        redirectTo: 'sfera'
      },
      {
        path: 'sfera',
        loadComponent: () => import('./sfera-observer/sfera-observer.component').then((m) => m.SferaObserverComponent),
      },
      {
        path: 'sfera-discover',
        loadComponent: () => import('./sfera-discover/sfera-discover.component').then((m) => m.SferaDiscoverComponent),
      },
      {
        path: 'mqtt',
        loadComponent: () =>
          import('./mqtt-playground/mqtt-playground.component').then((m) => m.MqttPlaygroundComponent),
      },
      {
        path: 'auth-insights',
        loadComponent: () =>
          import('./auth-insights/auth-insights.component').then((m) => m.AuthInsightsComponent),
      },
    ],
  },
  {
    path: 'unauthorized',
    loadComponent: () => import('./unauthorized/unauthorized.component').then((m) => m.UnauthorizedComponent)
  }
];
