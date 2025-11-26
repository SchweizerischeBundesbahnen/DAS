import {Routes} from '@angular/router';
import {Home} from './home/home';
import {Page} from './page/page';

export const routes: Routes = [
  {
    path: 'page',
    component: Page
  },
  {
    path: '',
    component: Home
  },
];
