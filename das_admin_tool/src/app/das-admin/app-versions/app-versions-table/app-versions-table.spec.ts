import { ComponentFixture, TestBed } from '@angular/core/testing';
import { AppVersionsService } from '../app-versions.service';
import { AppVersionsTable } from './app-versions-table';

const mockAppVersionsService = { appVersionsResource: new Proxy({}, { get: () => vi.fn() }) };

describe('AppVersionsTable', () => {
  let component: AppVersionsTable;
  let fixture: ComponentFixture<AppVersionsTable>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [AppVersionsTable],
      providers: [{ provide: AppVersionsService, useValue: mockAppVersionsService }],
    }).compileComponents();

    fixture = TestBed.createComponent(AppVersionsTable);
    component = fixture.componentInstance;
    await fixture.whenStable();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
