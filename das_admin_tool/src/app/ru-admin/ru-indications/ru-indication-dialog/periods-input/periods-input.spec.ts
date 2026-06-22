import { ComponentFixture, TestBed } from '@angular/core/testing';
import { FormControl } from '@angular/forms';
import { RuIndicationPeriod } from '~ru-admin/ru-admin-api';
import { PeriodsInput } from './periods-input';

describe('PeriodsInput', () => {
	let component: PeriodsInput;
	let fixture: ComponentFixture<PeriodsInput>;
	let control: FormControl<RuIndicationPeriod[]>;

	beforeEach(async () => {
		await TestBed.configureTestingModule({ imports: [PeriodsInput] }).compileComponents();

		fixture = TestBed.createComponent(PeriodsInput);
		component = fixture.componentInstance;
		control = new FormControl<RuIndicationPeriod[]>([], { nonNullable: true });
		fixture.componentRef.setInput('control', control);
		fixture.detectChanges();
		await fixture.whenStable();
	});

	it('should create', () => {
		expect(component).toBeTruthy();
	});

	it('should set draftInvalid error when a draft value exists', () => {
		component['periodForm'].controls.validFrom.setValue(new Date('2026-01-10'));

		expect(control.hasError('draftInvalid')).toBe(true);
	});

	it('periodFormValidator: should require validTo when isRange is true', () => {
		const pf = component['periodForm'];
		pf.controls.isRange.setValue(true);
		pf.controls.validFrom.setValue(new Date('2026-01-10'));
		pf.controls.validTo.setValue(null);
		pf.updateValueAndValidity();

		expect(pf.errors).toEqual({ validToRequired: true });
	});

	it('periodFormValidator: should report dateRangeInvalid when validFrom >= validTo', () => {
		const pf = component['periodForm'];
		pf.controls.isRange.setValue(true);
		pf.controls.validFrom.setValue(new Date('2026-01-10'));
		pf.controls.validTo.setValue(new Date('2026-01-09'));
		pf.updateValueAndValidity();

		expect(pf.errors).toEqual({ dateRangeInvalid: true });
	});

	it('periodFormValidator: should be valid when isRange is false even if validTo is missing', () => {
		const pf = component['periodForm'];
		pf.controls.isRange.setValue(false);
		pf.controls.validFrom.setValue(new Date('2026-01-10'));
		pf.controls.validTo.setValue(null);
		pf.updateValueAndValidity();

		expect(pf.errors).toBeNull();
	});

	it('should clear errors after adding a valid single day period', () => {
		component['periodForm'].controls.validFrom.setValue(new Date('2026-01-10'));

		component['addPeriod']();

		expect(control.valid).toBe(true);
		expect(control.value).toHaveLength(1);
		expect(component['periodForm'].controls.validFrom.value).toBeNull();
		expect(component['periodForm'].controls.isRange.value).toBe(false);
	});
});
