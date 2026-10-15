import { ComponentFixture, TestBed } from '@angular/core/testing';
import { provideRouter } from '@angular/router';
import { CompanyApi } from '~shared/services/company.api';
import { LocationApi } from './location.api';
import { RuAdmin } from './ru-admin';

describe('RuAdmin', () => {
  let component: RuAdmin;
  let fixture: ComponentFixture<RuAdmin>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [RuAdmin],
      providers: [
        provideRouter([]),
        { provide: CompanyApi, useValue: { loaded: () => true } },
        { provide: LocationApi, useValue: { loaded: () => true } },
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
