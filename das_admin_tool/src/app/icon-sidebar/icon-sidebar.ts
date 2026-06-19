import { Component, inject } from '@angular/core';
import { RouterLink, RouterLinkActive } from '@angular/router';
import { SbbIconSidebarModule } from '@sbb-esta/lyne-angular/icon-sidebar';
import { SbbTooltipModule } from '@sbb-esta/lyne-angular/tooltip';
import { AuthService } from '~shared/auth-service';

@Component({
  selector: 'app-icon-sidebar',
  imports: [SbbIconSidebarModule, SbbTooltipModule, RouterLinkActive, RouterLink],
  templateUrl: './icon-sidebar.html',
  styleUrl: './icon-sidebar.css',
})
export class IconSidebar {
  protected authService = inject(AuthService);
}
