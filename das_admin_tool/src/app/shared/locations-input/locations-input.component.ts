import {Component, computed, inject} from '@angular/core';
import {SbbOptionModule} from '@sbb-esta/lyne-angular/option';
import {SbbAutocompleteModule} from '@sbb-esta/lyne-angular/autocomplete';
import {SbbChipModule} from '@sbb-esta/lyne-angular/chip';
import {SbbFormFieldModule} from '@sbb-esta/lyne-angular/form-field';
import {FormControl, ReactiveFormsModule} from '@angular/forms';
import {Location, LocationsApi} from './locations-api.service';
import {toSignal} from '@angular/core/rxjs-interop';
import {DatePipe} from "@angular/common";

@Component({
  selector: 'app-locations-input',
  imports: [SbbOptionModule, SbbAutocompleteModule, SbbChipModule, SbbFormFieldModule, ReactiveFormsModule, DatePipe],
  templateUrl: './locations-input.component.html',
  styleUrl: './locations-input.component.css',
})
export class LocationsInput {

  inputControl = new FormControl('');
  private readonly locationsApi = inject(LocationsApi);
  private readonly inputValue = toSignal(this.inputControl.valueChanges, {initialValue: ''});
  filteredLocations = computed(() => {
    const query = this.inputValue();
    const all = this.locationsApi.locations.value()?.data ?? [];
    if (query && query.length >= 2) {
      return this.filterLocations(query, all);
    }
    return [];
  });

  private filterLocations(query: string, all: Location[]) {
    const q = query.toLowerCase();
    const includesQuery = all.filter(loc =>
      (loc.primaryLocationName?.toLowerCase().includes(q)) ||
      (loc.locationAbbreviation?.toLowerCase().includes(q))
    );
    return this.sortByRelevance(includesQuery, q);
  }

  private sortByRelevance(includesQuery: Location[], q: string) {
    return includesQuery.sort((a, b) => {
      const aName = a.primaryLocationName?.toLowerCase() ?? '';
      const bName = b.primaryLocationName?.toLowerCase() ?? '';
      const aAbbr = a.locationAbbreviation?.toLowerCase() ?? '';
      const bAbbr = b.locationAbbreviation?.toLowerCase() ?? '';

      const aRank = Math.min(this.rank(q, aName), this.rank(q, aAbbr));
      const bRank = Math.min(this.rank(q, bName), this.rank(q, bAbbr));
      if (aRank !== bRank) return aRank - bRank;
      return aName.localeCompare(bName);
    });
  }

  private rank(query: string, str: string): number {
    if (str === query) return 0; // exact
    if (str.startsWith(query)) return 1; // prefix
    if (str.includes(query)) return 2; // substring
    return 3;
  }
}
