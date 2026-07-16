import { ComponentFixture, TestBed } from '@angular/core/testing';

import { CompanyDialog } from './company-dialog';

describe('CompanyDialog', () => {
  let component: CompanyDialog;
  let fixture: ComponentFixture<CompanyDialog>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({ imports: [CompanyDialog] }).compileComponents();

    fixture = TestBed.createComponent(CompanyDialog);
    component = fixture.componentInstance;
    await fixture.whenStable();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
