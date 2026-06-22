import { DatePipe } from '@angular/common';
import { Component, computed, inject, input } from '@angular/core';
import { toSignal } from '@angular/core/rxjs-interop';
import { FormControl, ReactiveFormsModule } from '@angular/forms';
import { SbbAutocompleteModule } from '@sbb-esta/lyne-angular/autocomplete';
import { SbbChipModule } from '@sbb-esta/lyne-angular/chip';
import { SbbFormFieldModule } from '@sbb-esta/lyne-angular/form-field';
import { SbbOptionModule } from '@sbb-esta/lyne-angular/option';
import { LocationService } from './location.service';

@Component({
	selector: 'app-locations-input',
	imports: [
		SbbOptionModule,
		SbbAutocompleteModule,
		SbbChipModule,
		SbbFormFieldModule,
		ReactiveFormsModule,
		DatePipe,
	],
	templateUrl: './locations-input.component.html',
	styleUrl: './locations-input.component.css',
})
export class LocationsInput {
	readonly label = input<string>($localize`:@@locations_form_label:Betriebspunkt`);
	readonly control = input<FormControl<string[]>>(
		new FormControl<string[]>([], { nonNullable: true }),
	);

	inputControl = new FormControl('', { nonNullable: true });
	private readonly locationService = inject(LocationService);
	private readonly inputValue = toSignal(this.inputControl.valueChanges, { initialValue: '' });
	readonly filteredLocations = computed(() => {
		return this.locationService.filterLocations(this.inputValue(), this.control().value);
	});

	protected locationToName = (reference: string) => {
		return this.locationService.getLocation(reference)?.primaryLocationName ?? reference;
	};
}
