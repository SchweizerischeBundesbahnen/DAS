import {Component, computed, inject, LOCALE_ID} from '@angular/core';
import {SbbHeader, SbbHeaderButton, SbbHeaderEnvironment} from "@sbb-esta/lyne-angular/header";
import {SbbMenu, SbbMenuButton, SbbMenuLink} from "@sbb-esta/lyne-angular/menu";
import {environment} from '../../environments/environment';
import packageJson from '../../../package.json';
import {OidcSecurityService} from 'angular-auth-oidc-client';
import {SbbDivider} from '@sbb-esta/lyne-angular/divider';
import {Router} from '@angular/router';
import {
  SbbNavigation,
  SbbNavigationButton,
  SbbNavigationList,
  SbbNavigationMarker,
  SbbNavigationSection
} from '@sbb-esta/lyne-angular/navigation';
import {SbbButton} from '@sbb-esta/lyne-angular/button/button';

@Component({
  selector: 'app-header',
  imports: [
    SbbHeader,
    SbbHeaderButton,
    SbbHeaderEnvironment,
    SbbMenu,
    SbbMenuLink,
    SbbDivider,
    SbbMenuButton,
    SbbNavigationButton,
    SbbNavigationList,
    SbbNavigationSection,
    SbbButton,
    SbbNavigationMarker,
    SbbNavigation
  ],
  templateUrl: './header.html',
  styleUrl: './header.css',
})
export class Header {
  protected readonly oidcSecurityService = inject(OidcSecurityService);
  protected readonly stage = environment.stage;
  protected readonly version = packageJson.version;
  protected readonly languages = [
    {localeId: 'de-CH', path: 'de', label: 'Deutsch'},
    {localeId: 'fr-CH', path: 'fr', label: 'Français'},
    {localeId: 'it-CH', path: 'it', label: 'Italiano'}
  ];
  protected readonly roles = computed(() => this.oidcSecurityService.userData().userData.roles.filter((role: string) => role.includes('admin')));
  private readonly router = inject(Router);
  private readonly localeId = inject(LOCALE_ID);
  protected readonly currentLanguage = this.languages
    .find(lang => lang.localeId === this.localeId);

  protected switchLanguage(languagePath: string) {
    const segments = window.location.pathname.split('/').filter(Boolean);
    if (languagePath === segments[0]) {
      return;
    }
    segments[0] = languagePath;
    window.location.href = '/' + segments.join('/') + window.location.search + window.location.hash;
  }

  protected login() {
    this.oidcSecurityService.authorize();
  }

  protected switchLogin() {
    this.oidcSecurityService.authorize(undefined, {customParams: {prompt: 'select_account'}})
  }

  protected async logout() {
    this.oidcSecurityService.logoffLocalMultiple();
    return this.router.navigate(['/unauthorized']);
  }
}
