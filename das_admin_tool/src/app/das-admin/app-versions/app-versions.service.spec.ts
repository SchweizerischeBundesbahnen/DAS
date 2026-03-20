import {TestBed} from '@angular/core/testing';

import {AppVersionsService} from './app-versions.service';
import {AppVersion, DasAdminApi, Response} from '../das-admin-api';
import {of} from 'rxjs';
import {SbbDialogService} from '@sbb-esta/lyne-angular/dialog';
import {ToastService} from '../../shared/toast-service';
import {toUtcDateOnly} from '../../shared/date-util';
import {HttpResourceRef} from '@angular/common/http';
import {VersionDialogEditResult} from './app-version-dialog/app-version-dialog';

const appVersion: AppVersion = {
  id: 1,
  version: '0.2.1',
  minimalVersion: false,
};

const mockDasAdminApi: Partial<DasAdminApi> = {
  putAppVersion: () => of({} as Response),
  deleteAppVersion: () => of(),
  postAppVersion: () => of({} as Response),
  appVersions: {reload: () => true} as HttpResourceRef<Response | undefined>
};

const mockToastService: Partial<ToastService> = {
  success: vi.fn(),
  error: vi.fn()
}

const openSpy = vi.fn();

const mockSbbDialogService: Partial<SbbDialogService> = {open: openSpy};

function mockDialogResult(result: VersionDialogEditResult) {
  openSpy.mockReturnValue({afterClosed: of({result})});
}

describe('AppVersionsService', () => {
  let service: AppVersionsService;

  beforeEach(() => {

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
    mockDialogResult("delete");

    await service.edit(appVersion);

    expect(successToastSpy).toHaveBeenCalled();
    expect(apiDeleteSpy).toHaveBeenCalledWith(appVersion.id);
  });

  it('edit failed should show error toast', async () => {
    const apiSpy = vi.spyOn(mockDasAdminApi, 'putAppVersion');
    const errorToastSpy = vi.spyOn(mockToastService, 'error');
    apiSpy.mockThrowOnce(new Error('API error'));

    await service.edit(appVersion);

    expect(errorToastSpy).toHaveBeenCalled();
  })

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
