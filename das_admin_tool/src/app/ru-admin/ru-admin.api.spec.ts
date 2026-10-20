import { TestBed } from '@angular/core/testing';
import { RuAdminApi } from './ru-admin.api';

describe('RuAdminApi', () => {
  let ruAdminApi: RuAdminApi;

  beforeEach(() => {
    TestBed.configureTestingModule({});
    ruAdminApi = TestBed.inject(RuAdminApi);
  });

  it('should be created', () => {
    expect(ruAdminApi).toBeTruthy();
  });
});
