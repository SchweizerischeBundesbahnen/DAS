import { TestBed } from '@angular/core/testing';
import { SBB_OVERLAY_DATA } from '@sbb-esta/lyne-angular/core';
import { RuIndicationTemplate } from '~ru-admin/ru-admin-api';
import { RuIndicationTemplateDialog } from './ru-indication-template-dialog';

function createDialog(data?: RuIndicationTemplate): RuIndicationTemplateDialog {
  TestBed.configureTestingModule({
    providers: [RuIndicationTemplateDialog, { provide: SBB_OVERLAY_DATA, useValue: data ?? null }],
  });
  return TestBed.inject(RuIndicationTemplateDialog);
}

describe('RuIndicationTemplateDialog', () => {
  beforeEach(() => vi.clearAllMocks());

  describe('required field validation', () => {
    it('should be invalid when form is empty', () => {
      const dialog = createDialog();
      expect(dialog['ruIndicationTemplateForm'].invalid).toBe(true);
    });

    it('should require category field', () => {
      const dialog = createDialog();
      expect(dialog['ruIndicationTemplateForm'].get('category')!.hasError('required')).toBe(true);
    });

    it('should still be invalid when only category is filled but no language content', () => {
      const dialog = createDialog();
      dialog['ruIndicationTemplateForm'].get('category')!.setValue('Test Category');
      dialog['ruIndicationTemplateForm'].updateValueAndValidity();
      expect(dialog['ruIndicationTemplateForm'].invalid).toBe(true);
    });

    it('should still be invalid when only title is filled but category is empty', () => {
      const dialog = createDialog();
      dialog['ruIndicationTemplateForm'].get('content.de.title')!.setValue('Titel');
      dialog['ruIndicationTemplateForm'].updateValueAndValidity();
      expect(dialog['ruIndicationTemplateForm'].invalid).toBe(true);
    });

    it('should be valid when category and at least one title are filled', () => {
      const dialog = createDialog();
      dialog['ruIndicationTemplateForm'].get('category')!.setValue('Test Category');
      dialog['ruIndicationTemplateForm'].get('content.de.title')!.setValue('Titel');
      dialog['ruIndicationTemplateForm'].updateValueAndValidity();
      expect(dialog['ruIndicationTemplateForm'].invalid).toBe(false);
    });
  });

  describe('oneLanguageRequired validator', () => {
    it('should be invalid when all language titles and texts are empty', () => {
      const dialog = createDialog();
      expect(dialog['ruIndicationTemplateForm'].get('content')!.errors).toEqual({
        oneLanguageRequired: true,
      });
    });

    it('should be valid when de title is filled', () => {
      const dialog = createDialog();
      dialog['ruIndicationTemplateForm'].get('content.de.title')!.setValue('Titel');
      expect(dialog['ruIndicationTemplateForm'].get('content')!.errors).toBeNull();
    });

    it('should be valid when fr title is filled', () => {
      const dialog = createDialog();
      dialog['ruIndicationTemplateForm'].get('content.fr.title')!.setValue('Titre');
      expect(dialog['ruIndicationTemplateForm'].get('content')!.errors).toBeNull();
    });

    it('should be valid when it title is filled', () => {
      const dialog = createDialog();
      dialog['ruIndicationTemplateForm'].get('content.it.title')!.setValue('Titolo');
      expect(dialog['ruIndicationTemplateForm'].get('content')!.errors).toBeNull();
    });

    it('should be invalid when a title contains only whitespace', () => {
      const dialog = createDialog();
      const deGroup = dialog['ruIndicationTemplateForm'].get('content.de')!;
      dialog['ruIndicationTemplateForm'].get('content.de.title')!.setValue('  ');
      dialog['ruIndicationTemplateForm'].get('content.de.text')!.setValue('Text');
      expect(dialog['ruIndicationTemplateForm'].get('content')!.errors).toBeNull();
      expect(deGroup.get('title')!.errors).toEqual({ titleRequired: true });
    });
  });

  describe('titleRequired validator', () => {
    it('should be invalid for a language group when text is set but title is empty', () => {
      const dialog = createDialog();
      const deGroup = dialog['ruIndicationTemplateForm'].get('content.de')!;
      deGroup.get('text')!.setValue('Some text');
      deGroup.get('title')!.setValue('');
      deGroup.updateValueAndValidity();

      expect(deGroup.get('title')!.errors).toEqual({ titleRequired: true });
    });

    it('should be valid for a language group when title is set but text is empty', () => {
      const dialog = createDialog();
      const deGroup = dialog['ruIndicationTemplateForm'].get('content.de')!;
      deGroup.get('title')!.setValue('Titel');
      deGroup.get('text')!.setValue('');
      deGroup.updateValueAndValidity();

      expect(deGroup.errors).toBeNull();
    });

    it('should be valid when both title and text are set', () => {
      const dialog = createDialog();
      const deGroup = dialog['ruIndicationTemplateForm'].get('content.de')!;
      deGroup.get('title')!.setValue('Titel');
      deGroup.get('text')!.setValue('Text');
      deGroup.updateValueAndValidity();

      expect(deGroup.errors).toBeNull();
    });

    it('should be valid when both title and text are empty', () => {
      const dialog = createDialog();
      const deGroup = dialog['ruIndicationTemplateForm'].get('content.de')!;
      deGroup.get('title')!.setValue('');
      deGroup.get('text')!.setValue('');
      deGroup.updateValueAndValidity();

      expect(deGroup.errors).toBeNull();
    });
  });
});
