import { httpResource } from '@angular/common/http';
import { computed, Service } from '@angular/core';
import { ApiResponse } from '~shared/models/api-response.model';
import { environment } from '~src/environments/environment';

export interface Tenant {
  name: string;
  tenantId: string;
}

type TenantApiResponse = ApiResponse<Tenant>;

@Service()
export class TenantApi {
  private readonly url = `${environment.backendUrl}/tenants`;
  private readonly tenantsResource = httpResource<TenantApiResponse>(() => this.url);
  public readonly tenants = computed(() => this.tenantsResource.value()?.data ?? []);

  public getTenant(tenantId: string) {
    return this.tenants().find((tenant) => tenant.tenantId === tenantId);
  }
}
