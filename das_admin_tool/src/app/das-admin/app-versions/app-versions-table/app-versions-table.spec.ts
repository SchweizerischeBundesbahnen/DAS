import { ComponentFixture, TestBed } from '@angular/core/testing';

import { AppVersionsTable } from './app-versions-table';

describe('AppVersionsTable', () => {
  let component: AppVersionsTable;
  let fixture: ComponentFixture<AppVersionsTable>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [AppVersionsTable]
    })
    .compileComponents();

    fixture = TestBed.createComponent(AppVersionsTable);
    component = fixture.componentInstance;
    await fixture.whenStable();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
