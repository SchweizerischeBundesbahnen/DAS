import {Component, computed, effect, inject, input, signal} from '@angular/core';
import {toSignal} from '@angular/core/rxjs-interop';
import {FormControl, ReactiveFormsModule} from '@angular/forms';
import {SbbAutocompleteModule} from '@sbb-esta/lyne-angular/autocomplete';
import {SbbChipModule} from '@sbb-esta/lyne-angular/chip';
import {SbbFormFieldModule} from '@sbb-esta/lyne-angular/form-field';
import {SbbOptionModule} from '@sbb-esta/lyne-angular/option';
import {CompaniesApi, Company} from './companies-api.service';

@Component({
  selector: 'app-companies-input',
  imports: [
    SbbOptionModule,
    SbbAutocompleteModule,
    SbbChipModule,
    SbbFormFieldModule,
    ReactiveFormsModule,
  ],
  templateUrl: './companies-input.component.html',
  styleUrl: './companies-input.component.css',
})
export class CompaniesInputComponent {
  label = input<string>($localize`:@@companies_form_label:Gültig für`);
  control = input.required<FormControl<string[]>>();

  inputControl = new FormControl('', {nonNullable: true});
  private readonly companiesApi = inject(CompaniesApi);
  private readonly companies = signal<Company[]>([]);
  private readonly inputValue = toSignal(this.inputControl.valueChanges, {initialValue: ''});
  protected readonly filteredCompanies = computed(() => {
    const allCompanies = this.companies().filter((company) => !this.control().value.includes(company.code));
    if (typeof this.inputValue() !== 'string')
      return allCompanies;
    const query = this.inputValue().trim().toLowerCase();

    if (!query) {
      return allCompanies;
    }

    const matching = allCompanies.filter((company) => {
      const code = company.code.toLowerCase();
      const name = company.name.toLowerCase();
      return code.includes(query) || name.includes(query);
    });

    return this.sortByRelevance(matching, query);
  });

  constructor() {
    effect(() => {
      if (!this.companiesApi.companies.hasValue()) {
        return;
      }

      this.companies.set(this.companiesApi.companies.value().data);
    });
  }

  protected codeToName = (code: string) => {
    return this.companies().find((company) => company.code === code)?.name ?? code;
  }

  private sortByRelevance(candidates: Company[], query: string): Company[] {
    return [...candidates].sort((a, b) => {
      const aCode = a.code.toLowerCase();
      const bCode = b.code.toLowerCase();
      const aName = a.name.toLowerCase();
      const bName = b.name.toLowerCase();

      const aRank = Math.min(this.rank(query, aCode), this.rank(query, aName));
      const bRank = Math.min(this.rank(query, bCode), this.rank(query, bName));

      if (aRank !== bRank) {
        return aRank - bRank;
      }

      return aName.localeCompare(bName);
    });
  }

  private rank(query: string, candidate: string): number {
    if (candidate === query) {
      return 0;
    }
    if (candidate.startsWith(query)) {
      return 1;
    }
    if (candidate.includes(query)) {
      return 2;
    }
    return 3;
  }
}
