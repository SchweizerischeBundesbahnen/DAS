import {Component, inject, LOCALE_ID} from '@angular/core';
import {SbbHeader, SbbHeaderButton, SbbHeaderEnvironment} from "@sbb-esta/lyne-angular/header";
import {SbbMenu, SbbMenuLink} from "@sbb-esta/lyne-angular/menu";
import {environment} from '../../environments/environment';
import packageJson from '../../../package.json';

@Component({
  selector: 'app-header',
  imports: [
    SbbHeader,
    SbbHeaderButton,
    SbbHeaderEnvironment,
    SbbMenu,
    SbbMenuLink
  ],
  templateUrl: './header.html',
  styleUrl: './header.css',
})
export class Header {
  protected readonly stage = environment.stage;
  protected readonly version = packageJson.version;
  protected readonly languages = [
    {localeId: 'de-CH', path: 'de', label: 'Deutsch'},
    {localeId: 'fr-CH', path: 'fr', label: 'Français'},
    {localeId: 'it-CH', path: 'it', label: 'Italiano'}
  ];
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
}
