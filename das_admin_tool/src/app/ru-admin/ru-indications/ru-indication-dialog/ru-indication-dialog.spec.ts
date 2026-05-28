import { ComponentFixture, TestBed } from '@angular/core/testing';

import { RuIndicationDialog } from './ru-indication-dialog.component';
import { SBB_OVERLAY_DATA } from '@sbb-esta/lyne-angular/core/overlay';
import { RecentCompaniesStore } from '../../../shared/recent-companies.store';
import { RuIndicationDialogData } from '../ru-indication.service';

const mockRecentCompaniesStore = {get: () => []};

const dialogData: RuIndicationDialogData = {ruIndication: undefined, templates: []};

describe('RuIndicationDialog', () => {
  let component: RuIndicationDialog;
  let fixture: ComponentFixture<RuIndicationDialog>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [RuIndicationDialog],
      providers: [
        {provide: SBB_OVERLAY_DATA, useValue: dialogData},
        {provide: RecentCompaniesStore, useValue: mockRecentCompaniesStore}
      ]
    })
      .compileComponents();

    fixture = TestBed.createComponent(RuIndicationDialog);
    component = fixture.componentInstance;
    await fixture.whenStable();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
