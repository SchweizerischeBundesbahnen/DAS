import { Component, inject, OnInit, signal } from '@angular/core';
import { NavigationEnd, Router, RouterOutlet } from '@angular/router';
import { SbbLink } from '@sbb-esta/lyne-angular/link';
import { SbbNotificationModule } from '@sbb-esta/lyne-angular/notification';
import { SbbTitleModule } from '@sbb-esta/lyne-angular/title';
import packageJson from '~package.json';
import { AuthService } from '~shared/auth-service';
import { Header } from './header/header';
import { IconSidebar } from './icon-sidebar/icon-sidebar';

@Component({
  selector: 'app-root',
  imports: [RouterOutlet, Header, IconSidebar, SbbTitleModule, SbbNotificationModule, SbbLink],
  templateUrl: './app.html',
  styleUrl: './app.css',
})
export class App implements OnInit {
  private readonly router = inject(Router);
  private readonly authService = inject(AuthService);

  protected readonly isAdBlockerDetected = signal(this.isInstanaBlockedByAdBlocker);

  private get isInstanaBlockedByAdBlocker(): boolean {
    const pageLoadId = ineum('getPageLoadId');
    return pageLoadId === undefined;
  }

  ngOnInit(): void {
    ineum('meta', 'version', packageJson.version);
    if (this.authService.isAuthenticated()) {
      ineum('user', this.authService.oid());
    }
    this.router.events.subscribe((event) => {
      if (event instanceof NavigationEnd && typeof ineum !== 'undefined') {
        ineum('page', event.url);
      }
    });
  }
}
