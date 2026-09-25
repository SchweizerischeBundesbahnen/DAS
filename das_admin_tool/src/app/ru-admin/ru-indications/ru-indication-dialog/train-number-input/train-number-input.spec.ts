import { Injector, signal } from '@angular/core';
import { ComponentFixture, TestBed } from '@angular/core/testing';
import { FieldTree, form } from '@angular/forms/signals';
import { expectError } from '~src/testing/utils';
import { OperationalTrainNumber } from '../ru-indication-dialog.component';
import { displayTrainNumberFilter, TrainNumberInput } from './train-number-input';

describe('TrainNumberInput', () => {
  let component: TrainNumberInput;
  let fixture: ComponentFixture<TrainNumberInput>;
  let formField: FieldTree<OperationalTrainNumber>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [TrainNumberInput],
    }).compileComponents();

    fixture = TestBed.createComponent(TrainNumberInput);
    component = fixture.componentInstance;
    formField = form(signal<OperationalTrainNumber>({ mode: 'all', filters: [] }), {
      injector: TestBed.inject(Injector),
    });
    fixture.componentRef.setInput('form', formField);
    fixture.detectChanges();
    await fixture.whenStable();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });

  it('should set draftInvalid error when there is uncommitted text in the input', () => {
    const trainNumberForm = component['trainNumberForm'];
    trainNumberForm.trainNumber().value.set('100');

    expect(expectError(trainNumberForm(), 'draftInvalid')).toBe(true);
  });

  it('should clear all errors after a filter is successfully added', () => {
    const trainNumberForm = component['trainNumberForm'];
    trainNumberForm.trainNumber().value.set('100');

    component['addTrainNumberFilter']();

    expect(formField.filters().valid()).toBe(true);
    expect(formField.filters().value()).toHaveLength(1);
    expect(trainNumberForm.trainNumber().value()).toBe('');
  });

  it('train number validator: should mark invalid formats and ranges', () => {
    const trainNumberForm = component['trainNumberForm'];
    trainNumberForm.trainNumber().value.set('abc');
    expect(expectError(trainNumberForm.trainNumber(), 'invalidFormat')).toBe(true);

    trainNumberForm.trainNumber().value.set('10-5');
    expect(expectError(trainNumberForm.trainNumber(), 'rangeInvalid')).toBe(true);

    trainNumberForm.trainNumber().value.set('100');
    expect(trainNumberForm.trainNumber().errors()).toEqual([]);

    trainNumberForm.trainNumber().value.set('100-200');
    expect(trainNumberForm.trainNumber().errors()).toEqual([]);
  });

  it('displayTrainNumberFilter should include parity label when set', () => {
    const even = displayTrainNumberFilter({ expression: '100', parity: 'EVEN' });
    const odd = displayTrainNumberFilter({ expression: '100', parity: 'ODD' });

    expect(even).toContain('100');
    expect(even).toContain('Gerade');
    expect(odd).toContain('Ungerade');
  });
});
