import { ComponentFixture, TestBed } from '@angular/core/testing';
import { FormControl } from '@angular/forms';

import { LocationsInput } from './locations-input.component';
import { Location, LocationService } from './location.service';

const mockLocations: Location[] = [
  { locationReference: 'LOC1', primaryLocationName: 'Bern', locationAbbreviation: 'BRN' },
  { locationReference: 'LOC2', primaryLocationName: 'Zürich', locationAbbreviation: 'ZH' },
  { locationReference: 'LOC3', primaryLocationName: 'Basel', locationAbbreviation: 'BS' },
];

const mockLocationService = {
  filterLocations: (query: string, excluded: string[] = []) => {
    const q = query.trim().toLowerCase();
    if (q.length < 2) return [];
    return mockLocations.filter(
      (l) =>
        (l.primaryLocationName?.toLowerCase().includes(q)
          || l.locationAbbreviation?.toLowerCase().includes(q))
        && !excluded.includes(l.locationReference),
    );
  },
  getLocation: (ref: string) => mockLocations.find((l) => l.locationReference === ref),
};

describe('LocationsInput', () => {
  let component: LocationsInput;
  let fixture: ComponentFixture<LocationsInput>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [LocationsInput],
      providers: [{ provide: LocationService, useValue: mockLocationService }],
    }).compileComponents();

    fixture = TestBed.createComponent(LocationsInput);
    component = fixture.componentInstance;
    const control = new FormControl<string[]>([], { nonNullable: true });
    fixture.componentRef.setInput('control', control);
    await fixture.whenStable();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });

  it('should show suggestions when query has at least 2 chars', () => {
    component.inputControl.setValue('be');
    const refs = component.filteredLocations().map((l) => l.locationReference);
    expect(refs).toEqual(['LOC1']);
  });

  it('should not include excluded locations in suggestions', () => {
    const control = new FormControl<string[]>(['LOC1'], { nonNullable: true });
    fixture.componentRef.setInput('control', control);
    component.inputControl.setValue('be');
    const refs = component.filteredLocations().map((l) => l.locationReference);
    expect(refs).toEqual([]);
  });

  it('locationToName should return primary name or fallback to reference', () => {
    expect(component['locationToName']('LOC2')).toBe('Zürich');
    expect(component['locationToName']('UNKNOWN')).toBe('UNKNOWN');
  });
});
