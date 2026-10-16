import {
  booleanAttribute,
  Component,
  computed,
  effect,
  inject,
  input,
  signal,
  untracked,
} from '@angular/core';
import { FieldTree, form, FormField } from '@angular/forms/signals';
import { SbbAutocompleteModule } from '@sbb-esta/lyne-angular/autocomplete';
import { SbbChipModule } from '@sbb-esta/lyne-angular/chip';
import { SbbFormFieldModule } from '@sbb-esta/lyne-angular/form-field';
import { CompanyApi } from '~shared/services/company.api';
import { RecentCompaniesService } from '~shared/services/recent-companies.service';

@Component({
  selector: 'app-companies-input',
  imports: [SbbAutocompleteModule, SbbChipModule, SbbFormFieldModule, FormField],
  templateUrl: './companies-input.html',
  styleUrl: './companies-input.css',
})
export class CompaniesInput {
  private readonly companyApi = inject(CompanyApi);
  private readonly recentCompaniesService = inject(RecentCompaniesService);

  public readonly label = input<string>($localize`:@@companies_form_label:EVU`);
  public readonly field = input.required<FieldTree<string[]> | FieldTree<string>>();
  public readonly multiselect = input(false, { transform: booleanAttribute });

  protected readonly multiField = computed(() => this.field() as FieldTree<string[]>);
  protected inputField = form(signal(''));

  protected readonly singleField = computed(() => this.field() as FieldTree<string>);
  private readonly searchTerm = signal<string>('');

  protected readonly filteredCompanies = computed(() => {
    if (this.multiselect()) {
      return this.companyApi.filterCompanies(
        this.inputField().value(),
        this.multiField()().value(),
      );
    }
    return this.companyApi.filterCompanies(this.searchTerm());
  });

  constructor() {
    effect(() => {
      if (!this.multiselect()) {
        return;
      }
      const multi = this.multiField()();
      if (untracked(() => multi.value()).length === 0) {
        const recent = this.recentCompaniesService.get();
        if (recent.length > 0) {
          multi.value.set(recent);
        }
      }
    });
  }

  protected codeToName = (code: string) => this.companyApi.getName(code) ?? code;

  protected onSearchInput(event: Event): void {
    this.searchTerm.set((event.target as HTMLInputElement).value);
  }
}
