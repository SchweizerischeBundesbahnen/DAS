import { ComponentFixture, TestBed } from '@angular/core/testing';
import { InternalCompany } from '~app/das-admin/das-admin.api';
import { ConfirmDeleteService } from '~shared/services/confirm-delete.service';
import { CompanyService } from '../company.service';
import { TenantApi } from '../tenant.api';
import { CompaniesTable } from './companies-table';

const mockCompanyService = { companiesResource: new Proxy({}, { get: () => vi.fn() }) };

const mockTenantApi = {
  getTenant: vi.fn(() => ({ tenantId: 'tenant-1', name: 'SBB Personenverkehr' })),
};

const company: InternalCompany = {
  id: 1,
  code: '1085',
  shortName: 'SBBP',
  tenantId: 'tenant-1',
  lastModifiedBy: 'admin',
  lastModifiedAt: new Date('2026-01-15T10:00:00Z'),
};

describe('CompaniesTable', () => {
  let component: CompaniesTable;
  let fixture: ComponentFixture<CompaniesTable>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [CompaniesTable],
      providers: [
        { provide: CompanyService, useValue: mockCompanyService },
        { provide: TenantApi, useValue: mockTenantApi },
        { provide: ConfirmDeleteService, useValue: { confirm: vi.fn() } },
      ],
    }).compileComponents();

    fixture = TestBed.createComponent(CompaniesTable);
    component = fixture.componentInstance;
    fixture.componentRef.setInput('title', 'Title');
    await fixture.whenStable();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });

  describe('searchFilter', () => {
    it.each([
      { search: '', expected: true, description: 'empty search returns all' },
      { search: '1085', expected: true, description: 'matches on code' },
      { search: 'sbbp', expected: true, description: 'matches on short name' },
      { search: 'personenverkehr', expected: true, description: 'matches on tenant name' },
      { search: 'admin', expected: true, description: 'matches on lastModifiedBy' },
      { search: 'SBBP', expected: true, description: 'is case-insensitive' },
      { search: 'xyz-nomatch', expected: false, description: 'returns false when no match' },
    ])('$description (search="$search")', ({ search, expected }) => {
      expect(component['searchFilter']({ search }, company)).toBe(expected);
    });
  });
});
