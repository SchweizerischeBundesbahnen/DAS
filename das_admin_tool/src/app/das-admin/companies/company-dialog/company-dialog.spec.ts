import { ComponentFixture, TestBed } from '@angular/core/testing';

import { CompanyDialog } from './company-dialog';
import { TenantService } from './tenant.service';

const mockTenantService = { tenants: () => [] };

describe('CompanyDialog', () => {
  let component: CompanyDialog;
  let fixture: ComponentFixture<CompanyDialog>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [CompanyDialog],
      providers: [{ provide: TenantService, useValue: mockTenantService }],
    }).compileComponents();

    fixture = TestBed.createComponent(CompanyDialog);
    component = fixture.componentInstance;
    await fixture.whenStable();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
