import { DatePipe } from '@angular/common';
import { afterNextRender, Component, effect, inject, viewChild } from '@angular/core';
import { SbbMiniButton } from '@sbb-esta/lyne-angular/button';
import { SbbSort, SbbTableDataSource, SbbTableModule } from '@sbb-esta/lyne-angular/table';
import { InternalCompany } from '~app/das-admin/das-admin.api';
import { TableBottomBar } from '~shared/components/table-bottom-bar/table-bottom-bar';
import { CompanyService } from '../company.service';
import { TenantApi } from '../tenant.api';

@Component({
  selector: 'app-companies-table',
  imports: [SbbTableModule, SbbMiniButton, DatePipe, TableBottomBar],
  templateUrl: './companies-table.html',
  styleUrl: './companies-table.css',
})
export class CompaniesTable {
  private readonly companyService = inject(CompanyService);
  private readonly tenantApi = inject(TenantApi);

  protected dataSource = new SbbTableDataSource<InternalCompany>();
  protected columns = [
    'code',
    'shortName',
    'tenantId',
    'lastModifiedAt',
    'lastModifiedBy',
    'action',
  ];
  protected isDeleting = false;

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
}
