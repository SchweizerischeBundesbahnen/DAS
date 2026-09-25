import { TestBed } from '@angular/core/testing';
import { SBB_OVERLAY_DATA } from '@sbb-esta/lyne-angular/core';
import { RuIndicationTemplate } from '~ru-admin/ru-admin-api';
import { expectError } from '~src/testing/utils';
import { RuIndicationTemplateDialog } from './ru-indication-template-dialog';

function createDialog(data?: RuIndicationTemplate): RuIndicationTemplateDialog {
  TestBed.configureTestingModule({
    providers: [RuIndicationTemplateDialog, { provide: SBB_OVERLAY_DATA, useValue: data ?? null }],
  });
  return TestBed.inject(RuIndicationTemplateDialog);
}

describe('RuIndicationTemplateDialog', () => {
  beforeEach(() => vi.clearAllMocks());

  describe('field validation', () => {
    it('should be invalid when form is empty', () => {
      const form = createDialog()['ruIndicationTemplateForm'];

      expect(form().invalid()).toBe(true);
      expect(expectError(form.category(), 'required')).toBe(true);
    });

    it('should have oneLanguageRequired error when no language content is provided', () => {
      const form = createDialog()['ruIndicationTemplateForm'];
      form.category().value.set('Test Category');

      expect(expectError(form.content(), 'oneLanguageRequired')).toBe(true);
    });

    it('should require category when only title is filled', () => {
      const form = createDialog()['ruIndicationTemplateForm'];
      form.content.de.title().value.set('Titel');

      expect(expectError(form.category(), 'required')).toBe(true);
      expect(form.content().errors()).toEqual([]);
    });

    it('should be valid when category and at least one title are filled', () => {
      const form = createDialog()['ruIndicationTemplateForm'];
      form.category().value.set('Test Category');
      form.content.de.title().value.set('Titel');

      expect(form().errors()).toEqual([]);
    });

    it('should be valid when fr title is filled', () => {
      const form = createDialog()['ruIndicationTemplateForm'];
      form.content.fr.title().value.set('Titre');

      expect(form.content().errors()).toEqual([]);
    });

    it('should be valid when it title is filled', () => {
      const form = createDialog()['ruIndicationTemplateForm'];
      form.content.it.title().value.set('Titolo');

      expect(form.content().errors()).toEqual([]);
    });

    it('should be invalid when a title contains only whitespace and text is set', () => {
      const form = createDialog()['ruIndicationTemplateForm'];
      const deTree = form.content.de;
      deTree.title().value.set('  ');
      deTree.text().value.set('Text');

      expect(form.content().errors()).toEqual([]);
      expect(expectError(deTree.title(), 'titleRequired')).toBe(true);
    });

    it('should be invalid title is empty and text is set', () => {
      const form = createDialog()['ruIndicationTemplateForm'];
      const deTree = form.content.de;
      deTree.title().value.set('');
      deTree.text().value.set('Some text');

      expect(expectError(deTree.title(), 'titleRequired')).toBe(true);
    });

    it.each([
      ['Titel', '', 'title is set but text is empty'],
      ['Titel', 'Text', 'both title and text are set'],
      ['', '', 'both title and text are empty'],
    ])('should be valid when $2', (title, text) => {
      const form = createDialog()['ruIndicationTemplateForm'];
      const deTree = form.content.de;
      deTree.title().value.set(title);
      deTree.text().value.set(text);

      expect(deTree().errors()).toEqual([]);
    });
  });
});
