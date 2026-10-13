import { LOCALE_ID } from '@angular/core';
import { TestBed } from '@angular/core/testing';
import { LanguageProviderService } from './language-provider.service';

function setup(localeId = 'de-CH') {
  TestBed.configureTestingModule({
    providers: [{ provide: LOCALE_ID, useValue: localeId }],
  });

  return TestBed.inject(LanguageProviderService);
}

describe('LanguageProviderService', () => {
  it('should be created', () => {
    const languageProviderService = setup();
    expect(languageProviderService).toBeTruthy();
  });

  it('exposes 3 supported languages', () => {
    const languageProviderService = setup();

    expect(languageProviderService.allLanguages).toHaveLength(3);
  });

  it('resolves currentLanguage from LOCALE_ID', () => {
    const languageProviderService = setup('fr-CH');

    expect(languageProviderService.currentLanguage).toEqual({
      localeId: 'fr-CH',
      path: 'fr',
      label: 'Français',
    });
  });

  it('returns undefined currentLanguage for unsupported locale', () => {
    const languageProviderService = setup('en-US');

    expect(languageProviderService.currentLanguage).toBeUndefined();
  });
});
