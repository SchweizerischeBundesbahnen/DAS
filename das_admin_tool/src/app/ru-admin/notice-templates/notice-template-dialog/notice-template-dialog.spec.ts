import {TestBed} from '@angular/core/testing';
import {NoticeTemplateDialog} from './notice-template-dialog';
import {SBB_OVERLAY_DATA} from '@sbb-esta/lyne-angular/core/overlay';
import {NoticeTemplate} from '../../ru-admin-api';

function createDialog(data?: NoticeTemplate): NoticeTemplateDialog {
  TestBed.configureTestingModule({
    providers: [
      NoticeTemplateDialog,
      {provide: SBB_OVERLAY_DATA, useValue: data ?? null},
    ],
  });
  return TestBed.inject(NoticeTemplateDialog);
}

const existingTemplate: NoticeTemplate = {
  id: 1,
  category: 'Kategorie1',
  de: {title: 'Titel', text: 'Text'},
};

describe('NoticeTemplateDialog', () => {
  beforeEach(() => vi.clearAllMocks());

  describe('oneLanguageRequired validator', () => {
    it('should be invalid when all language titles are empty', () => {
      const dialog = createDialog();
      expect(dialog['noticeTemplateForm'].errors).toEqual({oneLanguageRequired: true});
    });

    it('should be valid when at least de title is filled', () => {
      const dialog = createDialog();
      dialog['noticeTemplateForm'].get('de.title')!.setValue('Titel');
      expect(dialog['noticeTemplateForm'].errors).toBeNull();
    });

    it('should be valid when only fr title is filled', () => {
      const dialog = createDialog();
      dialog['noticeTemplateForm'].get('fr.title')!.setValue('Titre');
      expect(dialog['noticeTemplateForm'].errors).toBeNull();
    });

    it('should be valid when only it title is filled', () => {
      const dialog = createDialog();
      dialog['noticeTemplateForm'].get('it.title')!.setValue('Titolo');
      expect(dialog['noticeTemplateForm'].errors).toBeNull();
    });

    it('should be invalid when titles contain only whitespace', () => {
      const dialog = createDialog();
      dialog['noticeTemplateForm'].get('de.title')!.setValue('   ');
      expect(dialog['noticeTemplateForm'].errors).toEqual({oneLanguageRequired: true});
    });
  });

  describe('titleRequired validator', () => {
    it('should be invalid for a language group when text is set but title is empty', () => {
      const dialog = createDialog();
      const deGroup = dialog['noticeTemplateForm'].get('de')!;
      deGroup.get('text')!.setValue('Some text');
      deGroup.get('title')!.setValue('');
      deGroup.updateValueAndValidity();

      expect(deGroup.errors).toEqual({titleRequired: true});
      expect(deGroup.get('title')!.errors).toEqual({titleRequired: true});
    });

    it('should be valid when both title and text are set', () => {
      const dialog = createDialog();
      const deGroup = dialog['noticeTemplateForm'].get('de')!;
      deGroup.get('title')!.setValue('Titel');
      deGroup.get('text')!.setValue('Text');
      deGroup.updateValueAndValidity();

      expect(deGroup.errors).toBeNull();
    });

    it('should be valid when both title and text are empty', () => {
      const dialog = createDialog();
      const deGroup = dialog['noticeTemplateForm'].get('de')!;
      deGroup.get('title')!.setValue('');
      deGroup.get('text')!.setValue('');
      deGroup.updateValueAndValidity();

      expect(deGroup.errors).toBeNull();
    });
  });

  describe('isLanguageEmpty', () => {
    it('should return true when title is empty', () => {
      const dialog = createDialog();
      expect(dialog.isLanguageEmpty('de')).toBe(true);
    });

    it('should return true when title is only whitespace', () => {
      const dialog = createDialog();
      dialog['noticeTemplateForm'].get('de.title')!.setValue('   ');
      expect(dialog.isLanguageEmpty('de')).toBe(true);
    });

    it('should return false when title has content', () => {
      const dialog = createDialog(existingTemplate);
      expect(dialog.isLanguageEmpty('de')).toBe(false);
    });
  });
});


