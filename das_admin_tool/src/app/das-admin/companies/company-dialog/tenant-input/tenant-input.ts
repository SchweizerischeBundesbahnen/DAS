import { Component, computed, inject, input } from '@angular/core';
import { FormControl, ReactiveFormsModule } from '@angular/forms';
import { SbbAutocompleteModule } from '@sbb-esta/lyne-angular/autocomplete';
import { SbbFormFieldModule } from '@sbb-esta/lyne-angular/form-field';
import { Tenant, TenantService } from './tenant.service';
import { rxResource } from '@angular/core/rxjs-interop';

@Component({
  selector: 'app-tenant-input',
  imports: [SbbAutocompleteModule, SbbFormFieldModule, ReactiveFormsModule],
  templateUrl: './tenant-input.html',
  styleUrl: './tenant-input.css',
})
export class TenantInput {
  public readonly control = input.required<FormControl<string>>();

  private readonly tenantService = inject(TenantService);

  private readonly query = rxResource({
    params: () => ({ control: this.control() }),
    stream: ({ params }) => params.control.valueChanges,
    defaultValue: '',
  });

  protected filteredTenants = computed(() => {
    const query = this.query.value();
    const excludedReferences = this.control().value;
    const tenants = this.tenantService.tenants();

    const caseInsensitiveQuery = query.trim().toLowerCase();
    if (caseInsensitiveQuery.length < 2) {
      return tenants;
    }
    const includesQuery = tenants.filter(
      ({ name, tenantId }) =>
        (name.toLowerCase().includes(caseInsensitiveQuery)
          || tenantId.toLowerCase().includes(caseInsensitiveQuery))
        && !excludedReferences.includes(tenantId),
    );
    return this.sortByRelevance(includesQuery, caseInsensitiveQuery);
  });

  private sortByRelevance(includesQuery: Tenant[], query: string) {
    return includesQuery.sort((a, b) => {
      const aName = a.name.toLowerCase() ?? '';
      const bName = b.name.toLowerCase() ?? '';
      const aTenantId = a.tenantId.toLowerCase() ?? '';
      const bTenantId = b.tenantId.toLowerCase() ?? '';

      const aRank = Math.min(this.rank(query, aName), this.rank(query, aTenantId));
      const bRank = Math.min(this.rank(query, bName), this.rank(query, bTenantId));
      return aRank !== bRank ? aRank - bRank : aName.localeCompare(bName);
    });
  }

  private rank(query: string, value: string): number {
    if (value === query) return 0; // exact
    if (value.startsWith(query)) return 1; // prefix
    if (value.includes(query)) return 2; // substring
    return 3;
  }
}
