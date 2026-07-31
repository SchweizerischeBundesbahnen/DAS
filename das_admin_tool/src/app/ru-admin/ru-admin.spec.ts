import { ComponentFixture, TestBed } from '@angular/core/testing';
import { provideRouter } from '@angular/router';
import { CompanyService } from '~shared/companies-input/company.service';
import { RuAdmin } from './ru-admin';
import { LocationService } from './ru-indications/ru-indication-dialog/locations-input/location.service';

describe('RuAdmin', () => {
  let component: RuAdmin;
  let fixture: ComponentFixture<RuAdmin>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [RuAdmin],
      providers: [
        provideRouter([]),
        { provide: CompanyService, useValue: { loaded: () => true } },
        { provide: LocationService, useValue: { loaded: () => true } },
      ],
    }).compileComponents();

    fixture = TestBed.createComponent(RuAdmin);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
