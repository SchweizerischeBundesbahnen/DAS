import { TestBed } from '@angular/core/testing';
import { ToastService } from '~shared/services/toast.service';
import { Location, LocationApi } from './location.api';

const locations: Location[] = [
  { primaryLocationName: 'Bern', locationAbbreviation: 'BN', locationReference: 'CH00001' },
  { primaryLocationName: 'Bernau', locationAbbreviation: 'BAU', locationReference: 'DE00002' },
  { primaryLocationName: 'Bernried', locationAbbreviation: 'BRD', locationReference: 'DE00003' },
  { primaryLocationName: 'Zürich', locationAbbreviation: 'ZH', locationReference: 'CH00004' },
  { primaryLocationName: 'Winterthur', locationAbbreviation: 'WT', locationReference: 'CH00005' },
  { primaryLocationName: 'Luzern', locationAbbreviation: 'LU', locationReference: 'CH00007' },
];

describe('LocationApi', () => {
  let locationApi: LocationApi;
  beforeEach(() => {
    TestBed.configureTestingModule({
      providers: [LocationApi, { provide: ToastService, useValue: { error: vi.fn() } }],
    });

    locationApi = TestBed.inject(LocationApi);

    (
      locationApi as unknown as {
        locationsResource: {
          hasValue: () => boolean;
          value: () => { data: Location[] };
          error: () => unknown;
        };
      }
    ).locationsResource = {
      hasValue: () => true,
      value: () => ({ data: locations }),
      error: vi.fn(),
    };
  });

  it('should be created', () => {
    expect(locationApi).toBeTruthy();
  });

  it('rank should return 0 for exact match', () => {
    expect(locationApi['rank']('bern', 'bern')).toBe(0);
  });
  it('rank should return 1 for prefix match', () => {
    expect(locationApi['rank']('bern', 'bernried')).toBe(1);
  });
  it('rank should return 2 for substring match', () => {
    expect(locationApi['rank']('bern', 'abernc')).toBe(2);
  });
  it('rank should return 3 for no match', () => {
    expect(locationApi['rank']('bern', 'zurich')).toBe(3);
  });

  it('filterLocations should prioritize exact, then prefix, then substring', () => {
    const filtered = locationApi.filterLocations('ber');
    expect(filtered[0].primaryLocationName.toLowerCase()).toBe('bern');
    expect(filtered.map((l) => l.primaryLocationName)).toContain('Bernried');
    expect(filtered.map((l) => l.primaryLocationName)).toContain('Bernau');
    expect(filtered.map((l) => l.primaryLocationName)).not.toContain('Zürich');
  });

  it('filterLocations should match abbreviation', () => {
    const filtered = locationApi.filterLocations('bn');
    expect(filtered.some((l) => l.locationAbbreviation?.toLowerCase() === 'bn')).toBeTruthy();
  });

  it('filterLocations should exclude specified references', () => {
    const filtered = locationApi.filterLocations('ber', ['CH00001']);
    expect(filtered.map((l) => l.locationReference)).not.toContain('CH00001');
    expect(filtered.map((l) => l.primaryLocationName)).toContain('Bernau');
  });

  it('filterLocations should return empty for query shorter than 2 chars', () => {
    expect(locationApi.filterLocations('b')).toEqual([]);
    expect(locationApi.filterLocations('')).toEqual([]);
  });

  it('getLocation should return location by reference', () => {
    expect(locationApi.getLocation('CH00001')?.primaryLocationName).toBe('Bern');
    expect(locationApi.getLocation('CH00004')?.primaryLocationName).toBe('Zürich');
  });

  it('getLocation should return undefined for unknown reference', () => {
    expect(locationApi.getLocation('UNKNOWN')).toBeUndefined();
  });

  it('loaded should return true when locationsResource has value', () => {
    expect(locationApi.loaded()).toBe(true);
  });

  it('loaded should return true when locationsResource has error', () => {
    (
      locationApi as unknown as {
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
    expect(locationApi.loaded()).toBe(true);
  });
});
