import {Routes} from '@angular/router';

export const routes: Routes = [
  {
    path: '',
    loadComponent: () => import('./ru-admin').then((m) => m.RuAdmin),
    children: [
      {
        path: '',
        redirectTo: 'indications',
        pathMatch: 'full',
      },
      {
        path: 'indications',
        loadComponent: () => import('./ru-indications/ru-indications').then((m) => m.RuIndications),
      },
      {
        path: 'templates',
        loadComponent: () => import('./ru-indication-templates/ru-indication-templates').then((m) => m.RuIndicationTemplates),
      },
      {
        path: 'special-holidays',
        loadComponent: () => import('./special-holidays/special-holidays.component').then((m) => m.SpecialHolidays),
      },
    ],
  },
];

