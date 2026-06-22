import { NgTemplateOutlet } from '@angular/common';
import { Component, computed, input, signal, viewChild, viewChildren } from '@angular/core';
import { ReactiveFormsModule } from '@angular/forms';
import { SbbActionGroup } from '@sbb-esta/lyne-angular/action-group';
import { SbbButtonModule } from '@sbb-esta/lyne-angular/button';
import { SbbDialogModule } from '@sbb-esta/lyne-angular/dialog';
import { SbbStep, SbbStepper, SbbStepperModule } from '@sbb-esta/lyne-angular/stepper';
import { SbbTitleModule } from '@sbb-esta/lyne-angular/title';
import { SbbStepChangeEvent } from '@sbb-esta/lyne-elements/stepper.js';
import { Audit } from '../audit/audit';
import { Auditable } from '../audit/auditable';

@Component({
	selector: 'app-base-dialog',
	imports: [
		NgTemplateOutlet,
		SbbStepperModule,
		SbbTitleModule,
		ReactiveFormsModule,
		SbbButtonModule,
		SbbDialogModule,
		SbbActionGroup,
		Audit,
	],
	templateUrl: './base-dialog.component.html',
	styleUrl: './base-dialog.component.css',
})
export class BaseDialog {
	readonly dialogTitle = input.required<string>();
	readonly stepLabel = input.required<string>();
	readonly data = input<Auditable>();
	readonly saveDisabled = input.required<boolean>();
	readonly dialogClose = input.required();
	readonly isEdit = computed(() => !!this.data());
	readonly steps = viewChildren(SbbStep);
	protected readonly stepchange = signal<SbbStepChangeEvent | undefined>(undefined);
	protected readonly isLastStep = computed(() => {
		const selectedIndex = this.stepchange()?.selectedIndex;
		if (selectedIndex === undefined) return true;
		const lastStep = this.steps().length - 1;
		return selectedIndex === lastStep;
	});
	protected readonly isStepDisabled = computed(() => {
		const step = this.stepchange()?.selectedIndex;
		return step === 0 ? this.saveDisabled() : false;
	});
	private readonly stepper = viewChild.required(SbbStepper);

	next(): void {
		this.stepper().next();
	}
}
