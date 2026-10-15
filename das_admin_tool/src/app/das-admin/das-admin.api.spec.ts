import { TestBed } from '@angular/core/testing';
import { DasAdminApi } from './das-admin.api';

describe('DasAdminApi', () => {
  let dasAdminApi: DasAdminApi;

  beforeEach(() => {
    TestBed.configureTestingModule({});
    dasAdminApi = TestBed.inject(DasAdminApi);
  });

  it('should be created', () => {
    expect(dasAdminApi).toBeTruthy();
  });
});
