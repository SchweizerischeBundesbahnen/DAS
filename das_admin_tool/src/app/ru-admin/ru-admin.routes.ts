import { Routes } from '@angular/router';

export const routes: Routes = [
	{
		path: '',
		loadComponent: () => import('./ru-admin').then((m) => m.RuAdmin),
		children: [
			{ path: '', redirectTo: 'ruindications', pathMatch: 'full' },
			{
				path: 'ruindications',
				loadComponent: () => import('./ru-indications/ru-indications').then((m) => m.RuIndications),
			},
			{
				path: 'ruindication-templates',
				loadComponent: () =>
					import('./ru-indication-templates/ru-indication-templates').then(
						(m) => m.RuIndicationTemplates,
					),
			},
			{
				path: 'special-holidays',
				loadComponent: () =>
					import('./special-holidays/special-holidays.component').then((m) => m.SpecialHolidays),
			},
			{
				path: 'external-links',
				loadComponent: () => import('./external-links/external-links').then((m) => m.ExternalLinks),
			},
		],
	},
];
