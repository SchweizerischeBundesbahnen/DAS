import {ComponentFixture, TestBed} from '@angular/core/testing';

import {LocationsInput} from './locations-input.component';
import {Location, LocationApiResponse, LocationsApi} from './locations-api.service';
import {HttpResourceRef} from "@angular/common/http";

const mockLocationsApi: Partial<LocationsApi> = {
  locations: {value: () => undefined} as HttpResourceRef<LocationApiResponse | undefined>
}

describe('LocationsInput', () => {
  let component: LocationsInput;
  let fixture: ComponentFixture<LocationsInput>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [LocationsInput],
      providers: [{provide: LocationsApi, useValue: mockLocationsApi}]
    })
      .compileComponents();

    fixture = TestBed.createComponent(LocationsInput);
    component = fixture.componentInstance;
    await fixture.whenStable();
  });

  const locations: Location[] = [
    {primaryLocationName: 'Bern', locationAbbreviation: 'BN', locationReference: 'CH00001'},
    {primaryLocationName: 'Bernau', locationAbbreviation: 'BAU', locationReference: 'DE00002'},
    {primaryLocationName: 'Bernried', locationAbbreviation: 'BRD', locationReference: 'DE00003'},
    {primaryLocationName: 'Zürich', locationAbbreviation: 'ZH', locationReference: 'CH00004'},
    {primaryLocationName: 'Winterthur', locationAbbreviation: 'WT', locationReference: 'CH00005'},
    {primaryLocationName: 'Luzern', locationAbbreviation: 'LU', locationReference: 'CH00007'},
  ];

  it('should create', () => {
    expect(component).toBeTruthy();
  });

  it('rank should return 0 for exact match', () => {
    expect(component['rank']('bern', 'bern')).toBe(0);
  });
  it('rank should return 1 for prefix match', () => {
    expect(component['rank']('bern', 'bernried')).toBe(1);
  });
  it('rank should return 2 for substring match', () => {
    expect(component['rank']('bern', 'abernc')).toBe(2);
  });
  it('rank should return 3 for no match', () => {
    expect(component['rank']('bern', 'zurich')).toBe(3);
  });

  it('filterLocations should prioritize exact, then prefix, then substring', () => {
    const filtered = component['filterLocations']('ber', locations);
    expect(filtered[0].primaryLocationName.toLowerCase()).toBe('bern');
    expect(filtered.map(l => l.primaryLocationName)).toContain('Bernried');
    expect(filtered.map(l => l.primaryLocationName)).toContain('Bernau');
    expect(filtered.map(l => l.primaryLocationName)).not.toContain('Zürich');
  });

  it('filterLocations should match abbreviation', () => {
    const filtered = component['filterLocations']('bn', locations);
    expect(filtered.some(l => l.locationAbbreviation?.toLowerCase() === 'bn')).toBeTruthy();
  });
});
