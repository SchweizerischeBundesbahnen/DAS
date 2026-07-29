import { HttpResourceRef } from '@angular/common/http';
import { TestBed } from '@angular/core/testing';
import { SbbDialogService } from '@sbb-esta/lyne-angular/dialog';
import { SbbOverlayCloseEvent } from '@sbb-esta/lyne-elements/overlay.pure.js';
import { of, throwError } from 'rxjs';
import { RecentCompaniesStore } from '~shared/recent-companies.store';
import { ToastService } from '~shared/toast-service';
import { DasAdminApi, InternalCompany, InternalCompanyApiResponse } from '../das-admin-api';
import { CompanyDialogEditResult } from './company-dialog/company-dialog';
import { CompanyService } from './company.service';

const company: InternalCompany = {
  id: 1,
  code: '9999',
  shortName: 'TEST',
  tenantId: '2cda5d11-f0ac-46b3-967d-af1b2e1bd01a',
};

const mockDasAdminApi: Partial<DasAdminApi> = {
  postCompany: () => of({} as InternalCompanyApiResponse),
  putCompany: () => of({} as InternalCompanyApiResponse),
  deleteCompanyById: () => of(undefined),
  companiesResource: { reload: () => true } as HttpResourceRef<
    InternalCompanyApiResponse | undefined
  >,
};

const mockToastService: Partial<ToastService> = { success: vi.fn(), error: vi.fn() };

const mockRecentCompaniesStore: Partial<RecentCompaniesStore> = { save: vi.fn() };

const openSpy = vi.fn();

const mockSbbDialogService: Partial<SbbDialogService> = { open: openSpy };

function mockDialogResult(result: CompanyDialogEditResult) {
  openSpy.mockReturnValue({ afterClosed: of({ result } as SbbOverlayCloseEvent) });
}

describe('CompanyService', () => {
  let service: CompanyService;

  beforeEach(() => {
    vi.clearAllMocks();

    TestBed.configureTestingModule({
      providers: [
        { provide: DasAdminApi, useValue: mockDasAdminApi },
        { provide: SbbDialogService, useValue: mockSbbDialogService },
        { provide: ToastService, useValue: mockToastService },
        { provide: RecentCompaniesStore, useValue: mockRecentCompaniesStore },
      ],
    });
    service = TestBed.inject(CompanyService);
  });

  it('should be created', () => {
    expect(service).toBeTruthy();
  });

  it('edit should update company', async () => {
    const apiSpy = vi.spyOn(mockDasAdminApi, 'putCompany');
    const toastSpy = vi.spyOn(mockToastService, 'success');
    mockDialogResult(company);

    await service.edit(company);

    expect(apiSpy).toHaveBeenCalledWith(1, {
      id: 1,
      code: '9999',
      shortName: 'TEST',
      tenantId: '2cda5d11-f0ac-46b3-967d-af1b2e1bd01a',
    });
    expect(toastSpy).toHaveBeenCalled();
  });

  it('edit with delete should delete company', async () => {
    const apiSpy = vi.spyOn(mockDasAdminApi, 'deleteCompanyById');
    const toastSpy = vi.spyOn(mockToastService, 'success');
    mockDialogResult('delete');

    await service.edit(company);

    expect(apiSpy).toHaveBeenCalledWith(company.id);
    expect(toastSpy).toHaveBeenCalled();
  });

  it('edit failed should show error toast', async () => {
    vi.spyOn(mockDasAdminApi, 'putCompany').mockReturnValueOnce(
      throwError(() => new Error('API error')),
    );
    const errorToastSpy = vi.spyOn(mockToastService, 'error');
    mockDialogResult(company);

    await service.edit(company);

    expect(errorToastSpy).toHaveBeenCalled();
  });

  it('add should create app version', async () => {
    const apiSpy = vi.spyOn(mockDasAdminApi, 'postCompany');
    const toastSpy = vi.spyOn(mockToastService, 'success');
    mockDialogResult(company);

    await service.add();

    expect(apiSpy).toHaveBeenCalledWith(company);
    expect(toastSpy).toHaveBeenCalled();
  });
});
