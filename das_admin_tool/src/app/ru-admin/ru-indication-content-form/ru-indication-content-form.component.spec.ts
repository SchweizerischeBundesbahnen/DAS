import { Injector, signal } from '@angular/core';
import { ComponentFixture, TestBed } from '@angular/core/testing';
import { form } from '@angular/forms/signals';
import {
  contentFormValue,
  createContentFormTree,
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
    fixture.componentRef.setInput(
      'form',
      form(signal(createContentFormTree()), { injector: TestBed.inject(Injector) }),
    );
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
        form(signal({ de: { title: '  ' } }), { injector: TestBed.inject(Injector) }),
      );
      expect(component['isLanguageEmpty']('de')).toBe(true);
    });

    it('should return false when title has content', () => {
      const formData = createContentFormTree();
      formData.de.title = 'Titel';
      fixture.componentRef.setInput(
        'form',
        form(signal(formData), { injector: TestBed.inject(Injector) }),
      );
      expect(component['isLanguageEmpty']('de')).toBe(false);
    });
  });

  describe('insertLink', () => {
    it('should insert markdown link at cursor position', () => {
      const formData = createContentFormTree();
      formData.de.text = 'Hello world';
      fixture.componentRef.setInput(
        'form',
        form(signal(formData), { injector: TestBed.inject(Injector) }),
      );

      const textarea = {
        selectionStart: 5,
        selectionEnd: 5,
        focus: vi.fn(),
        setSelectionRange: vi.fn(),
      } as unknown as HTMLTextAreaElement;
      component['insertLink']('de', textarea);

      expect(component.form().de.text().value()).toBe('Hello[](url) world');
    });

    it('should replace selected text with markdown link', () => {
      const formData = createContentFormTree();
      formData.de.text = 'Hello world';
      fixture.componentRef.setInput(
        'form',
        form(signal(formData), { injector: TestBed.inject(Injector) }),
      );

      const textarea = {
        selectionStart: 0,
        selectionEnd: 5,
        focus: vi.fn(),
        setSelectionRange: vi.fn(),
      } as unknown as HTMLTextAreaElement;
      component['insertLink']('de', textarea);

      expect(component.form().de.text().value()).toBe('[](url) world');
    });

    it('should mark field as dirty and touched', () => {
      const formData = createContentFormTree();
      fixture.componentRef.setInput(
        'form',
        form(signal(formData), { injector: TestBed.inject(Injector) }),
      );

      const textarea = {
        selectionStart: 0,
        selectionEnd: 0,
        focus: vi.fn(),
        setSelectionRange: vi.fn(),
      } as unknown as HTMLTextAreaElement;
      component['insertLink']('de', textarea);

      expect(component.form().de.text().dirty()).toBe(true);
      expect(component.form().de.text().touched()).toBe(true);
    });

    it('should do nothing when text field is not found', () => {
      fixture.componentRef.setInput(
        'form',
        form(signal({}), { injector: TestBed.inject(Injector) }),
      );
      const textarea = {
        selectionStart: 0,
        selectionEnd: 0,
        focus: vi.fn(),
        setSelectionRange: vi.fn(),
      } as unknown as HTMLTextAreaElement;
      expect(() => component['insertLink']('de', textarea)).toThrow(TypeError);
    });
  });

  describe('createContentFormTree', () => {
    it('should create a form tree with de, fr, it language trees', () => {
      const formData = createContentFormTree();
      expect(formData.de).toBeTruthy();
      expect(formData.fr).toBeTruthy();
      expect(formData.it).toBeTruthy();
    });

    it('should create language trees with title and text fields', () => {
      const formData = createContentFormTree();
      expect(formData.de.title).toBe('');
      expect(formData.de.text).toBe('');
    });

    it('should create a tree with a category', () => {
      const formData = createContentFormTree();
      expect(formData.category).toBe('');
    });

    it('should create a tree withou a category when `withCategory: false` is provided', () => {
      const formData = createContentFormTree(false);
      expect(Object.prototype.hasOwnProperty.call(formData, 'category')).toBe(false);
    });
  });
});

describe('contentFormValue', () => {
  it('should return undefined for empty languages', () => {
    const formData = createContentFormTree();
    const result = contentFormValue(formData);
    expect(result.de).toBeUndefined();
    expect(result.fr).toBeUndefined();
    expect(result.it).toBeUndefined();
  });

  it('should return language content when title is set', () => {
    const formData = createContentFormTree();
    formData.de.title = 'Titel DE';
    formData.de.text = 'Text DE';
    const result = contentFormValue(formData);
    expect(result.de).toEqual({ title: 'Titel DE', text: 'Text DE' });
  });

  it('should trim whitespace from title and text', () => {
    const formData = createContentFormTree();
    formData.fr.title = '  Titre FR  ';
    formData.fr.text = '  Texte FR  ';
    const result = contentFormValue(formData);
    expect(result.fr).toEqual({ title: 'Titre FR', text: 'Texte FR' });
  });

  it('should return text as undefined when text is empty but title is set', () => {
    const formData = createContentFormTree();
    formData.it.title = 'Titolo';
    formData.it.text = '';
    const result = contentFormValue(formData);
    expect(result.it).toEqual({ title: 'Titolo', text: undefined });
  });

  it('should return undefined when both title and text are only whitespace', () => {
    const formData = createContentFormTree();
    formData.de.title = '  ';
    formData.de.text = '  ';
    const result = contentFormValue(formData);
    expect(result.de).toBeUndefined();
  });
});
