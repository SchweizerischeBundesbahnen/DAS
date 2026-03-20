import {ComponentFixture, TestBed} from '@angular/core/testing';

import {AppVersionDialog} from './app-version-dialog';

describe('AppVersionDialog', () => {
  let component: AppVersionDialog;
  let fixture: ComponentFixture<AppVersionDialog>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [AppVersionDialog]
    })
      .compileComponents();

    fixture = TestBed.createComponent(AppVersionDialog);
    component = fixture.componentInstance;
    await fixture.whenStable();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
