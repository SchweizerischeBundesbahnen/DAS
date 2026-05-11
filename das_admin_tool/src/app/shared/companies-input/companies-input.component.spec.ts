import {ComponentFixture, TestBed} from '@angular/core/testing';
import {HttpResourceRef} from '@angular/common/http';
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

  it('should propagate selected code', () => {
    const onChange = vi.fn();
    const onTouched = vi.fn();
    component.registerOnChange(onChange);
    component.registerOnTouched(onTouched);
    component.writeValue(['1087']);
    component['selectOption']({code: '1085', name: 'SBB'});

    expect(onChange).toHaveBeenCalledWith(['1087', '1085']);
    expect(onTouched).toHaveBeenCalled();
  });

  it('should remove selected company', () => {
    const onChange = vi.fn();
    component.registerOnChange(onChange);
    component.writeValue(['1085', '1087']);
    component['remove']({code: '1085', name: 'SBB'});

    expect(onChange).toHaveBeenCalledWith(['1087']);
  });

  it('should not include already selected companies in suggestions', async () => {
    component.writeValue(['1087']);
    fixture.detectChanges();
    await fixture.whenStable();
    component.inputControl.setValue('');
    const suggestedCodes = component['filteredCompanies']().map((company) => company.code);

    expect(suggestedCodes).not.toContain('1087');
    expect(suggestedCodes).toEqual(expect.arrayContaining(['1085', '9090']));
  });
});
