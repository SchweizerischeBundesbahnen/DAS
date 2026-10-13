import { HttpResourceRef } from '@angular/common/http';
import { TestBed } from '@angular/core/testing';
import { SbbDialogService } from '@sbb-esta/lyne-angular/dialog';
import { SbbOverlayCloseEvent } from '@sbb-esta/lyne-elements/overlay.js';
import { of, throwError } from 'rxjs';
import { RecentCompaniesService } from '~shared/services/recent-companies.service';
import { ToastService } from '~shared/services/toast.service';
import { RuAdminApi, RuFeature, RuFeatureApiResponse } from '../ru-admin.api';
import { RuFeatureDialogEditResult } from './ru-feature-toggle-dialog/ru-feature-toggle-dialog';
import { RuFeatureToggleService } from './ru-feature-toggle.service';

const ruFeature: RuFeature = {
  id: 1,
  companyCode: '1085',
  key: 'WARNAPP',
  enabled: true,
};

const mockRuAdminApi: Partial<RuAdminApi> = {
  putRuFeature: () => of({} as RuFeatureApiResponse),
  postRuFeature: () => of({} as RuFeatureApiResponse),
  deleteRuFeaturesByIds: () => of(undefined),
  ruFeatures: { reload: () => true } as HttpResourceRef<RuFeatureApiResponse | undefined>,
};

const mockToastService: Partial<ToastService> = {
  success: vi.fn(),
  error: vi.fn(),
};

const openSpy = vi.fn();

const mockSbbDialogService: Partial<SbbDialogService> = { open: openSpy };

const mockRecentCompaniesService: Partial<RecentCompaniesService> = {
  save: vi.fn(),
};

function mockDialogResult(result: RuFeatureDialogEditResult | null): void {
  openSpy.mockReturnValue({
    afterClosed: of({ result } as SbbOverlayCloseEvent),
  });
}

describe('RuFeatureToggleService', () => {
  let ruFeatureToggleService: RuFeatureToggleService;

  beforeEach(() => {
    vi.clearAllMocks();

    TestBed.configureTestingModule({
      providers: [
        RuFeatureToggleService,
        { provide: RuAdminApi, useValue: mockRuAdminApi },
        { provide: SbbDialogService, useValue: mockSbbDialogService },
        { provide: ToastService, useValue: mockToastService },
        { provide: RecentCompaniesService, useValue: mockRecentCompaniesService },
      ],
    });

    ruFeatureToggleService = TestBed.inject(RuFeatureToggleService);
  });

  it('should be created', () => {
    expect(ruFeatureToggleService).toBeTruthy();
  });

  it('edit should update ru feature', async () => {
    const apiSpy = vi.spyOn(mockRuAdminApi, 'putRuFeature');
    const toastSpy = vi.spyOn(mockToastService, 'success');
    const recentCompaniesSaveSpy = vi.spyOn(mockRecentCompaniesService, 'save');
    mockDialogResult({ ...ruFeature, enabled: false });

    await ruFeatureToggleService.edit(ruFeature);

    expect(toastSpy).toHaveBeenCalled();
    expect(apiSpy).toHaveBeenCalledWith(1, {
      id: 1,
      companyCode: '1085',
      key: 'WARNAPP',
      enabled: false,
    });
    expect(recentCompaniesSaveSpy).toHaveBeenCalledWith(['1085']);
  });

  it('edit with delete should delete ru feature by id', async () => {
    const apiDeleteSpy = vi.spyOn(mockRuAdminApi, 'deleteRuFeaturesByIds');
    const successToastSpy = vi.spyOn(mockToastService, 'success');
    const recentCompaniesSaveSpy = vi.spyOn(mockRecentCompaniesService, 'save');
    mockDialogResult('delete');

    await ruFeatureToggleService.edit(ruFeature);

    expect(successToastSpy).toHaveBeenCalled();
    expect(apiDeleteSpy).toHaveBeenCalledWith([1]);
    expect(recentCompaniesSaveSpy).not.toHaveBeenCalled();
  });

  it('edit with dialog close should do nothing', async () => {
    const apiSpy = vi.spyOn(mockRuAdminApi, 'putRuFeature');
    const successToastSpy = vi.spyOn(mockToastService, 'success');
    mockDialogResult(null);

    await ruFeatureToggleService.edit(ruFeature);

    expect(apiSpy).not.toHaveBeenCalled();
    expect(successToastSpy).not.toHaveBeenCalled();
  });

  it('edit failed should show error toast', async () => {
    vi.spyOn(mockRuAdminApi, 'putRuFeature').mockReturnValueOnce(
      throwError(() => new Error('API error')),
    );
    const errorToastSpy = vi.spyOn(mockToastService, 'error');
    mockDialogResult({ ...ruFeature, enabled: false });

    await ruFeatureToggleService.edit(ruFeature);

    expect(errorToastSpy).toHaveBeenCalled();
  });

  it('add should create ru feature', async () => {
    const apiSpy = vi.spyOn(mockRuAdminApi, 'postRuFeature');
    const successToastSpy = vi.spyOn(mockToastService, 'success');
    const recentCompaniesSaveSpy = vi.spyOn(mockRecentCompaniesService, 'save');
    const featureToCreate: RuFeature = {
      companyCode: '1087',
      key: 'CHECKLIST_DEPARTURE_PROCESS',
      enabled: true,
    };
    mockDialogResult(featureToCreate);

    await ruFeatureToggleService.add();

    expect(successToastSpy).toHaveBeenCalled();
    expect(apiSpy).toHaveBeenCalledWith(featureToCreate);
    expect(recentCompaniesSaveSpy).toHaveBeenCalledWith(['1087']);
  });

  it('add with dialog close should do nothing', async () => {
    const apiSpy = vi.spyOn(mockRuAdminApi, 'postRuFeature');
    const recentCompaniesSaveSpy = vi.spyOn(mockRecentCompaniesService, 'save');
    mockDialogResult(null);

    await ruFeatureToggleService.add();

    expect(apiSpy).not.toHaveBeenCalled();
    expect(recentCompaniesSaveSpy).not.toHaveBeenCalled();
  });
});
