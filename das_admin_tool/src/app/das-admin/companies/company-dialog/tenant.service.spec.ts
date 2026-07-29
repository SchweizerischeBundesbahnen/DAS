import { TestBed } from '@angular/core/testing';
import { Tenant, TenantService } from './tenant.service';

describe('TenantService', () => {
  let service: TenantService;

  beforeEach(() => {
    TestBed.configureTestingModule({});
    service = TestBed.inject(TenantService);
  });

  it('should be created', () => {
    expect(service).toBeTruthy();
  });

  it('getTenant should return tenant', () => {
    (service as { tenants: () => Tenant[] }).tenants = () => [
      { name: 'SBB', tenantId: '1' },
      { name: 'BLS', tenantId: '2' },
    ];
    expect(service.getTenant('1')).toEqual({ name: 'SBB', tenantId: '1' });
  });
});
