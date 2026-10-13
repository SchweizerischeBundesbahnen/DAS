import { TestBed } from '@angular/core/testing';
import { AuthService } from './auth.service';
import { RecentCompaniesService } from './recent-companies.service';

describe('RecentCompaniesService', () => {
  let recentCompaniesService: RecentCompaniesService;

  beforeEach(() => {
    localStorage.clear();

    TestBed.configureTestingModule({
      providers: [
        RecentCompaniesService,
        { provide: AuthService, useValue: { oid: () => 'test-oid' } },
      ],
    });

    recentCompaniesService = TestBed.inject(RecentCompaniesService);
  });

  it('should return empty list if nothing is stored', () => {
    expect(recentCompaniesService.get()).toEqual([]);
  });

  it('should keep latest selected companies', () => {
    recentCompaniesService.save(['1085', '1087']);

    expect(recentCompaniesService.get()).toEqual(['1085', '1087']);
  });

  it('should override latest selected companies', () => {
    recentCompaniesService.save(['1085', '1087']);
    recentCompaniesService.save(['1265', '8925']);

    expect(recentCompaniesService.get()).toEqual(['1265', '8925']);
  });
});
