import { TestBed } from '@angular/core/testing';
import { SBB_OVERLAY_DATA } from '@sbb-esta/lyne-angular/core';
import { ExternalLink } from '~ru-admin/ru-admin-api';
import { expectError } from '~src/testing/utils';
import { ExternalLinkDialog } from './external-link-dialog';

function createDialog(data?: ExternalLink): ExternalLinkDialog {
  TestBed.configureTestingModule({
    providers: [ExternalLinkDialog, { provide: SBB_OVERLAY_DATA, useValue: data ?? null }],
  });
  return TestBed.inject(ExternalLinkDialog);
}

const existingExternalLink: ExternalLink = {
  id: 1,
  companies: ['2185'],
  de: { title: 'Titel', link: 'https://sbb.ch' },
};

describe('ExternalLinkDialog', () => {
  beforeEach(() => vi.clearAllMocks());

  describe('oneLanguageRequired validator', () => {
    it('should be invalid when all language fields are empty', () => {
      const dialog = createDialog();

      expect(expectError(dialog['externalLinkForm'](), 'oneLanguageRequired')).toBe(true);
    });

    it('should be valid when de title and link are filled', () => {
      const dialog = createDialog();
      dialog['externalLinkForm'].de.title().value.set('Titel');
      dialog['externalLinkForm'].de.link().value.set('https://sbb.ch');

      expect(dialog['externalLinkForm']().errors()).toEqual([]);
    });

    it('should be valid when fr title and link are filled', () => {
      const dialog = createDialog();
      dialog['externalLinkForm'].fr.title().value.set('Titre');
      dialog['externalLinkForm'].fr.link().value.set('https://sbb.ch');

      expect(dialog['externalLinkForm']().errors()).toEqual([]);
    });

    it('should be valid when it title and link are filled', () => {
      const dialog = createDialog();
      dialog['externalLinkForm'].it.title().value.set('Titolo');
      dialog['externalLinkForm'].it.link().value.set('https://sbb.ch');

      expect(dialog['externalLinkForm']().errors()).toEqual([]);
    });

    it('should be invalid when titles contain only whitespace', () => {
      const dialog = createDialog();
      dialog['externalLinkForm'].de.title().value.set('  ');
      dialog['externalLinkForm'].de.link().value.set('https://sbb.ch');

      expect(dialog['externalLinkForm']().errors()).toEqual([]);
      expect(expectError(dialog['externalLinkForm'].de.title(), 'languageRequired')).toBe(true);
    });
  });

  describe('languageRequired validator', () => {
    it('should be invalid for a language tree when link is set but title is empty', () => {
      const dialog = createDialog();
      const deTree = dialog['externalLinkForm'].de;
      deTree.link().value.set('https://sbb.ch');

      expect(expectError(deTree.title(), 'languageRequired')).toBe(true);
    });

    it('should be invalid for a language tree when title is set but link is empty', () => {
      const dialog = createDialog();
      const deTree = dialog['externalLinkForm'].de;
      deTree.title().value.set('Titel');

      expect(expectError(deTree.link(), 'languageRequired')).toBe(true);
    });

    it('should be valid when both title and link are set', () => {
      const dialog = createDialog();
      const deTree = dialog['externalLinkForm'].de;
      deTree.title().value.set('Titel');
      deTree.link().value.set('https://sbb.ch');

      expect(deTree().errors()).toEqual([]);
    });

    it('should be valid when both title and link are empty', () => {
      const dialog = createDialog();
      const deTree = dialog['externalLinkForm'].de;

      expect(deTree().errors()).toEqual([]);
    });
  });

  describe('url validator', () => {
    it('should be invalid when link doesnt match url validator', () => {
      const dialog = createDialog();
      const deLink = dialog['externalLinkForm'].de.link;
      deLink().value.set('sbb.ch');

      expect(expectError(deLink(), 'url')).toBe(true);
    });

    it('should be valid when link is empty', () => {
      const dialog = createDialog();
      const deLink = dialog['externalLinkForm'].de.link;

      expect(expectError(deLink(), 'url')).toBe(false);
    });

    it('should be valid when link does match url validator', () => {
      const dialog = createDialog();
      const deLink = dialog['externalLinkForm'].de.link;
      deLink().value.set('https://sbb.ch');

      expect(expectError(deLink(), 'url')).toBe(false);
    });
  });

  describe('isLanguageEmpty', () => {
    it('should return true when title is empty', () => {
      const dialog = createDialog();

      expect(dialog['isLanguageEmpty']('de')).toBe(true);
    });

    it('should return true when title is only whitespace', () => {
      const dialog = createDialog();
      dialog['externalLinkForm'].de.title().value.set('  ');

      expect(dialog['isLanguageEmpty']('de')).toBe(true);
    });

    it('should return false when title has content', () => {
      const dialog = createDialog(existingExternalLink);

      expect(dialog['isLanguageEmpty']('de')).toBe(false);
    });

    it('should return false when link has content', () => {
      const dialog = createDialog(existingExternalLink);
      dialog['externalLinkForm'].de.link().value.set('https://sbb.ch');

      expect(dialog['isLanguageEmpty']('de')).toBe(false);
    });
  });
});
