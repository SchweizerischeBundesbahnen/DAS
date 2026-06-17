import { ComponentFixture, TestBed } from '@angular/core/testing';

import { DasAdmin } from './das-admin';
import { AppVersionsService } from './app-versions/app-versions.service';

const mockAppVersionsService = {
  appVersionsResource: new Proxy({}, {get: () => vi.fn()})
};

describe('DasAdmin', () => {
  let component: DasAdmin;
  let fixture: ComponentFixture<DasAdmin>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [DasAdmin],
      providers: [{provide: AppVersionsService, useValue: mockAppVersionsService}],
    })
      .compileComponents();

    fixture = TestBed.createComponent(DasAdmin);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
