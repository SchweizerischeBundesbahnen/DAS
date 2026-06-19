import { TestBed } from '@angular/core/testing';
import { RecentCompaniesStore } from './recent-companies.store';
import { AuthService } from './auth-service';

describe('RecentCompaniesStore', () => {
  let store: RecentCompaniesStore;

  beforeEach(() => {
    localStorage.clear();

    TestBed.configureTestingModule({
      providers: [
        RecentCompaniesStore,
        { provide: AuthService, useValue: { oid: () => 'test-oid' } },
      ],
    });

    store = TestBed.inject(RecentCompaniesStore);
  });

  it('should return empty list if nothing is stored', () => {
    expect(store.get()).toEqual([]);
  });

  it('should keep latest selected companies', () => {
    store.save(['1085', '1087']);

    expect(store.get()).toEqual(['1085', '1087']);
  });

  it('should override latest selected companies', () => {
    store.save(['1085', '1087']);
    store.save(['1265', '8925']);

    expect(store.get()).toEqual(['1265', '8925']);
  });
});
