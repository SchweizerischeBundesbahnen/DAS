import { LOCALE_ID } from '@angular/core';
import { TestBed } from '@angular/core/testing';
import { LanguageService } from './language.service';

function setup(localeId = 'de-CH') {
  TestBed.configureTestingModule({
    providers: [{ provide: LOCALE_ID, useValue: localeId }],
  });

  return TestBed.inject(LanguageService);
}

describe('LanguageService', () => {
  it('should be created', () => {
    const languageService = setup();
    expect(languageService).toBeTruthy();
  });

  it('exposes 3 supported languages', () => {
    const languageService = setup();

    expect(languageService.allLanguages).toHaveLength(3);
  });

  it('resolves currentLanguage from LOCALE_ID', () => {
    const languageService = setup('fr-CH');

    expect(languageService.currentLanguage).toEqual({
      localeId: 'fr-CH',
      path: 'fr',
      label: 'Français',
    });
  });

  it('returns undefined currentLanguage for unsupported locale', () => {
    const languageService = setup('en-US');

    expect(languageService.currentLanguage).toBeUndefined();
  });
});
