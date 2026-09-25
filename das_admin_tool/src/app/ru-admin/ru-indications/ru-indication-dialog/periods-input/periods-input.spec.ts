import { Injector, signal } from '@angular/core';
import { ComponentFixture, TestBed } from '@angular/core/testing';
import { FieldTree, form } from '@angular/forms/signals';
import { RuIndicationPeriod } from '~ru-admin/ru-admin-api';
import { expectError } from '~src/testing/utils';
import { PeriodsInput } from './periods-input';

describe('PeriodsInput', () => {
  let component: PeriodsInput;
  let fixture: ComponentFixture<PeriodsInput>;
  let field: FieldTree<RuIndicationPeriod[]>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [PeriodsInput],
    }).compileComponents();

    fixture = TestBed.createComponent(PeriodsInput);
    component = fixture.componentInstance;
    field = form(signal<RuIndicationPeriod[]>([]), { injector: TestBed.inject(Injector) });
    fixture.componentRef.setInput('field', field);
    fixture.detectChanges();
    await fixture.whenStable();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });

  it('should set draftInvalid error when a draft value exists', () => {
    const periodForm = component['periodForm'];
    periodForm.validFrom().value.set(new Date('2026-01-10'));

    expect(expectError(periodForm(), 'draftInvalid')).toBe(true);
  });

  it('should require validTo when isRange is true', () => {
    const periodForm = component['periodForm'];
    periodForm.isRange().value.set(true);
    periodForm.validFrom().value.set(new Date('2026-01-10'));
    periodForm.validTo().value.set(null);

    expect(expectError(periodForm(), 'validToRequired')).toBe(true);
  });

  it('should report dateRangeInvalid when validFrom >= validTo', () => {
    const periodForm = component['periodForm'];
    periodForm.isRange().value.set(true);
    periodForm.validFrom().value.set(new Date('2026-01-10'));
    periodForm.validTo().value.set(new Date('2026-01-09'));

    expect(expectError(periodForm(), 'dateRangeInvalid')).toBe(true);
  });

  it('should clear errors after adding a valid single day period', () => {
    const periodForm = component['periodForm'];
    periodForm.validFrom().value.set(new Date('2026-01-10'));

    component['addPeriod']();

    expect(field().valid()).toBe(true);
    expect(field().value()).toHaveLength(1);
    expect(periodForm.validFrom().value()).toBeNull();
    expect(periodForm.isRange().value()).toBe(false);
  });
});
