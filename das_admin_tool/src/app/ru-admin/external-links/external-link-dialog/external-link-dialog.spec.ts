import {TestBed} from '@angular/core/testing';
import {ExternalLinkDialog} from './external-link-dialog';
import {SBB_OVERLAY_DATA} from '@sbb-esta/lyne-angular/core/overlay';
import {ExternalLink} from '../../ru-admin-api';

function createDialog(data?: ExternalLink): ExternalLinkDialog {
  TestBed.configureTestingModule({
    providers: [
      ExternalLinkDialog,
      {provide: SBB_OVERLAY_DATA, useValue: data ?? null},
    ],
  });
  return TestBed.inject(ExternalLinkDialog);
}

const existingExternalLink: ExternalLink = {
  id: 1,
  companies: ['2185'],
  de: {title: 'Titel', link: 'https://sbb.ch'},
};

describe('ExternalLinkDialog', () => {
  beforeEach(() => vi.clearAllMocks());

  describe('oneLanguageRequired validator', () => {
    it('should be invalid when all language fields are empty', () => {
      const dialog = createDialog();

      expect(dialog['externalLinkForm'].errors).toEqual({oneLanguageRequired: true});
    });

    it('should be valid when de title and link are filled', () => {
      const dialog = createDialog();
      dialog['externalLinkForm'].get('de.title')!.setValue('Titel');
      dialog['externalLinkForm'].get('de.link')!.setValue('https://sbb.ch');

      expect(dialog['externalLinkForm'].errors).toBeNull();
    });

    it('should be valid when fr title and link are filled', () => {
      const dialog = createDialog();
      dialog['externalLinkForm'].get('fr.title')!.setValue('Titre');
      dialog['externalLinkForm'].get('fr.link')!.setValue('https://sbb.ch');

      expect(dialog['externalLinkForm'].errors).toBeNull();
    });

    it('should be valid when it title and link are filled', () => {
      const dialog = createDialog();
      dialog['externalLinkForm'].get('it.title')!.setValue('Titolo');
      dialog['externalLinkForm'].get('it.link')!.setValue('https://sbb.ch');

      expect(dialog['externalLinkForm'].errors).toBeNull();
    });

    it('should be invalid when titles contain only whitespace', () => {
      const dialog = createDialog();
      dialog['externalLinkForm'].get('de.title')!.setValue('   ');
      dialog['externalLinkForm'].get('de.link')!.setValue('https://sbb.ch');

      expect(dialog['externalLinkForm'].errors).toBeNull();
      expect(dialog['externalLinkForm'].get('de.title')!.errors).toEqual({languageRequired: true});
    });
  });

  describe('languageRequired validator', () => {
    it('should be invalid for a language group when link is set but title is empty', () => {
      const dialog = createDialog();
      const deGroup = dialog['externalLinkForm'].get('de')!;
      deGroup.get('link')!.setValue('https://sbb.ch');

      expect(deGroup.get('title')!.errors).toEqual({languageRequired: true});
    });

    it('should be invalid for a language group when title is set but link is empty', () => {
      const dialog = createDialog();
      const deGroup = dialog['externalLinkForm'].get('de')!;
      deGroup.get('title')!.setValue('Titel');

      expect(deGroup.get('link')!.errors).toEqual({languageRequired: true});
    });

    it('should be valid when both title and link are set', () => {
      const dialog = createDialog();
      const deGroup = dialog['externalLinkForm'].get('de')!;
      deGroup.get('title')!.setValue('Titel');
      deGroup.get('link')!.setValue('https://sbb.ch');

      expect(deGroup.errors).toBeNull();
    });

    it('should be valid when both title and link are empty', () => {
      const dialog = createDialog();
      const deGroup = dialog['externalLinkForm'].get('de')!;

      expect(deGroup.errors).toBeNull();
    });
  });

  describe('url validator', () => {
    it('should be invalid when link doesnt match url validator', () => {
      const dialog = createDialog();
      const deLink = dialog['externalLinkForm'].get('de.link')!;
      deLink.setValue('sbb.ch');

      expect(deLink.hasError('url')).toBe(true);
    });

    it('should be valid when link is empty', () => {
      const dialog = createDialog();
      const deLink = dialog['externalLinkForm'].get('de.link')!;

      expect(deLink.hasError('url')).toBe(false);
    });

    it('should be valid when link does match url validator', () => {
      const dialog = createDialog();
      const deLink = dialog['externalLinkForm'].get('de.link')!;
      deLink.setValue('https://sbb.ch');

      expect(deLink.hasError('url')).toBe(false);
    });
  });

  describe('isLanguageEmpty', () => {
    it('should return true when title is empty', () => {
      const dialog = createDialog();

      expect(dialog['isLanguageEmpty']('de')).toBe(true);
    });

    it('should return true when title is only whitespace', () => {
      const dialog = createDialog();
      dialog['externalLinkForm'].get('de.title')!.setValue('   ');

      expect(dialog['isLanguageEmpty']('de')).toBe(true);
    });

    it('should return false when title has content', () => {
      const dialog = createDialog(existingExternalLink);

      expect(dialog['isLanguageEmpty']('de')).toBe(false);
    });

    it('should return false when link has content', () => {
      const dialog = createDialog(existingExternalLink);
      dialog['externalLinkForm'].get('de.link')!.setValue('https://sbb.ch');

      expect(dialog['isLanguageEmpty']('de')).toBe(false);
    });
  });
});
