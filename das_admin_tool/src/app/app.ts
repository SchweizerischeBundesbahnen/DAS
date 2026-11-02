import { Component, inject, OnInit } from '@angular/core';
import { NavigationEnd, Router, RouterOutlet } from '@angular/router';
import { SbbLink } from '@sbb-esta/lyne-angular/link';
import { SbbNotificationModule } from '@sbb-esta/lyne-angular/notification';
import { SbbTitleModule } from '@sbb-esta/lyne-angular/title';
import packageJson from '~package.json';
import { AuthService } from '~shared/services/auth.service';
import { Header } from './header/header';
import { IconSidebar } from './icon-sidebar/icon-sidebar';
import { isInstanaBlocked } from './instana-setup.util';

@Component({
  selector: 'app-root',
  imports: [RouterOutlet, Header, IconSidebar, SbbTitleModule, SbbNotificationModule, SbbLink],
  templateUrl: './app.html',
  styleUrl: './app.css',
})
export class App implements OnInit {
  private readonly router = inject(Router);
  private readonly authService = inject(AuthService);

  protected readonly isInstanaBlocked = isInstanaBlocked;

  ngOnInit(): void {
    ineum('meta', 'version', packageJson.version);
    if (this.authService.isAuthenticated()) {
      ineum('user', this.authService.oid());
    }
    this.router.events.subscribe((event) => {
      if (typeof ineum !== 'undefined' && event instanceof NavigationEnd) {
        ineum('page', event.url);
      }
    });
  }
}
