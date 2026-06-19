import { Component, computed, effect, inject, input, signal } from '@angular/core';
import { toSignal } from '@angular/core/rxjs-interop';
import { FormControl, ReactiveFormsModule } from '@angular/forms';
import { SbbAutocompleteModule } from '@sbb-esta/lyne-angular/autocomplete';
import { SbbChipModule } from '@sbb-esta/lyne-angular/chip';
import { SbbFormFieldModule } from '@sbb-esta/lyne-angular/form-field';
import { CompanyService } from './company.service';
import { RecentCompaniesStore } from '../recent-companies.store';

@Component({
  selector: 'app-companies-input',
  imports: [SbbAutocompleteModule, SbbChipModule, SbbFormFieldModule, ReactiveFormsModule],
  templateUrl: './companies-input.component.html',
  styleUrl: './companies-input.component.css',
})
export class CompaniesInputComponent {
  readonly label = input<string>($localize`:@@companies_form_label:EVU`);
  readonly control = input.required<FormControl<string[]> | FormControl<string>>();
  readonly multiselect = input<boolean>(true);

  protected inputControl = new FormControl('', { nonNullable: true });
  private readonly inputValue = toSignal(this.inputControl.valueChanges, { initialValue: '' });
  private readonly searchTerm = signal<string>('');

  private readonly companyService = inject(CompanyService);
  private readonly recentCompaniesStore = inject(RecentCompaniesStore);

  protected readonly multiControl = computed(() => this.control() as FormControl<string[]>);
  protected readonly singleControl = computed(() => this.control() as FormControl<string>);

  protected readonly filteredCompanies = computed(() => {
    if (this.multiselect()) {
      return this.companyService.filterCompanies(this.inputValue(), this.multiControl().value);
    }
    return this.companyService.filterCompanies(this.searchTerm());
  });

  constructor() {
    effect(
      () => {
        if (!this.multiselect()) {
          return;
        }
        const controlValue = this.multiControl().value;
        if (controlValue.length === 0) {
          const recent = this.recentCompaniesStore.get();
          if (recent.length > 0) {
            this.multiControl().patchValue(recent, { emitEvent: false });
          }
        }
      },
      { allowSignalWrites: true },
    );
  }

  protected codeToName = (code: string) => {
    return this.companyService.getName(code) ?? code;
  };

  protected onSearchInput(event: Event): void {
    this.searchTerm.set((event.target as HTMLInputElement).value);
  }
}
