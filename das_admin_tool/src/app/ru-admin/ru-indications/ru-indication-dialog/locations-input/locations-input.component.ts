import { DatePipe } from '@angular/common';
import { Component, computed, inject, input, signal } from '@angular/core';
import { FieldTree, form, FormField } from '@angular/forms/signals';
import { SbbAutocompleteModule } from '@sbb-esta/lyne-angular/autocomplete';
import { SbbChipModule } from '@sbb-esta/lyne-angular/chip';
import { SbbFormFieldModule } from '@sbb-esta/lyne-angular/form-field';
import { SbbOptionModule } from '@sbb-esta/lyne-angular/option';
import { LocationService } from './location.service';

@Component({
  selector: 'app-locations-input',
  imports: [
    FormField,
    SbbOptionModule,
    SbbAutocompleteModule,
    SbbChipModule,
    SbbFormFieldModule,
    DatePipe,
  ],
  templateUrl: './locations-input.component.html',
  styleUrl: './locations-input.component.css',
})
export class LocationsInput {
  private readonly locationService = inject(LocationService);

  readonly label = input<string>($localize`:@@locations_form_label:Betriebspunkt`);
  readonly field = input.required<FieldTree<string[]>>();

  protected readonly inputField = form(signal(''));

  readonly filteredLocations = computed(() =>
    this.locationService.filterLocations(this.inputField().value(), this.field()().value()),
  );

  protected locationToName = (reference: string) =>
    this.locationService.getLocation(reference)?.primaryLocationName ?? reference;
}
