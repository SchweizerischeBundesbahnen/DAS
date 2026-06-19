import { ComponentFixture, TestBed } from '@angular/core/testing';
import { AppVersions } from './app-versions';
import { AppVersionsService } from './app-versions.service';

const mockAppVersionsService = {
  appVersionsResource: new Proxy({}, { get: () => vi.fn() }),
};

describe('AppVersions', () => {
  let component: AppVersions;
  let fixture: ComponentFixture<AppVersions>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [AppVersions],
      providers: [{ provide: AppVersionsService, useValue: mockAppVersionsService }],
    }).compileComponents();

    fixture = TestBed.createComponent(AppVersions);
    component = fixture.componentInstance;
  });

  it('should create', () => {
    fixture.detectChanges();
    expect(component).toBeTruthy();
  });
});
