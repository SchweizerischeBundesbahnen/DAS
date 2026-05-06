import {inject, Injectable, LOCALE_ID} from '@angular/core';

export interface Language {
  localeId: string;
  path: LanguageCode;
  label: string;
}

export type LanguageCode = 'de' | 'fr' | 'it';

@Injectable({
  providedIn: 'root',
})
export class LanguageProvider {
  public readonly allLanguages: Language[] = [
    {localeId: 'de-CH', path: 'de', label: 'Deutsch'},
    {localeId: 'fr-CH', path: 'fr', label: 'Français'},
    {localeId: 'it-CH', path: 'it', label: 'Italiano'}
  ];
  private readonly localeId = inject(LOCALE_ID);
  public readonly currentLanguage = this.allLanguages.find(lang => lang.localeId === this.localeId);

  public switch(language: Language) {
    const languagePath = language.path;
    const segments = window.location.pathname.split('/').filter(Boolean);
    if (languagePath === segments[0]) {
      return;
    }
    segments[0] = languagePath;
    window.location.href = '/' + segments.join('/') + window.location.search + window.location.hash;
  }
}
