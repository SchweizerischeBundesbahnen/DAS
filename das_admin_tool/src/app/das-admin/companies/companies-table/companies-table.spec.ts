import { ComponentFixture, TestBed } from '@angular/core/testing';
import { CompanyService } from '../company.service';
import { TenantApi } from '../tenant.api';
import { CompaniesTable } from './companies-table';

const mockCompanyService = { companiesResource: new Proxy({}, { get: () => vi.fn() }) };

const mockTenantApi = { getTenant: new Proxy({}, { get: () => vi.fn() }) };

describe('CompaniesTable', () => {
  let component: CompaniesTable;
  let fixture: ComponentFixture<CompaniesTable>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [CompaniesTable],
      providers: [
        { provide: CompanyService, useValue: mockCompanyService },
        { provide: TenantApi, useValue: mockTenantApi },
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
