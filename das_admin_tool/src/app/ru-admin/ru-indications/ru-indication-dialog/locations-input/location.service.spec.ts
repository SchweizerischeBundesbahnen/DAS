import { TestBed } from '@angular/core/testing';

import { Location, LocationService } from './location.service';

const locations: Location[] = [
  {primaryLocationName: 'Bern', locationAbbreviation: 'BN', locationReference: 'CH00001'},
  {primaryLocationName: 'Bernau', locationAbbreviation: 'BAU', locationReference: 'DE00002'},
  {primaryLocationName: 'Bernried', locationAbbreviation: 'BRD', locationReference: 'DE00003'},
  {primaryLocationName: 'Zürich', locationAbbreviation: 'ZH', locationReference: 'CH00004'},
  {primaryLocationName: 'Winterthur', locationAbbreviation: 'WT', locationReference: 'CH00005'},
  {primaryLocationName: 'Luzern', locationAbbreviation: 'LU', locationReference: 'CH00007'},
];

describe('LocationService', () => {
  let service: LocationService;
  beforeEach(async () => {
    TestBed.configureTestingModule({
      providers: [LocationService]
    });

    service = TestBed.inject(LocationService);

    ((service as unknown) as {
      locationsRessource: { hasValue: () => boolean; value: () => { data: Location[] } }
    }).locationsRessource = {hasValue: () => true, value: () => ({data: locations})};
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
    expect(filtered.map(l => l.primaryLocationName)).toContain('Bernried');
    expect(filtered.map(l => l.primaryLocationName)).toContain('Bernau');
    expect(filtered.map(l => l.primaryLocationName)).not.toContain('Zürich');
  });

  it('filterLocations should match abbreviation', () => {
    const filtered = service.filterLocations('bn');
    expect(filtered.some(l => l.locationAbbreviation?.toLowerCase() === 'bn')).toBeTruthy();
  });
});
