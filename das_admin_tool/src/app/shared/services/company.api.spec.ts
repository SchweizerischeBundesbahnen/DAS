import { TestBed } from '@angular/core/testing';
import { Company, CompanyApi } from './company.api';
import { ToastService } from './toast.service';

function mockCompanies(companyApi: CompanyApi, companies: Company[]) {
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
}

describe('CompanyApi', () => {
  let companyApi: CompanyApi;
  const companies = [
    { code: '1085', shortName: 'SBB' },
    { code: '1087', shortName: 'BLS' },
    { code: '9090', shortName: 'RhB' },
  ];

  beforeEach(() => {
    TestBed.configureTestingModule({
      providers: [{ provide: ToastService, useValue: { error: vi.fn() } }],
    });
    companyApi = TestBed.inject(CompanyApi);
    mockCompanies(companyApi, companies);
  });

  it('should be created', () => {
    expect(companyApi).toBeTruthy();
  });

  it('getName returns the company name for known code', () => {
    expect(companyApi.getName('1085')).toBe('SBB');
    expect(companyApi.getName('9090')).toBe('RhB');
    expect(companyApi.getName('unknown')).toBeUndefined();
  });

  it('filterCompanies returns all when query is empty and excludes provided codes', () => {
    expect(companyApi.filterCompanies('', ['1087']).map((c) => c.code)).toEqual(['1085', '9090']);
  });

  it('filterCompanies filters by code and name (case-insensitive)', () => {
    expect(companyApi.filterCompanies('sbb').map((c) => c.code)).toEqual(['1085']);
    expect(companyApi.filterCompanies('1087').map((c) => c.code)).toEqual(['1087']);
  });

  it('filterCompanies matches an uppercase or mixed-case query against uppercase-stored names', () => {
    expect(companyApi.filterCompanies('SBB').map((c) => c.code)).toEqual(['1085']);
    expect(companyApi.filterCompanies('Sb').map((c) => c.code)).toEqual(['1085']);
    expect(companyApi.filterCompanies('S').map((c) => c.code)).toEqual(['1085', '1087']);
  });

  it('filterCompanies ranks exact and prefix matches before contains matches', () => {
    const extended = [...companies, { code: '1231085', shortName: 'Other' }];
    mockCompanies(companyApi, extended);

    const result = companyApi.filterCompanies('1085').map((c) => c.code);
    expect(result.indexOf('1085')).toBeLessThan(result.indexOf('1231085'));
  });

  it('formatCompanies maps known codes to shortNames and sorts by shortName', () => {
    const input = ['9090', '1085'];
    const result = companyApi.formatCompanies(input);

    expect(result).toBe('RhB, SBB');
  });

  it('formatCompanies preserves unknown codes and includes them in the sorted output', () => {
    const input = ['1085', 'UNKNOWN'];
    const result = companyApi.formatCompanies(input);

    expect(result).toBe('SBB, UNKNOWN');
  });

  it('formatCompanies returns empty string for empty input', () => {
    expect(companyApi.formatCompanies([])).toBe('');
  });

  it('loaded should return true when companiesResource has value', () => {
    expect(companyApi.loaded()).toBe(true);
  });

  it('loaded should return true when companiesResource has error', () => {
    (
      companyApi as unknown as {
        companiesResource: {
          hasValue: () => boolean;
          value: () => { data: Company[] };
          error: () => unknown;
        };
      }
    ).companiesResource = {
      hasValue: () => false,
      value: () => ({ data: [] }),
      error: () => new Error('fail'),
    };
    expect(companyApi.loaded()).toBe(true);
  });

  it('loaded should return false when companiesResource is still loading', () => {
    (
      companyApi as unknown as {
        companiesResource: {
          hasValue: () => boolean;
          value: () => { data: Company[] };
          error: () => unknown;
        };
      }
    ).companiesResource = {
      hasValue: () => false,
      value: () => ({ data: [] }),
      error: vi.fn(),
    };
    expect(companyApi.loaded()).toBe(false);
  });
});
