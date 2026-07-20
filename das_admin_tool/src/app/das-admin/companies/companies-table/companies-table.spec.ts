import { ComponentFixture, TestBed } from '@angular/core/testing';

import { CompaniesTable } from './companies-table';
import { CompanyService } from '../company.service';
import { TenantService } from '../company-dialog/tenant.service';

const mockCompanyService = { companiesResource: new Proxy({}, { get: () => vi.fn() }) };

const mockTenantService = { getTenant: new Proxy({}, { get: () => vi.fn() }) };

describe('CompaniesTable', () => {
  let component: CompaniesTable;
  let fixture: ComponentFixture<CompaniesTable>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [CompaniesTable],
      providers: [
        { provide: CompanyService, useValue: mockCompanyService },
        { provide: TenantService, useValue: mockTenantService },
      ],
    }).compileComponents();

    fixture = TestBed.createComponent(CompaniesTable);
    component = fixture.componentInstance;
    await fixture.whenStable();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
