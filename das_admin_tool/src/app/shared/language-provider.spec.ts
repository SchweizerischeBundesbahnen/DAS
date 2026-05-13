import {LOCALE_ID} from '@angular/core';
import {TestBed} from '@angular/core/testing';

import {LanguageProvider} from './language-provider';

describe('LanguageProvider', () => {
  const setup = (localeId = 'de-CH') => {
    TestBed.configureTestingModule({
      providers: [{provide: LOCALE_ID, useValue: localeId}],
    });

    return TestBed.inject(LanguageProvider);
  };

  it('should be created', () => {
    const service = setup();
    expect(service).toBeTruthy();
  });

  it('exposes 3 supported languages', () => {
    const service = setup();

    expect(service.allLanguages).toHaveLength(3);
  });

  it('resolves currentLanguage from LOCALE_ID', () => {
    const service = setup('fr-CH');

    expect(service.currentLanguage).toEqual({localeId: 'fr-CH', path: 'fr', label: 'Français'});
  });

  it('returns undefined currentLanguage for unsupported locale', () => {
    const service = setup('en-US');

    expect(service.currentLanguage).toBeUndefined();
  });
});
