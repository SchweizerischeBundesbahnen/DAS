import {TestBed} from '@angular/core/testing';

import {RuAdminApi} from './ru-admin-api';

describe('DasAdminApi', () => {
  let service: RuAdminApi;

  beforeEach(() => {
    TestBed.configureTestingModule({});
    service = TestBed.inject(RuAdminApi);
  });

  it('should be created', () => {
    expect(service).toBeTruthy();
  });
});
