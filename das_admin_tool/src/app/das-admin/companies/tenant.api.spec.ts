import { TestBed } from '@angular/core/testing';
import { Tenant, TenantApi } from './tenant.api';

describe('TenantApi', () => {
  let tenantApi: TenantApi;

  beforeEach(() => {
    TestBed.configureTestingModule({});
    tenantApi = TestBed.inject(TenantApi);
  });

  it('should be created', () => {
    expect(tenantApi).toBeTruthy();
  });

  it('getTenant should return tenant', () => {
    (tenantApi as { tenants: () => Tenant[] }).tenants = () => [
      { name: 'SBB', tenantId: '1' },
      { name: 'BLS', tenantId: '2' },
    ];
    expect(tenantApi.getTenant('1')).toEqual({ name: 'SBB', tenantId: '1' });
  });
});
