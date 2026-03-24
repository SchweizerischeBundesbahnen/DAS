import { TestBed } from '@angular/core/testing';

import { DasAdminApi } from './das-admin-api';

describe('DasAdminApi', () => {
  let service: DasAdminApi;

  beforeEach(() => {
    TestBed.configureTestingModule({});
    service = TestBed.inject(DasAdminApi);
  });

  it('should be created', () => {
    expect(service).toBeTruthy();
  });
});
