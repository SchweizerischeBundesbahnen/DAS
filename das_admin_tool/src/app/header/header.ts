import {Component, inject} from '@angular/core';
import {SbbHeaderModule} from "@sbb-esta/lyne-angular/header";
import {SbbMenuModule} from "@sbb-esta/lyne-angular/menu";
import {environment} from '../../environments/environment';
import packageJson from '../../../package.json';
import {SbbDividerModule} from '@sbb-esta/lyne-angular/divider';
import {AuthService} from '../shared/auth-service';
import {Language, LanguageProvider} from '../shared/language-provider';

@Component({
  selector: 'app-header',
  imports: [
    SbbHeaderModule,
    SbbMenuModule,
    SbbDividerModule,
  ],
  templateUrl: './header.html',
  styleUrl: './header.css',
})
export class Header {
  protected readonly authService = inject(AuthService);
  protected readonly languageProvider = inject(LanguageProvider);
  protected readonly stage = environment.stage;
  protected readonly version = packageJson.version;

  protected languageIconName(language: Language) {
    return language.localeId === this.languageProvider.currentLanguage?.localeId ? 'tick-small' : '';
  }
}
