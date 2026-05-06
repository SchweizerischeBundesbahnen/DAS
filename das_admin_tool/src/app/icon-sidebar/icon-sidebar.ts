import {Component, inject} from '@angular/core';
import {AuthService} from '../shared/auth-service';
import {SbbIconSidebarModule} from '@sbb-esta/lyne-angular/icon-sidebar';
import {SbbTooltipModule} from '@sbb-esta/lyne-angular/tooltip';
import {RouterLink, RouterLinkActive} from '@angular/router';

@Component({
  selector: 'app-icon-sidebar',
  imports: [
    SbbIconSidebarModule,
    SbbTooltipModule,
    RouterLinkActive,
    RouterLink
  ],
  templateUrl: './icon-sidebar.html',
  styleUrl: './icon-sidebar.css',
})
export class IconSidebar {
  protected authService = inject(AuthService);
}
