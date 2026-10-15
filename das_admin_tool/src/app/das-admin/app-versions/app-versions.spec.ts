import { ComponentFixture, TestBed } from '@angular/core/testing';
import { AppVersionService } from './app-version.service';
import { AppVersions } from './app-versions';

const mockAppVersionService = {
  appVersionsResource: new Proxy({}, { get: () => vi.fn() }),
};

describe('AppVersions', () => {
  let component: AppVersions;
  let fixture: ComponentFixture<AppVersions>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [AppVersions],
      providers: [{ provide: AppVersionService, useValue: mockAppVersionService }],
    }).compileComponents();

    fixture = TestBed.createComponent(AppVersions);
    component = fixture.componentInstance;
  });

  it('should create', () => {
    fixture.detectChanges();
    expect(component).toBeTruthy();
  });
});
