import {ComponentFixture, TestBed} from '@angular/core/testing';

import {AppVersions} from './app-versions';

describe('AppVersions', () => {
  let component: AppVersions;
  let fixture: ComponentFixture<AppVersions>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [AppVersions],
      providers: [],
    })
      .compileComponents();

    fixture = TestBed.createComponent(AppVersions);
    component = fixture.componentInstance;
  });

  it('should create', () => {
    fixture.detectChanges();
    expect(component).toBeTruthy();
  });
});
