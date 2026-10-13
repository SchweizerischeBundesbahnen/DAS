import { Component, inject } from '@angular/core';
import { SbbDividerModule } from '@sbb-esta/lyne-angular/divider';
import { SbbHeaderModule } from '@sbb-esta/lyne-angular/header';
import { SbbMenuModule } from '@sbb-esta/lyne-angular/menu';
import packageJson from '~package.json';
import { AuthService } from '~shared/services/auth.service';
import { Language, LanguageProviderService } from '~shared/services/language-provider.service';
import { environment } from '~src/environments/environment';

@Component({
  selector: 'app-header',
  imports: [SbbHeaderModule, SbbMenuModule, SbbDividerModule],
  templateUrl: './header.html',
  styleUrl: './header.css',
})
export class Header {
  protected readonly authService = inject(AuthService);
  protected readonly languageProviderService = inject(LanguageProviderService);
  protected readonly stage = environment.stage;
  protected readonly version = packageJson.version;

  protected languageIconName(language: Language) {
    return language.localeId === this.languageProviderService.currentLanguage.localeId
      ? 'tick-small'
      : '';
  }
}
