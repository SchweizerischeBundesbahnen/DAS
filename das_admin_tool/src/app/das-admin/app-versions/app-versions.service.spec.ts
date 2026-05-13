import {TestBed} from '@angular/core/testing';

import {AppVersionsService} from './app-versions.service';
import {AppVersion, AppVersionApiResponse, DasAdminApi} from '../das-admin-api';
import {of, throwError} from 'rxjs';
import {SbbDialogService} from '@sbb-esta/lyne-angular/dialog';
import {ToastService} from '../../shared/toast-service';
import {toUtcDateOnly} from '../../shared/date-util';
import {HttpErrorResponse, HttpResourceRef} from '@angular/common/http';
import {VersionDialogEditResult} from './app-version-dialog/app-version-dialog';
import {SbbOverlayCloseEvent} from '@sbb-esta/lyne-elements/overlay.js';

const appVersion: AppVersion = {
  id: 1,
  version: '0.2.1',
  minimalVersion: false,
};

const mockDasAdminApi: Partial<DasAdminApi> = {
  putAppVersion: () => of({} as AppVersionApiResponse),
  deleteAppVersion: () => of(undefined),
  postAppVersion: () => of({} as AppVersionApiResponse),
  appVersions: {reload: () => true} as HttpResourceRef<AppVersionApiResponse | undefined>
};

const mockToastService: Partial<ToastService> = {
  success: vi.fn(),
  error: vi.fn()
};

const openSpy = vi.fn();

const mockSbbDialogService: Partial<SbbDialogService> = {open: openSpy};

function mockDialogResult(result: VersionDialogEditResult) {
  openSpy.mockReturnValue({
    afterClosed: of({result} as SbbOverlayCloseEvent)
  });
}

describe('AppVersionsService', () => {
  let service: AppVersionsService;

  beforeEach(() => {
    vi.clearAllMocks();

    TestBed.configureTestingModule({
      providers: [
        AppVersionsService,
        {provide: DasAdminApi, useValue: mockDasAdminApi},
        {provide: SbbDialogService, useValue: mockSbbDialogService},
        {provide: ToastService, useValue: mockToastService},
      ],
    });

    service = TestBed.inject(AppVersionsService);
  });

  it('should be created', () => {
    expect(service).toBeTruthy();
  });

  it('edit should update app version', async () => {
    const apiSpy = vi.spyOn(mockDasAdminApi, 'putAppVersion');
    const toastSpy = vi.spyOn(mockToastService, 'success');
    mockDialogResult({
      ...appVersion,
      version: '0.2.2',
      expiryDate: toUtcDateOnly(new Date('2026-03-20'))
    })

    await service.edit(appVersion);

    expect(toastSpy).toHaveBeenCalled();
    expect(apiSpy).toHaveBeenCalledWith(1, {
      id: 1,
      version: '0.2.2',
      minimalVersion: false,
      expiryDate: new Date('2026-03-20'),
    });

  });

  it('edit with delete should delete app version', async () => {
    const apiDeleteSpy = vi.spyOn(mockDasAdminApi, 'deleteAppVersion');
    const successToastSpy = vi.spyOn(mockToastService, 'success');
    mockDialogResult('delete');

    await service.edit(appVersion);

    expect(apiDeleteSpy).toHaveBeenCalledWith(appVersion.id);
    expect(successToastSpy).toHaveBeenCalled();
  });

  it('edit failed should show error toast', async () => {
    vi.spyOn(mockDasAdminApi, 'putAppVersion').mockReturnValueOnce(throwError(() => new Error('API error')));
    const errorToastSpy = vi.spyOn(mockToastService, 'error');
    mockDialogResult({...appVersion, version: '0.2.2'});

    await service.edit(appVersion);

    expect(errorToastSpy).toHaveBeenCalled();
  })

  it('edit 409 conflict should show conflict toast', async () => {
    vi.spyOn(mockDasAdminApi, 'putAppVersion').mockReturnValueOnce(
      throwError(() => new HttpErrorResponse({status: 409, error: {status: 409}}))
    );
    const errorToastSpy = vi.spyOn(mockToastService, 'error');
    mockDialogResult({...appVersion, version: '0.2.2'});

    await service.edit(appVersion);

    expect(errorToastSpy).toHaveBeenCalledWith(expect.stringContaining('existiert bereits'));
  });

  it('add should create app version', async () => {
    const apiSpy = vi.spyOn(mockDasAdminApi, 'postAppVersion');
    const successToastSpy = vi.spyOn(mockToastService, 'success');
    mockDialogResult({
      version: '2.4.0',
      minimalVersion: true
    });

    await service.add();

    expect(successToastSpy).toHaveBeenCalled();
    expect(apiSpy).toHaveBeenCalledWith({
      version: '2.4.0',
      minimalVersion: true,
    });
  });
});
