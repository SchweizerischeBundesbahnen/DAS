import { ComponentFixture, TestBed } from '@angular/core/testing';

import { Companies } from './companies';
import { CompanyService } from './company.service';

const mockCompanyService = { companiesResource: new Proxy({}, { get: () => vi.fn() }) };

describe('Companies', () => {
  let component: Companies;
  let fixture: ComponentFixture<Companies>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [Companies],
      providers: [{ provide: CompanyService, useValue: mockCompanyService }],
    }).compileComponents();

    fixture = TestBed.createComponent(Companies);
    component = fixture.componentInstance;
    await fixture.whenStable();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
