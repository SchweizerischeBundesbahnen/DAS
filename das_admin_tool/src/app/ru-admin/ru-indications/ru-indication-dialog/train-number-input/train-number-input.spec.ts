import {ComponentFixture, TestBed} from '@angular/core/testing';
import {FormControl, FormGroup} from '@angular/forms';
import {TrainNumberInput} from './train-number-input';
import {RuIndicationTrainNumberFilter} from '../../../ru-admin-api';

describe('TrainNumberInput', () => {
  let component: TrainNumberInput;
  let fixture: ComponentFixture<TrainNumberInput>;
  let control: FormControl<RuIndicationTrainNumberFilter[]>;
  let parentForm: FormGroup;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [TrainNumberInput],
    }).compileComponents();

    fixture = TestBed.createComponent(TrainNumberInput);
    component = fixture.componentInstance;
    control = new FormControl<RuIndicationTrainNumberFilter[]>([], {nonNullable: true});
    // Wrap in a parent FormGroup so parent?.valueChanges fires (mirrors the real ru indication form)
    parentForm = new FormGroup({
      operationalTrainNumberFilters: control,
      companies: new FormControl<string[]>([], {nonNullable: true}),
    });
    fixture.componentRef.setInput('control', control);
    fixture.detectChanges();
    await fixture.whenStable();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });

  it('should set required error when switching to filtered mode with no committed filters', () => {
    component['trainFilterModeControl'].setValue('filtered');

    expect(control.hasError('required')).toBe(true);
    expect(control.valid).toBe(false);
  });

  it('should set draftInvalid error when there is uncommitted text in the input', () => {
    component['trainFilterModeControl'].setValue('filtered');
    component['trainNumberFilterForm'].controls.trainNumber.setValue('100');

    expect(control.hasError('draftInvalid')).toBe(true);
  });

  it('should clear all errors after a filter is successfully added', () => {
    component['trainFilterModeControl'].setValue('filtered');
    component['trainNumberFilterForm'].controls.trainNumber.setValue('100');
    component['addTrainNumberFilter']();

    expect(control.valid).toBe(true);
    expect(control.value).toHaveLength(1);
  });

  it('should keep required error when a sibling control in the parent form changes (original bug)', () => {
    component['trainFilterModeControl'].setValue('filtered');
    expect(control.hasError('required')).toBe(true);

    // Simulate user changing the company — triggers parent valueChanges
    parentForm.controls['companies'].setValue(['1085']);

    expect(control.hasError('required')).toBe(true);
    expect(control.valid).toBe(false);
  });

  it('should reset to all mode and clear errors when switching back from filtered to all', () => {
    component['trainFilterModeControl'].setValue('filtered');
    expect(control.valid).toBe(false);

    component['trainFilterModeControl'].setValue('all');

    expect(control.valid).toBe(true);
    expect(control.errors).toBeNull();
    expect(control.value).toEqual([]);
  });

  it('should initialize in filtered mode when control already has committed filters', async () => {
    const prefilledFixture = TestBed.createComponent(TrainNumberInput);
    const prefilled = new FormControl<RuIndicationTrainNumberFilter[]>(
      [{expression: '100', parity: 'ANY'}],
      {nonNullable: true},
    );
    prefilledFixture.componentRef.setInput('control', prefilled);
    prefilledFixture.detectChanges();
    await prefilledFixture.whenStable();

    expect(prefilledFixture.componentInstance['trainFilterModeControl'].value).toBe('filtered');
  });
});
