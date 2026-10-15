import { HttpResourceRef } from '@angular/common/http';
import { TestBed } from '@angular/core/testing';
import { SbbDialogService } from '@sbb-esta/lyne-angular/dialog';
import { SbbOverlayCloseEvent } from '@sbb-esta/lyne-elements/overlay.js';
import { of, throwError } from 'rxjs';
import { RecentCompaniesService } from '~shared/services/recent-companies.service';
import { ToastService } from '~shared/services/toast.service';
import { ExternalLink, ExternalLinkApiResponse, RuAdminApi } from '../ru-admin.api';
import { ExternalLinkDialogEditResult } from './external-link-dialog/external-link-dialog';
import { ExternalLinkService } from './external-link.service';

const externalLink: ExternalLink = {
  id: 1,
  companies: ['2185'],
  de: { title: 'Titel', link: 'https://sbb.ch' },
};

const mockRuAdminApi: Partial<RuAdminApi> = {
  postExternalLink: () => of({} as ExternalLinkApiResponse),
  putExternalLink: () => of({} as ExternalLinkApiResponse),
  deleteExternalLinksByIds: () => of(undefined),
  externalLinks: { reload: () => true } as HttpResourceRef<ExternalLinkApiResponse | undefined>,
};

const mockToastService: Partial<ToastService> = {
  success: vi.fn(),
  error: vi.fn(),
};

const openSpy = vi.fn();

const mockSbbDialogService: Partial<SbbDialogService> = { open: openSpy };

const mockRecentCompaniesService: Partial<RecentCompaniesService> = { save: vi.fn() };

function mockDialogResult(result: ExternalLinkDialogEditResult | null): void {
  openSpy.mockReturnValue({
    afterClosed: of({ result } as SbbOverlayCloseEvent),
  });
}

describe('ExternalLinkService', () => {
  let externalLinkService: ExternalLinkService;

  beforeEach(() => {
    vi.clearAllMocks();

    TestBed.configureTestingModule({
      providers: [
        ExternalLinkService,
        { provide: RuAdminApi, useValue: mockRuAdminApi },
        { provide: SbbDialogService, useValue: mockSbbDialogService },
        { provide: ToastService, useValue: mockToastService },
        { provide: RecentCompaniesService, useValue: mockRecentCompaniesService },
      ],
    });

    externalLinkService = TestBed.inject(ExternalLinkService);
  });

  it('edit should update external link', async () => {
    const apiSpy = vi.spyOn(mockRuAdminApi, 'putExternalLink');
    const successToastSpy = vi.spyOn(mockToastService, 'success');
    mockDialogResult({ ...externalLink, companies: ['1080', '2185'] });

    await externalLinkService.edit(externalLink);

    expect(successToastSpy).toHaveBeenCalled();
    expect(apiSpy).toHaveBeenCalledWith(1, {
      id: 1,
      companies: ['1080', '2185'],
      de: { title: 'Titel', link: 'https://sbb.ch' },
    });
    expect(mockRecentCompaniesService.save).toHaveBeenCalledWith(['1080', '2185']);
  });

  it('edit with delete should delete external link', async () => {
    const apiDeleteSpy = vi.spyOn(mockRuAdminApi, 'deleteExternalLinksByIds');
    const successToastSpy = vi.spyOn(mockToastService, 'success');
    mockDialogResult('delete');

    await externalLinkService.edit(externalLink);

    expect(successToastSpy).toHaveBeenCalled();
    expect(apiDeleteSpy).toHaveBeenCalledWith([externalLink.id]);
  });

  it('edit with dialog close should do nothing', async () => {
    const apiSpy = vi.spyOn(mockRuAdminApi, 'putExternalLink');
    const successToastSpy = vi.spyOn(mockToastService, 'success');
    mockDialogResult(null);

    await externalLinkService.edit(externalLink);

    expect(apiSpy).not.toHaveBeenCalled();
    expect(successToastSpy).not.toHaveBeenCalled();
  });

  it('edit failed should show error toast', async () => {
    vi.spyOn(mockRuAdminApi, 'putExternalLink').mockReturnValueOnce(
      throwError(() => new Error('API error')),
    );
    const errorToastSpy = vi.spyOn(mockToastService, 'error');
    mockDialogResult({ ...externalLink, companies: ['1080', '2185'] });

    await externalLinkService.edit(externalLink);

    expect(errorToastSpy).toHaveBeenCalled();
  });

  it('add should create external link', async () => {
    const apiSpy = vi.spyOn(mockRuAdminApi, 'postExternalLink');
    const successToastSpy = vi.spyOn(mockToastService, 'success');
    const newExternalLink: ExternalLink = {
      id: 1,
      companies: ['2185'],
      de: { title: 'Titel', link: 'https://sbb.ch' },
    };
    mockDialogResult(newExternalLink);

    await externalLinkService.add();

    expect(successToastSpy).toHaveBeenCalled();
    expect(apiSpy).toHaveBeenCalledWith(newExternalLink);
  });

  it('add with dialog close should do nothing', async () => {
    const apiSpy = vi.spyOn(mockRuAdminApi, 'postExternalLink');
    mockDialogResult(null);

    await externalLinkService.add();

    expect(apiSpy).not.toHaveBeenCalled();
  });

  it('deleteAllByIds should delete by ids', async () => {
    const apiSpy = vi.spyOn(mockRuAdminApi, 'deleteExternalLinksByIds');
    const successToastSpy = vi.spyOn(mockToastService, 'success');

    await externalLinkService.deleteAllByIds([1, 2]);

    expect(apiSpy).toHaveBeenCalledWith([1, 2]);
    expect(successToastSpy).toHaveBeenCalled();
  });

  it('deleteAll failed should show error toast', async () => {
    vi.spyOn(mockRuAdminApi, 'deleteExternalLinksByIds').mockReturnValueOnce(
      throwError(() => new Error('API error')),
    );
    const errorToastSpy = vi.spyOn(mockToastService, 'error');

    await externalLinkService.deleteAllByIds([1]);

    expect(errorToastSpy).toHaveBeenCalled();
  });
});
