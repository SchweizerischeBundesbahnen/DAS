import {TestBed} from '@angular/core/testing';

import {LocationsApi} from './locations-api.service';

describe('LocationsApi', () => {
  let service: LocationsApi;

  beforeEach(() => {
    TestBed.configureTestingModule({});
    service = TestBed.inject(LocationsApi);
  });

  it('should be created', () => {
    expect(service).toBeTruthy();
  });
});
