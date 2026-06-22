import { ComponentFixture, TestBed } from '@angular/core/testing';
import { FormControl, FormGroup } from '@angular/forms';
import {
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
        new FormGroup({ de: new FormGroup({ title: new FormControl(' ') }) }),
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
});
