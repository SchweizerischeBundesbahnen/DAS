import { Routes } from '@angular/router';

export const routes: Routes = [
  {
    path: '',
    loadComponent: () => import('./das-admin').then((m) => m.DasAdmin),
    children: [
      { path: '', redirectTo: 'app-versions', pathMatch: 'full' },
      {
        path: 'app-versions',
        loadComponent: () => import('./app-versions/app-versions').then((m) => m.AppVersions),
      },
      {
        path: 'companies',
        loadComponent: () => import('./companies/companies').then((m) => m.Companies),
      },
    ],
  },
];
