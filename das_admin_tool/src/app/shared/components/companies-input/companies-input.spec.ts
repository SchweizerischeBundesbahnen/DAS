import { Injector, signal } from '@angular/core';
import { ComponentFixture, TestBed } from '@angular/core/testing';
import { FieldTree, form } from '@angular/forms/signals';
import { Company, CompanyApi } from '~shared/services/company.api';
import { RecentCompaniesService } from '~shared/services/recent-companies.service';
import { ToastService } from '~shared/services/toast.service';
import { CompaniesInput } from './companies-input';

const companies = [
  { code: '1085', shortName: 'SBB' },
  { code: '1087', shortName: 'BLS' },
  { code: '9090', shortName: 'RhB' },
];

const mockRecentCompaniesService: Partial<RecentCompaniesService> = { get: () => [] };

describe('CompaniesInput', () => {
  let fixture: ComponentFixture<CompaniesInput>;
  let component: CompaniesInput;
  let selectedCompaniesField: FieldTree<string[]>;
  let companyApi: CompanyApi;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [CompaniesInput],
      providers: [
        { provide: RecentCompaniesService, useValue: mockRecentCompaniesService },
        { provide: ToastService, useValue: { error: vi.fn() } },
      ],
    }).compileComponents();

    companyApi = TestBed.inject(CompanyApi);

    (
      companyApi as unknown as {
        companiesResource: {
          hasValue: () => boolean;
          value: () => { data: Company[] };
          error: () => unknown;
        };
      }
    ).companiesResource = {
      hasValue: () => true,
      value: () => ({ data: companies }),
      error: vi.fn(),
    };

    fixture = TestBed.createComponent(CompaniesInput);
    component = fixture.componentInstance;
    selectedCompaniesField = form(signal([]), { injector: TestBed.inject(Injector) });
    fixture.componentRef.setInput('multiselect', true);
    fixture.componentRef.setInput('field', selectedCompaniesField);
    fixture.detectChanges();
    await fixture.whenStable();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });

  it('should show all non-selected companies when query is empty', () => {
    component['inputField']().value.set('');

    expect(component['filteredCompanies']().map((company) => company.code)).toEqual([
      '1085',
      '1087',
      '9090',
    ]);
  });

  it('should filter by code and name', () => {
    component['inputField']().value.set('sbb');
    expect(component['filteredCompanies']().map((company) => company.code)).toEqual(['1085']);

    component['inputField']().value.set('1087');
    expect(component['filteredCompanies']().map((company) => company.code)).toEqual(['1087']);
  });

  it('should rank exact and prefix matches before contains matches', () => {
    component['inputField']().value.set('b');
    const codes = component['filteredCompanies']().map((company) => company.code);

    expect(codes[0]).toBe('1087');
    expect(codes).toEqual(expect.arrayContaining(['1085', '9090']));
  });

  it('should not include already selected companies in suggestions', () => {
    selectedCompaniesField().value.set(['1087']);

    component['inputField']().value.set('1');
    const suggestedCodes = component['filteredCompanies']().map((company) => company.code);

    expect(suggestedCodes).not.toContain('1087');
    expect(suggestedCodes).toContain('1085');
  });

  it('should initialize companies with recent companies', () => {
    mockRecentCompaniesService.get = () => ['1085', '1087'];

    const localFixture = TestBed.createComponent(CompaniesInput);
    const localField = form(signal([]), { injector: TestBed.inject(Injector) });
    localFixture.componentRef.setInput('multiselect', true);
    localFixture.componentRef.setInput('field', localField);
    localFixture.detectChanges();

    return localFixture.whenStable().then(() => {
      expect(localField().value()).toEqual(['1085', '1087']);
    });
  });
});

describe('CompaniesInput (single-select)', () => {
  let fixture: ComponentFixture<CompaniesInput>;
  let singleField: FieldTree<string>;
  let companyApi: CompanyApi;
  let element: HTMLElement;

  async function createSingle(initialValue: string): Promise<HTMLInputElement> {
    await TestBed.configureTestingModule({
      imports: [CompaniesInput],
      providers: [
        { provide: RecentCompaniesService, useValue: mockRecentCompaniesService },
        { provide: ToastService, useValue: { error: vi.fn() } },
      ],
    }).compileComponents();

    companyApi = TestBed.inject(CompanyApi);
    (
      companyApi as unknown as {
        companiesResource: {
          hasValue: () => boolean;
          value: () => { data: Company[] };
          error: () => unknown;
        };
      }
    ).companiesResource = {
      hasValue: () => true,
      value: () => ({ data: companies }),
      error: vi.fn(),
    };

    fixture = TestBed.createComponent(CompaniesInput);
    element = fixture.nativeElement as HTMLElement;
    singleField = form(signal(initialValue), { injector: TestBed.inject(Injector) });
    fixture.componentRef.setInput('field', singleField);
    fixture.detectChanges();
    await fixture.whenStable();

    return element.querySelector('input')!;
  }

  it('should filter companies by search term', async () => {
    const component = (await createSingle(''), fixture.componentInstance);

    component['onSearchInput']({ target: { value: 'sbb' } } as unknown as Event);

    expect(component['filteredCompanies']().map((company) => company.code)).toEqual(['1085']);
  });

  it('should keep a pre-filled value intact when the field is never touched (edit mode)', async () => {
    await createSingle('1085');

    expect(singleField().value()).toBe('1085');
  });

  it('should keep a pre-filled value intact after a blur with no user interaction', async () => {
    const input = await createSingle('1085');

    input.dispatchEvent(new FocusEvent('blur', { bubbles: true }));
    await fixture.whenStable();

    expect(singleField().value()).toBe('1085');
  });
});
