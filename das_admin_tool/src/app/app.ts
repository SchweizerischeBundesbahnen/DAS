import {Component, inject, OnInit, signal} from '@angular/core';
import {NavigationEnd, Router, RouterOutlet} from '@angular/router';
import {Header} from './header/header';
import {IconSidebar} from './icon-sidebar/icon-sidebar';
import packageJson from '../../package.json';
import {AuthService} from './shared/auth-service';
import {SbbTitleModule} from '@sbb-esta/lyne-angular/title';
import {SbbNotificationModule} from '@sbb-esta/lyne-angular/notification';
import {SbbLink} from '@sbb-esta/lyne-angular/link/link';

@Component({
  selector: 'app-root',
  imports: [RouterOutlet, Header, IconSidebar, SbbTitleModule, SbbNotificationModule, SbbLink],
  templateUrl: './app.html',
  styleUrl: './app.css'
})
export class App implements OnInit {
  protected isAdBlockerDetected = signal(this.isInstanaBlockedByAdBlocker);
  private readonly router = inject(Router);
  private readonly authService = inject(AuthService);

  private get isInstanaBlockedByAdBlocker(): boolean {
    const pageLoadId = ineum('getPageLoadId');
    return pageLoadId == null;
  }

  ngOnInit(): void {
    ineum('meta', 'version', packageJson.version);
    if (this.authService.isAuthenticated()) {
      ineum('user', this.authService.oid());
    }
    this.router.events
      .subscribe(event => {
        if (event instanceof NavigationEnd && typeof ineum !== 'undefined') {
          console.log('Set page to', event.url)
          ineum('page', event.url);
        }
      });
  }
}
