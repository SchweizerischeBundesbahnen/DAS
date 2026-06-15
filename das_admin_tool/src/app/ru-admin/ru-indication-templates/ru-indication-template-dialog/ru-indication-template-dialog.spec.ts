import {TestBed} from '@angular/core/testing';
import {RuIndicationTemplateDialog} from './ru-indication-template-dialog';
import {SBB_OVERLAY_DATA} from '@sbb-esta/lyne-angular/core/overlay';
import {RuIndicationTemplate} from '../../ru-admin-api';

function createDialog(data?: RuIndicationTemplate): RuIndicationTemplateDialog {
  TestBed.configureTestingModule({
    providers: [
      RuIndicationTemplateDialog,
      {provide: SBB_OVERLAY_DATA, useValue: data ?? null},
    ],
  });
  return TestBed.inject(RuIndicationTemplateDialog);
}

describe('RuIndicationTemplateDialog', () => {
  beforeEach(() => vi.clearAllMocks());

  describe('oneLanguageRequired validator', () => {
    it('should be invalid when all language titles are empty', () => {
      const dialog = createDialog();
      expect(dialog['ruIndicationTemplateForm'].get('content')!.errors).toEqual({oneLanguageRequired: true});
    });

    it('should be valid when at least de title is filled', () => {
      const dialog = createDialog();
      dialog['ruIndicationTemplateForm'].get('content.de.title')!.setValue('Titel');
      expect(dialog['ruIndicationTemplateForm'].get('content')!.errors).toBeNull();
    });

    it('should be valid when only fr title is filled', () => {
      const dialog = createDialog();
      dialog['ruIndicationTemplateForm'].get('content.fr.title')!.setValue('Titre');
      expect(dialog['ruIndicationTemplateForm'].get('content')!.errors).toBeNull();
    });

    it('should be valid when only it title is filled', () => {
      const dialog = createDialog();
      dialog['ruIndicationTemplateForm'].get('content.it.title')!.setValue('Titolo');
      expect(dialog['ruIndicationTemplateForm'].get('content')!.errors).toBeNull();
    });

    it('should be invalid when titles contain only whitespace', () => {
      const dialog = createDialog();
      dialog['ruIndicationTemplateForm'].get('content.de.title')!.setValue('   ');
      expect(dialog['ruIndicationTemplateForm'].get('content')!.errors).toEqual({oneLanguageRequired: true});
    });
  });

  describe('titleRequired validator', () => {
    it('should be invalid for a language group when text is set but title is empty', () => {
      const dialog = createDialog();
      const deGroup = dialog['ruIndicationTemplateForm'].get('content.de')!;
      deGroup.get('text')!.setValue('Some text');
      deGroup.get('title')!.setValue('');
      deGroup.updateValueAndValidity();

      expect(deGroup.get('title')!.errors).toEqual({titleRequired: true});
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


