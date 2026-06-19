import { ComponentFixture, TestBed } from '@angular/core/testing';
import { FormControl } from '@angular/forms';
import { CompaniesInputComponent } from './companies-input.component';
import { Company, CompanyService } from './company.service';
import { RecentCompaniesStore } from '../recent-companies.store';
import { ToastService } from '../toast-service';

const companies = [
  { code: '1085', shortName: 'SBB' },
  { code: '1087', shortName: 'BLS' },
  { code: '9090', shortName: 'RhB' },
];

const mockRecentCompaniesStore: Partial<RecentCompaniesStore> = { get: () => [] };

describe('CompaniesInputComponent', () => {
  let fixture: ComponentFixture<CompaniesInputComponent>;
  let component: CompaniesInputComponent;
  let selectedCompaniesControl: FormControl<string[]>;
  let companyService: CompanyService;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [CompaniesInputComponent],
      providers: [
        { provide: RecentCompaniesStore, useValue: mockRecentCompaniesStore },
        { provide: ToastService, useValue: { error: vi.fn() } },
      ],
    }).compileComponents();

    companyService = TestBed.inject(CompanyService);

    (
      companyService as unknown as {
        companiesResource: {
          hasValue: () => boolean;
          value: () => { data: Company[] };
          error: () => unknown;
        };
      }
    ).companiesResource = {
      hasValue: () => true,
      value: () => ({ data: companies }),
      error: () => undefined,
    };

    fixture = TestBed.createComponent(CompaniesInputComponent);
    component = fixture.componentInstance;
    selectedCompaniesControl = new FormControl<string[]>([], { nonNullable: true });
    fixture.componentRef.setInput('control', selectedCompaniesControl);
    fixture.detectChanges();
    await fixture.whenStable();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });

  it('should show all non-selected companies when query is empty', () => {
    component['inputControl'].setValue('');

    expect(component['filteredCompanies']().map((company) => company.code)).toEqual([
      '1085',
      '1087',
      '9090',
    ]);
  });

  it('should filter by code and name', () => {
    component['inputControl'].setValue('sbb');
    expect(component['filteredCompanies']().map((company) => company.code)).toEqual(['1085']);

    component['inputControl'].setValue('1087');
    expect(component['filteredCompanies']().map((company) => company.code)).toEqual(['1087']);
  });

  it('should rank exact and prefix matches before contains matches', () => {
    component['inputControl'].setValue('b');
    const codes = component['filteredCompanies']().map((company) => company.code);

    expect(codes[0]).toBe('1087');
    expect(codes).toEqual(expect.arrayContaining(['1085', '9090']));
  });

  it('should not include already selected companies in suggestions', () => {
    selectedCompaniesControl.setValue(['1087']);

    component['inputControl'].setValue('1');
    const suggestedCodes = component['filteredCompanies']().map((company) => company.code);

    expect(suggestedCodes).not.toContain('1087');
    expect(suggestedCodes).toContain('1085');
  });

  it('should initialize companies with recent companies', () => {
    mockRecentCompaniesStore.get = () => ['1085', '1087'];

    const localFixture = TestBed.createComponent(CompaniesInputComponent);
    const localControl = new FormControl<string[]>([], { nonNullable: true });
    localFixture.componentRef.setInput('control', localControl);
    localFixture.detectChanges();

    return localFixture.whenStable().then(() => {
      expect(localControl.value).toEqual(['1085', '1087']);
    });
  });
});

describe('CompaniesInputComponent (single-select)', () => {
  let fixture: ComponentFixture<CompaniesInputComponent>;
  let singleControl: FormControl<string>;
  let companyService: CompanyService;

  async function createSingle(initialValue: string): Promise<HTMLInputElement> {
    await TestBed.configureTestingModule({
      imports: [CompaniesInputComponent],
      providers: [
        { provide: RecentCompaniesStore, useValue: mockRecentCompaniesStore },
        { provide: ToastService, useValue: { error: vi.fn() } },
      ],
    }).compileComponents();

    companyService = TestBed.inject(CompanyService);
    (
      companyService as unknown as {
        companiesResource: {
          hasValue: () => boolean;
          value: () => { data: Company[] };
          error: () => unknown;
        };
      }
    ).companiesResource = {
      hasValue: () => true,
      value: () => ({ data: companies }),
      error: () => undefined,
    };

    fixture = TestBed.createComponent(CompaniesInputComponent);
    singleControl = new FormControl<string>(initialValue, { nonNullable: true });
    fixture.componentRef.setInput('control', singleControl);
    fixture.componentRef.setInput('multiselect', false);
    fixture.detectChanges();
    await fixture.whenStable();

    return fixture.nativeElement.querySelector('input') as HTMLInputElement;
  }

  it('should filter companies by search term', async () => {
    const component = (await createSingle(''), fixture.componentInstance);

    component['onSearchInput']({ target: { value: 'sbb' } } as unknown as Event);

    expect(component['filteredCompanies']().map((company) => company.code)).toEqual(['1085']);
  });

  it('should keep a pre-filled value intact when the field is never touched (edit mode)', async () => {
    await createSingle('1085');

    expect(singleControl.value).toBe('1085');
  });

  it('should keep a pre-filled value intact after a blur with no user interaction', async () => {
    const input = await createSingle('1085');

    input.dispatchEvent(new FocusEvent('blur', { bubbles: true }));
    await fixture.whenStable();

    expect(singleControl.value).toBe('1085');
  });
});
