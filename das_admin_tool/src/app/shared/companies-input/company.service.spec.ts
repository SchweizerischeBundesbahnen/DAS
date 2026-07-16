import {TestBed} from '@angular/core/testing';

import {Company, CompanyService} from './company.service';
import {ToastService} from '../toast-service';

function mockCompanies(service: CompanyService, companies: Company[]) {
  ((service as unknown) as {
    companiesResource: { hasValue: () => boolean; value: () => { data: Company[] }; error: () => unknown }
  }).companiesResource = {hasValue: () => true, value: () => ({data: companies}), error: () => undefined};
}

describe('CompanyService', () => {
  let service: CompanyService;
  const companies = [
    {code: '1085', shortName: 'SBB'},
    {code: '1087', shortName: 'BLS'},
    {code: '9090', shortName: 'RhB'},
  ];

  beforeEach(() => {
    TestBed.configureTestingModule({
      providers: [{provide: ToastService, useValue: {error: vi.fn()}}],
    });
    service = TestBed.inject(CompanyService);
    mockCompanies(service, companies)
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
    expect(service.filterCompanies('', ['1087']).map(c => c.code)).toEqual(['1085', '9090']);
  });

  it('filterCompanies filters by code and name (case-insensitive)', () => {
    expect(service.filterCompanies('sbb').map(c => c.code)).toEqual(['1085']);
    expect(service.filterCompanies('1087').map(c => c.code)).toEqual(['1087']);
  });

  it('filterCompanies matches an uppercase or mixed-case query against uppercase-stored names', () => {
    expect(service.filterCompanies('SBB').map(c => c.code)).toEqual(['1085']);
    expect(service.filterCompanies('Sb').map(c => c.code)).toEqual(['1085']);
    expect(service.filterCompanies('S').map(c => c.code)).toEqual(['1085', '1087']);
  });

  it('filterCompanies ranks exact and prefix matches before contains matches', () => {
    const extended = [...companies, {code: '1231085', shortName: 'Other'}];
    mockCompanies(service, extended);

    const result = service.filterCompanies('1085').map(c => c.code);
    expect(result.indexOf('1085')).toBeLessThan(result.indexOf('1231085'));
  });

  it('formatCompanies maps known codes to shortNames and sorts by shortName', () => {
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

  it('loaded should return true when companiesResource has value', () => {
    expect(service.loaded()).toBe(true);
  });

  it('loaded should return true when companiesResource has error', () => {
    ((service as unknown) as {
      companiesResource: { hasValue: () => boolean; value: () => { data: Company[] }; error: () => unknown }
    }).companiesResource = {hasValue: () => false, value: () => ({data: []}), error: () => new Error('fail')};
    expect(service.loaded()).toBe(true);
  });

  it('loaded should return false when companiesResource is still loading', () => {
    ((service as unknown) as {
      companiesResource: { hasValue: () => boolean; value: () => { data: Company[] }; error: () => unknown }
    }).companiesResource = {hasValue: () => false, value: () => ({data: []}), error: () => undefined};
    expect(service.loaded()).toBe(false);
  });
});
