import { TestBed } from '@angular/core/testing';

import { Location, LocationService } from './location.service';
import { ToastService } from '../../../../shared/toast-service';

const locations: Location[] = [
  { primaryLocationName: 'Bern', locationAbbreviation: 'BN', locationReference: 'CH00001' },
  { primaryLocationName: 'Bernau', locationAbbreviation: 'BAU', locationReference: 'DE00002' },
  { primaryLocationName: 'Bernried', locationAbbreviation: 'BRD', locationReference: 'DE00003' },
  { primaryLocationName: 'Zürich', locationAbbreviation: 'ZH', locationReference: 'CH00004' },
  { primaryLocationName: 'Winterthur', locationAbbreviation: 'WT', locationReference: 'CH00005' },
  { primaryLocationName: 'Luzern', locationAbbreviation: 'LU', locationReference: 'CH00007' },
];

describe('LocationService', () => {
  let service: LocationService;
  beforeEach(() => {
    TestBed.configureTestingModule({
      providers: [LocationService, { provide: ToastService, useValue: { error: vi.fn() } }],
    });

    service = TestBed.inject(LocationService);

    (
      service as unknown as {
        locationsResource: {
          hasValue: () => boolean;
          value: () => { data: Location[] };
          error: () => unknown;
        };
      }
    ).locationsResource = {
      hasValue: () => true,
      value: () => ({ data: locations }),
      error: () => undefined,
    };
  });

  it('should be created', () => {
    expect(service).toBeTruthy();
  });

  it('rank should return 0 for exact match', () => {
    expect(service['rank']('bern', 'bern')).toBe(0);
  });
  it('rank should return 1 for prefix match', () => {
    expect(service['rank']('bern', 'bernried')).toBe(1);
  });
  it('rank should return 2 for substring match', () => {
    expect(service['rank']('bern', 'abernc')).toBe(2);
  });
  it('rank should return 3 for no match', () => {
    expect(service['rank']('bern', 'zurich')).toBe(3);
  });

  it('filterLocations should prioritize exact, then prefix, then substring', () => {
    const filtered = service.filterLocations('ber');
    expect(filtered[0].primaryLocationName.toLowerCase()).toBe('bern');
    expect(filtered.map((l) => l.primaryLocationName)).toContain('Bernried');
    expect(filtered.map((l) => l.primaryLocationName)).toContain('Bernau');
    expect(filtered.map((l) => l.primaryLocationName)).not.toContain('Zürich');
  });

  it('filterLocations should match abbreviation', () => {
    const filtered = service.filterLocations('bn');
    expect(filtered.some((l) => l.locationAbbreviation?.toLowerCase() === 'bn')).toBeTruthy();
  });

  it('filterLocations should exclude specified references', () => {
    const filtered = service.filterLocations('ber', ['CH00001']);
    expect(filtered.map((l) => l.locationReference)).not.toContain('CH00001');
    expect(filtered.map((l) => l.primaryLocationName)).toContain('Bernau');
  });

  it('filterLocations should return empty for query shorter than 2 chars', () => {
    expect(service.filterLocations('b')).toEqual([]);
    expect(service.filterLocations('')).toEqual([]);
  });

  it('getLocation should return location by reference', () => {
    expect(service.getLocation('CH00001')?.primaryLocationName).toBe('Bern');
    expect(service.getLocation('CH00004')?.primaryLocationName).toBe('Zürich');
  });

  it('getLocation should return undefined for unknown reference', () => {
    expect(service.getLocation('UNKNOWN')).toBeUndefined();
  });

  it('loaded should return true when locationsResource has value', () => {
    expect(service.loaded()).toBe(true);
  });

  it('loaded should return true when locationsResource has error', () => {
    (
      service as unknown as {
        locationsResource: {
          hasValue: () => boolean;
          value: () => { data: Location[] };
          error: () => unknown;
        };
      }
    ).locationsResource = {
      hasValue: () => false,
      value: () => ({ data: [] }),
      error: () => new Error('fail'),
    };
    expect(service.loaded()).toBe(true);
  });
});
