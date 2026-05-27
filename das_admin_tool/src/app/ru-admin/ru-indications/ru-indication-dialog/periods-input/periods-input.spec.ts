import {ComponentFixture, TestBed} from '@angular/core/testing';
import {FormControl, FormGroup} from '@angular/forms';
import {RuIndicationPeriod} from '../../../ru-admin-api';
import {PeriodsInput} from './periods-input';

describe('PeriodsInput', () => {
  let component: PeriodsInput;
  let fixture: ComponentFixture<PeriodsInput>;
  let control: FormControl<RuIndicationPeriod[]>;
  let parentForm: FormGroup;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [PeriodsInput]
    }).compileComponents();

    fixture = TestBed.createComponent(PeriodsInput);
    component = fixture.componentInstance;
    control = new FormControl<RuIndicationPeriod[]>([], {nonNullable: true});
    parentForm = new FormGroup({
      periods: control,
      companies: new FormControl<string[]>([], {nonNullable: true}),
    });
    fixture.componentRef.setInput('control', control);
    fixture.detectChanges();
    await fixture.whenStable();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });

  it('should set required error when no committed periods exist', () => {
    expect(control.hasError('required')).toBe(true);
    expect(control.valid).toBe(false);
  });

  it('should set draftInvalid error when a draft value exists', () => {
    component['periodForm'].controls.validFrom.setValue(new Date('2026-01-10'));

    expect(control.hasError('draftInvalid')).toBe(true);
  });

  it('should clear errors after adding a valid single day period', () => {
    component['periodForm'].controls.validFrom.setValue(new Date('2026-01-10'));

    component['addPeriod']();

    expect(control.valid).toBe(true);
    expect(control.value).toHaveLength(1);
  });

  it('should keep required error when a sibling control in parent form changes', () => {
    expect(control.hasError('required')).toBe(true);

    parentForm.controls['companies'].setValue(['1085']);

    expect(control.hasError('required')).toBe(true);
    expect(control.valid).toBe(false);
  });
});
