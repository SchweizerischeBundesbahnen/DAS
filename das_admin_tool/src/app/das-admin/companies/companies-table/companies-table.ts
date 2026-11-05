import { DatePipe } from '@angular/common';
import {
  afterNextRender,
  Component,
  effect,
  inject,
  input,
  signal,
  viewChild,
} from '@angular/core';
import { form } from '@angular/forms/signals';
import { SbbMiniButton } from '@sbb-esta/lyne-angular/button';
import {
  SbbSort,
  SbbTableDataSource,
  SbbTableFilter,
  SbbTableModule,
} from '@sbb-esta/lyne-angular/table';
import { InternalCompany } from '~app/das-admin/das-admin.api';
import { PageHeader } from '~shared/components/page-header/page-header';
import { TableBottomBar } from '~shared/components/table-bottom-bar/table-bottom-bar';
import { TableSearchHeader } from '~shared/components/table-search-header/table-search-header';
import { CompanyService } from '../company.service';
import { TenantApi } from '../tenant.api';

interface CompanyFilter extends SbbTableFilter {
  search: string;
}

@Component({
  selector: 'app-companies-table',
  imports: [SbbTableModule, SbbMiniButton, DatePipe, PageHeader, TableBottomBar, TableSearchHeader],
  templateUrl: './companies-table.html',
  styleUrl: './companies-table.css',
})
export class CompaniesTable {
  private readonly companyService = inject(CompanyService);
  private readonly tenantApi = inject(TenantApi);

  readonly title = input.required<string>();

  protected dataSource = new SbbTableDataSource<InternalCompany, CompanyFilter>();
  protected columns = [
    'code',
    'shortName',
    'tenantId',
    'lastModifiedAt',
    'lastModifiedBy',
    'action',
  ];

  protected readonly filterModel = signal({ search: '' });
  protected readonly filterForm = form(this.filterModel);

  private readonly sort = viewChild.required<SbbSort>(SbbSort);
  private readonly bottomBar = viewChild.required(TableBottomBar);

  constructor() {
    effect(() => {
      const companiesResource = this.companyService.companiesResource;
      if (companiesResource.hasValue()) {
        this.dataSource.data = companiesResource.value().data;
      }
    });
    afterNextRender(() => {
      this.dataSource.paginator = this.bottomBar().paginator();
      this.dataSource.sort = this.sort();
    });
    this.dataSource.filterPredicate = (data: InternalCompany, filter: CompanyFilter) =>
      this.searchFilter(filter, data);
    effect(() => {
      this.dataSource.filter = this.filterModel();
    });
  }

  protected tenant(tenantId: string) {
    const tenant = this.tenantApi.getTenant(tenantId);
    return tenant ? `${tenant.tenantId} - ${tenant.name}` : tenantId;
  }

  protected async edit(company: InternalCompany): Promise<void> {
    await this.companyService.edit(company);
  }

  protected async add(): Promise<void> {
    await this.companyService.add();
  }

  private searchFilter(filter: CompanyFilter, data: InternalCompany): boolean {
    const search = filter.search.toLowerCase();
    if (!search) return true;
    return (
      data.code.toLowerCase().includes(search)
      || data.shortName.toLowerCase().includes(search)
      || this.tenant(data.tenantId).toLowerCase().includes(search)
      || (data.lastModifiedBy ?? '').toLowerCase().includes(search)
      || (data.lastModifiedAt ?? '').toString().toLowerCase().includes(search)
    );
  }
}
