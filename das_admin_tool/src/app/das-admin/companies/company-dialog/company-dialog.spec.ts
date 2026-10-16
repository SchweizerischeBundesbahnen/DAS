import { ComponentFixture, TestBed } from '@angular/core/testing';
import { TenantApi } from '../tenant.api';
import { CompanyDialog } from './company-dialog';

const mockTenantApi = { tenants: () => [] };

describe('CompanyDialog', () => {
  let component: CompanyDialog;
  let fixture: ComponentFixture<CompanyDialog>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [CompanyDialog],
      providers: [{ provide: TenantApi, useValue: mockTenantApi }],
    }).compileComponents();

    fixture = TestBed.createComponent(CompanyDialog);
    component = fixture.componentInstance;
    await fixture.whenStable();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
