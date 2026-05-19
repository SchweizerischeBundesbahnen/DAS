import {Routes} from '@angular/router';

export const routes: Routes = [
  {
    path: '',
    loadComponent: () => import('./ru-admin').then((m) => m.RuAdmin),
    children: [
      {
        path: '',
        redirectTo: 'notice-templates',
        pathMatch: 'full',
      },
      {
        path: 'notice-templates',
        loadComponent: () => import('./notice-templates/notice-templates').then((m) => m.NoticeTemplates),
      },
      {
        path: 'special-holidays',
        loadComponent: () => import('./special-holidays/special-holidays.component').then((m) => m.SpecialHolidays),
      },
    ],
  },
];

