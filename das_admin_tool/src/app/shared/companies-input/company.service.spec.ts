import { TestBed } from '@angular/core/testing';
import { Company, CompanyService } from './company.service';

function mockCompanies(service: CompanyService, companies: Company[]) {
  (
    service as unknown as {
      companiesResource: { hasValue: () => boolean; value: () => { data: Company[] } };
    }
  ).companiesResource = { hasValue: () => true, value: () => ({ data: companies }) };
}

describe('CompanyService', () => {
  let service: CompanyService;
  const companies = [
    { code: '1085', name: 'SBB' },
    { code: '1087', name: 'BLS' },
    { code: '9090', name: 'RhB' },
  ];

  beforeEach(() => {
    TestBed.configureTestingModule({});
    service = TestBed.inject(CompanyService);
    mockCompanies(service, companies);
  });

  it('should be created', () => {
    expect(service).toBeTruthy();
  });

  it('getName returns the company name for known code', () => {
    expect(service.getName('1085')).toBe('SBB');
    expect(service.getName('9090')).toBe('RhB');
    expect(service.getName('unknown')).toBeUndefined();
  });

  it('filterCompanies returns all when query is empty and excludes provided codes', () => {
    expect(service.filterCompanies('', ['1087']).map((c) => c.code)).toEqual(['1085', '9090']);
  });

  it('filterCompanies filters by code and name (case-insensitive)', () => {
    expect(service.filterCompanies('sbb').map((c) => c.code)).toEqual(['1085']);
    expect(service.filterCompanies('1087').map((c) => c.code)).toEqual(['1087']);
  });

  it('filterCompanies ranks exact and prefix matches before contains matches', () => {
    const extended = [...companies, { code: '1231085', name: 'Other' }];
    mockCompanies(service, extended);

    const result = service.filterCompanies('1085').map((c) => c.code);
    expect(result.indexOf('1085')).toBeLessThan(result.indexOf('1231085'));
  });

  it('formatCompanies maps known codes to names and sorts by name', () => {
    const input = ['9090', '1085'];
    const result = service.formatCompanies(input);

    expect(result).toBe('RhB, SBB');
  });

  it('formatCompanies preserves unknown codes and includes them in the sorted output', () => {
    const input = ['1085', 'UNKNOWN'];
    const result = service.formatCompanies(input);

    expect(result).toBe('SBB, UNKNOWN');
  });

  it('formatCompanies returns empty string for empty input', () => {
    expect(service.formatCompanies([])).toBe('');
  });
});
