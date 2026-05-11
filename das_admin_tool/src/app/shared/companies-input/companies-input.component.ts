import {Component, computed, effect, forwardRef, inject, input, signal} from '@angular/core';
import {toSignal} from '@angular/core/rxjs-interop';
import {
  ControlValueAccessor,
  FormControl,
  NG_VALUE_ACCESSOR,
  ReactiveFormsModule
} from '@angular/forms';
import {SbbAutocompleteModule} from '@sbb-esta/lyne-angular/autocomplete';
import {SbbChipModule} from '@sbb-esta/lyne-angular/chip';
import {SbbFormFieldModule} from '@sbb-esta/lyne-angular/form-field';
import {SbbOptionModule} from '@sbb-esta/lyne-angular/option';
import {CompaniesApi, Company} from './companies-api.service';

@Component({
  selector: 'app-companies-input',
  providers: [{
    provide: NG_VALUE_ACCESSOR,
    useExisting: forwardRef(() => CompaniesInputComponent),
    multi: true,
  }],
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
export class CompaniesInputComponent implements ControlValueAccessor {
  label = input<string>($localize`:@@companies_form_label:Gültig für`);
  required = input<boolean>(false);

  inputControl = new FormControl('', {nonNullable: true});
  protected readonly selectedCompanies = signal<Company[]>([]);
  private readonly companiesApi = inject(CompaniesApi);
  private readonly companies = signal<Company[]>([]);
  private readonly selectedCompanyCodes = signal<string[]>([]);
  private readonly touched = signal(false);
  protected readonly showError = computed(() => {
    return this.touched() && this.required() && this.selectedCompanies().length === 0;
  });
  private readonly inputValue = toSignal(this.inputControl.valueChanges, {initialValue: ''});
  protected readonly filteredCompanies = computed(() => {
    const allCompanies = this.companies().filter((company) => !this.selectedCompanies().includes(company));
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
    effect(() => {
      this.selectedCompanies.set(this.companies().filter((company) => this.selectedCompanyCodes().includes(company.code)));
    });
  }

  writeValue(value: string[] | null): void {
    this.selectedCompanyCodes.set(value ?? []);
  }

  registerOnChange(fn: (value: string[]) => void): void {
    this.onChange = fn;
  }

  registerOnTouched(fn: () => void): void {
    this.onTouched = fn;
  }

  setDisabledState(): void {
    // implement when needed
  }

  protected markAsTouched(): void {
    if (this.touched()) {
      return;
    }

    this.touched.set(true);
    this.onTouched();
  }

  protected selectOption(company: Company) {
    this.inputControl.setValue('');
    this.selectedCompanyCodes.set([...this.selectedCompanyCodes(), company.code])
    this.onChange(this.selectedCompanyCodes());
    this.markAsTouched();
  }

  protected remove(company: Company) {
    this.selectedCompanyCodes.set(this.selectedCompanyCodes().filter((code) => code !== company.code));
    this.onChange(this.selectedCompanyCodes());
    this.markAsTouched();
  }

  private onChange: (value: string[]) => void = () => undefined;

  private onTouched: () => void = () => undefined;

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
