import {Component, inject, OnInit} from '@angular/core';
import {NavigationEnd, Router, RouterOutlet} from '@angular/router';
import {Header} from './header/header';
import {IconSidebar} from './icon-sidebar/icon-sidebar';
import packageJson from '../../package.json';
import {OidcSecurityService} from 'angular-auth-oidc-client';

@Component({
  selector: 'app-root',
  imports: [RouterOutlet, Header, IconSidebar],
  templateUrl: './app.html',
  styleUrl: './app.css'
})
export class App implements OnInit {
  private router = inject(Router);
  private oidcSecurityService = inject(OidcSecurityService);

  ngOnInit(): void {
    ineum('meta', 'blockedByAdBlocker', this.isInstanaBlockedByAdBlocker);
    ineum('meta', 'version', packageJson.version);
    ineum('user', this.oidcSecurityService.userData().userData.oid);
    this.router.events
      .subscribe(event => {
        if (event instanceof NavigationEnd && typeof ineum !== 'undefined') {
          console.log('Set page to', event.url)
          ineum('page', event.url);
        }
      });
  }

  public get isInstanaBlockedByAdBlocker(): boolean {
    const pageLoadId = ineum('getPageLoadId');
    return pageLoadId == null;
  }
}
