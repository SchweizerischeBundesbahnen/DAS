import {Component, computed, effect, inject, input} from '@angular/core';
import {toSignal} from '@angular/core/rxjs-interop';
import {FormControl, ReactiveFormsModule} from '@angular/forms';
import {SbbAutocompleteModule} from '@sbb-esta/lyne-angular/autocomplete';
import {SbbChipModule} from '@sbb-esta/lyne-angular/chip';
import {SbbFormFieldModule} from '@sbb-esta/lyne-angular/form-field';
import {SbbOptionModule} from '@sbb-esta/lyne-angular/option';
import {CompanyService} from './company.service';
import {RecentCompaniesStore} from '../recent-companies.store';

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
  label = input<string>($localize`:@@companies_form_label:EVU`);
  control = input.required<FormControl<string[]>>();

  inputControl = new FormControl('', {nonNullable: true});
  private readonly companyService = inject(CompanyService);
  private readonly recentCompaniesStore = inject(RecentCompaniesStore);
  private readonly inputValue = toSignal(this.inputControl.valueChanges, {initialValue: ''});
  filteredCompanies = computed(() => {
    return this.companyService.filterCompanies(this.inputValue(), this.control().value);
  });

  constructor() {
    effect(() => {
      const controlValue = this.control().value;
      if (controlValue.length === 0) {
        const recent = this.recentCompaniesStore.get();
        if (recent.length > 0) {
          this.control().patchValue(recent, {emitEvent: false});
        }
      }
    }, {allowSignalWrites: true});
  }

  protected codeToName = (code: string) => {
    return this.companyService.getName(code) ?? code;
  };
}
