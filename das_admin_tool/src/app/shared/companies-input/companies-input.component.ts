import { Component, computed, effect, inject, input } from '@angular/core';
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
  readonly control = input.required<FormControl<string[]>>();

  protected inputControl = new FormControl('', { nonNullable: true });
  private readonly inputValue = toSignal(this.inputControl.valueChanges, { initialValue: '' });

  private readonly companyService = inject(CompanyService);
  private readonly recentCompaniesStore = inject(RecentCompaniesStore);

  protected readonly filteredCompanies = computed(() => {
    return this.companyService.filterCompanies(this.inputValue(), this.control().value);
  });

  constructor() {
    effect(
      () => {
        const controlValue = this.control().value;
        if (controlValue.length === 0) {
          const recent = this.recentCompaniesStore.get();
          if (recent.length > 0) {
            this.control().patchValue(recent, { emitEvent: false });
          }
        }
      },
      { allowSignalWrites: true },
    );
  }

  protected codeToName = (code: string) => {
    return this.companyService.getName(code) ?? code;
  };
}
