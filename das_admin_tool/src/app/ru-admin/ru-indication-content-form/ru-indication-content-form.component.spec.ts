import { ComponentFixture, TestBed } from '@angular/core/testing';
import { FormControl, FormGroup } from '@angular/forms';
import {
  contentFormValue,
  createContentFormGroup,
  RuIndicationContentForm,
} from './ru-indication-content-form.component';

describe('RuIndicationContentForm', () => {
  let component: RuIndicationContentForm;
  let fixture: ComponentFixture<RuIndicationContentForm>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [RuIndicationContentForm],
    }).compileComponents();

    fixture = TestBed.createComponent(RuIndicationContentForm);
    component = fixture.componentInstance;
    fixture.componentRef.setInput('form', createContentFormGroup());
    await fixture.whenStable();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });

  describe('isLanguageEmpty', () => {
    it('should return true when title is empty', () => {
      expect(component['isLanguageEmpty']('de')).toBe(true);
    });

    it('should return true when title is only whitespace', () => {
      fixture.componentRef.setInput(
        'form',
        new FormGroup({ de: new FormGroup({ title: new FormControl('   ') }) }),
      );
      expect(component['isLanguageEmpty']('de')).toBe(true);
    });

    it('should return false when title has content', () => {
      const form = createContentFormGroup();
      form.get('de')!.get('title')!.setValue('Titel');
      fixture.componentRef.setInput('form', form);
      expect(component['isLanguageEmpty']('de')).toBe(false);
    });
  });

  describe('insertLink', () => {
    it('should insert markdown link at cursor position', () => {
      const form = createContentFormGroup();
      form.get('de.text')!.setValue('Hello world');
      fixture.componentRef.setInput('form', form);

      const textarea = {
        selectionStart: 5,
        selectionEnd: 5,
        focus: vi.fn(),
        setSelectionRange: vi.fn(),
      } as unknown as HTMLTextAreaElement;
      component['insertLink']('de', textarea);

      expect(form.get('de.text')!.value).toBe('Hello[](url) world');
    });

    it('should replace selected text with markdown link', () => {
      const form = createContentFormGroup();
      form.get('de.text')!.setValue('Hello world');
      fixture.componentRef.setInput('form', form);

      const textarea = {
        selectionStart: 0,
        selectionEnd: 5,
        focus: vi.fn(),
        setSelectionRange: vi.fn(),
      } as unknown as HTMLTextAreaElement;
      component['insertLink']('de', textarea);

      expect(form.get('de.text')!.value).toBe('[](url) world');
    });

    it('should mark control as dirty and touched', () => {
      const form = createContentFormGroup();
      fixture.componentRef.setInput('form', form);

      const textarea = {
        selectionStart: 0,
        selectionEnd: 0,
        focus: vi.fn(),
        setSelectionRange: vi.fn(),
      } as unknown as HTMLTextAreaElement;
      component['insertLink']('de', textarea);

      expect(form.get('de.text')!.dirty).toBe(true);
      expect(form.get('de.text')!.touched).toBe(true);
    });

    it('should do nothing when text control is not found', () => {
      fixture.componentRef.setInput('form', new FormGroup({}));
      const textarea = {
        selectionStart: 0,
        selectionEnd: 0,
        focus: vi.fn(),
        setSelectionRange: vi.fn(),
      } as unknown as HTMLTextAreaElement;
      // should not throw
      component['insertLink']('de', textarea);
      expect(component.form().get(`de.text`)).toBeNull();
    });
  });

  describe('validators', () => {
    it('should require text when title is set for RU indications', () => {
      const form = createContentFormGroup();
      const deGroup = form.get('de') as FormGroup;
      deGroup.get('title')!.setValue('Titel');
      deGroup.get('text')!.setValue('');
      deGroup.updateValueAndValidity();

      expect(deGroup.get('text')!.errors).toEqual({ languageRequired: true });
    });
  });
});

describe('createContentFormGroup', () => {
  it('should create a form group with de, fr, it language groups', () => {
    const form = createContentFormGroup();
    expect(form.get('de')).toBeTruthy();
    expect(form.get('fr')).toBeTruthy();
    expect(form.get('it')).toBeTruthy();
  });

  it('should create language groups with title and text controls', () => {
    const form = createContentFormGroup();
    expect(form.get('de.title')).toBeTruthy();
    expect(form.get('de.text')).toBeTruthy();
  });

  it('should apply languageRequired validator by default (text required)', () => {
    const form = createContentFormGroup();
    form.get('de.title')!.setValue('A title');
    form.get('de')!.updateValueAndValidity();
    expect(form.get('de.text')!.errors).toEqual({ languageRequired: true });
  });

  it('should apply titleRequired validator when textRequired is false', () => {
    const form = createContentFormGroup({ textRequired: false });
    form.get('de.text')!.setValue('Some text');
    form.get('de')!.updateValueAndValidity();
    expect(form.get('de.title')!.errors).toEqual({ titleRequired: true });
  });

  it('should have oneLanguageRequired group validator', () => {
    const form = createContentFormGroup();
    form.updateValueAndValidity();
    expect(form.errors).toEqual({ oneLanguageRequired: true });
  });

  it('should be valid when at least one language has content', () => {
    const form = createContentFormGroup();
    form.get('de.title')!.setValue('Title');
    form.get('de.text')!.setValue('Text');
    form.updateValueAndValidity();
    expect(form.errors).toBeNull();
  });
});

describe('contentFormValue', () => {
  it('should return undefined for empty languages', () => {
    const form = createContentFormGroup();
    const result = contentFormValue(form);
    expect(result.de).toBeUndefined();
    expect(result.fr).toBeUndefined();
    expect(result.it).toBeUndefined();
  });

  it('should return language content when title is set', () => {
    const form = createContentFormGroup();
    form.get('de.title')!.setValue('Titel DE');
    form.get('de.text')!.setValue('Text DE');
    const result = contentFormValue(form);
    expect(result.de).toEqual({ title: 'Titel DE', text: 'Text DE' });
  });

  it('should trim whitespace from title and text', () => {
    const form = createContentFormGroup();
    form.get('fr.title')!.setValue('  Titre FR  ');
    form.get('fr.text')!.setValue('  Texte FR  ');
    const result = contentFormValue(form);
    expect(result.fr).toEqual({ title: 'Titre FR', text: 'Texte FR' });
  });

  it('should return text as undefined when text is empty but title is set', () => {
    const form = createContentFormGroup();
    form.get('it.title')!.setValue('Titolo');
    form.get('it.text')!.setValue('');
    const result = contentFormValue(form);
    expect(result.it).toEqual({ title: 'Titolo', text: undefined });
  });

  it('should return undefined when both title and text are only whitespace', () => {
    const form = createContentFormGroup();
    form.get('de.title')!.setValue('   ');
    form.get('de.text')!.setValue('   ');
    const result = contentFormValue(form);
    expect(result.de).toBeUndefined();
  });
});
