import {ComponentFixture, TestBed} from '@angular/core/testing';
import {HttpResourceRef} from '@angular/common/http';
import {FormControl} from '@angular/forms';
import {CompaniesInputComponent} from './companies-input.component';
import {CompaniesApi} from './companies-api.service';

const companies = [
  {code: '1085', name: 'SBB'},
  {code: '1087', name: 'BLS'},
  {code: '9090', name: 'RhB'},
];

describe('CompaniesInputComponent', () => {
  let fixture: ComponentFixture<CompaniesInputComponent>;
  let component: CompaniesInputComponent;
  let selectedCompaniesControl: FormControl<string[]>;
  const companiesResource = {
    hasValue: () => true,
    value: () => ({data: companies}),
  } as HttpResourceRef<{ data: typeof companies }>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [CompaniesInputComponent],
      providers: [
        {provide: CompaniesApi, useValue: {companies: companiesResource}},
      ],
    }).compileComponents();

    fixture = TestBed.createComponent(CompaniesInputComponent);
    component = fixture.componentInstance;
    selectedCompaniesControl = new FormControl<string[]>([], {nonNullable: true});
    fixture.componentRef.setInput('control', selectedCompaniesControl);
    fixture.detectChanges();
    await fixture.whenStable();
  });

  beforeEach(() => vi.clearAllMocks());

  it('should create', () => {
    expect(component).toBeTruthy();
  });

  it('should show all non-selected companies when query is empty', () => {
    component.inputControl.setValue('');

    expect(component['filteredCompanies']().map((company) => company.code)).toEqual(['1085', '1087', '9090']);
  });

  it('should filter by code and name', () => {
    component.inputControl.setValue('sbb');
    expect(component['filteredCompanies']().map((company) => company.code)).toEqual(['1085']);

    component.inputControl.setValue('1087');
    expect(component['filteredCompanies']().map((company) => company.code)).toEqual(['1087']);
  });

  it('should rank exact and prefix matches before contains matches', () => {
    component.inputControl.setValue('b');
    const codes = component['filteredCompanies']().map((company) => company.code);

    expect(codes[0]).toBe('1087');
    expect(codes).toEqual(expect.arrayContaining(['1085', '9090']));
  });

  it('should not include already selected companies in suggestions', () => {
    component.control().setValue(['1087']);

    component.inputControl.setValue('1');
    const suggestedCodes = component['filteredCompanies']().map((company) => company.code);

    expect(suggestedCodes).not.toContain('1087');
    expect(suggestedCodes).toContain('1085');
  });
});
