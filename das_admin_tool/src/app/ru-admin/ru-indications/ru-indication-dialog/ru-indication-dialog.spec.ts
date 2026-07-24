import { ComponentFixture, TestBed } from '@angular/core/testing';
import { SBB_OVERLAY_DATA } from '@sbb-esta/lyne-angular/core';
import { CompanyService } from '~shared/companies-input/company.service';
import { RecentCompaniesStore } from '~shared/recent-companies.store';
import { RuIndicationDialogData } from '../ru-indication.service';
import { RuIndicationDialog } from './ru-indication-dialog.component';

const mockRecentCompaniesStore = { get: () => [] };

const mockCompanyService = {
  filterCompanies: vi.fn(),
};

const dialogData: RuIndicationDialogData = { ruIndication: undefined, templates: [] };

describe('RuIndicationDialog', () => {
  let component: RuIndicationDialog;
  let fixture: ComponentFixture<RuIndicationDialog>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [RuIndicationDialog],
      providers: [
        { provide: SBB_OVERLAY_DATA, useValue: dialogData },
        { provide: CompanyService, useValue: mockCompanyService },
        { provide: RecentCompaniesStore, useValue: mockRecentCompaniesStore },
      ],
    }).compileComponents();

    fixture = TestBed.createComponent(RuIndicationDialog);
    component = fixture.componentInstance;
    await fixture.whenStable();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
