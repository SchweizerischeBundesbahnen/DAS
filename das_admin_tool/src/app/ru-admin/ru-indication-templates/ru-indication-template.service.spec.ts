import { HttpResourceRef } from '@angular/common/http';
import { TestBed } from '@angular/core/testing';
import { SbbDialogService } from '@sbb-esta/lyne-angular/dialog';
import { SbbOverlayCloseEvent } from '@sbb-esta/lyne-elements/overlay.js';
import { of, throwError } from 'rxjs';
import { RecentCompaniesStore } from '~shared/recent-companies.store';
import { ToastService } from '~shared/toast-service';
import { RuAdminApi, RuIndicationTemplate, RuIndicationTemplateApiResponse } from '../ru-admin-api';
import { RuIndicationTemplateDialogEditResult } from './ru-indication-template-dialog/ru-indication-template-dialog';
import { RuIndicationTemplateService } from './ru-indication-template.service';

const ruIndicationTemplate: RuIndicationTemplate = {
  id: 1,
  category: 'General',
  de: { title: 'Titel', text: 'Text' },
};

const mockRuAdminApi: Partial<RuAdminApi> = {
  putRuIndicationTemplate: () => of({} as RuIndicationTemplateApiResponse),
  postRuIndicationTemplate: () => of({} as RuIndicationTemplateApiResponse),
  deleteAllRuIndicationTemplate: () => of(undefined),
  ruIndicationTemplates: { reload: () => true } as HttpResourceRef<
    RuIndicationTemplateApiResponse | undefined
  >,
};

const mockToastService: Partial<ToastService> = {
  success: vi.fn(),
  error: vi.fn(),
};

const openSpy = vi.fn();

const mockSbbDialogService: Partial<SbbDialogService> = { open: openSpy };

function mockDialogResult(result: RuIndicationTemplateDialogEditResult | null): void {
  openSpy.mockReturnValue({
    afterClosed: of({ result } as SbbOverlayCloseEvent),
  });
}

describe('RuIndicationTemplateService', () => {
  let service: RuIndicationTemplateService;

  beforeEach(() => {
    vi.clearAllMocks();

    TestBed.configureTestingModule({
      providers: [
        RuIndicationTemplateService,
        { provide: RuAdminApi, useValue: mockRuAdminApi },
        { provide: SbbDialogService, useValue: mockSbbDialogService },
        { provide: ToastService, useValue: mockToastService },
        { provide: RecentCompaniesStore, useValue: {} },
      ],
    });

    service = TestBed.inject(RuIndicationTemplateService);
  });

  it('should be created', () => {
    expect(service).toBeTruthy();
  });

  it('edit should update ru indication template', async () => {
    const apiSpy = vi.spyOn(mockRuAdminApi, 'putRuIndicationTemplate');
    const toastSpy = vi.spyOn(mockToastService, 'success');
    mockDialogResult({
      ...ruIndicationTemplate,
      category: 'Updated',
    });

    await service.edit(ruIndicationTemplate);

    expect(toastSpy).toHaveBeenCalled();
    expect(apiSpy).toHaveBeenCalledWith(1, {
      id: 1,
      category: 'Updated',
      de: { title: 'Titel', text: 'Text' },
    });
  });

  it('edit with delete should delete ru indication template', async () => {
    const apiDeleteSpy = vi.spyOn(mockRuAdminApi, 'deleteAllRuIndicationTemplate');
    const successToastSpy = vi.spyOn(mockToastService, 'success');
    mockDialogResult('delete');

    await service.edit(ruIndicationTemplate);

    expect(successToastSpy).toHaveBeenCalled();
    expect(apiDeleteSpy).toHaveBeenCalledWith([ruIndicationTemplate.id]);
  });

  it('edit with dialog close should do nothing', async () => {
    const apiSpy = vi.spyOn(mockRuAdminApi, 'putRuIndicationTemplate');
    const successToastSpy = vi.spyOn(mockToastService, 'success');
    mockDialogResult(null);

    await service.edit(ruIndicationTemplate);

    expect(apiSpy).not.toHaveBeenCalled();
    expect(successToastSpy).not.toHaveBeenCalled();
  });

  it('edit failed should show error toast', async () => {
    vi.spyOn(mockRuAdminApi, 'putRuIndicationTemplate').mockReturnValueOnce(
      throwError(() => new Error('API error')),
    );
    const errorToastSpy = vi.spyOn(mockToastService, 'error');
    mockDialogResult({
      ...ruIndicationTemplate,
      category: 'Updated',
    });

    await service.edit(ruIndicationTemplate);

    expect(errorToastSpy).toHaveBeenCalled();
  });

  it('add should create ru indication template', async () => {
    const apiSpy = vi.spyOn(mockRuAdminApi, 'postRuIndicationTemplate');
    const successToastSpy = vi.spyOn(mockToastService, 'success');
    const templateToCreate: RuIndicationTemplate = {
      category: 'New',
      de: { title: 'Neu', text: 'Inhalt' },
    };
    mockDialogResult(templateToCreate);

    await service.add();

    expect(successToastSpy).toHaveBeenCalled();
    expect(apiSpy).toHaveBeenCalledWith(templateToCreate);
  });

  it('add with dialog close should do nothing', async () => {
    const apiSpy = vi.spyOn(mockRuAdminApi, 'postRuIndicationTemplate');
    mockDialogResult(null);

    await service.add();

    expect(apiSpy).not.toHaveBeenCalled();
  });

  it('deleteAll should delete by ids', async () => {
    const apiSpy = vi.spyOn(mockRuAdminApi, 'deleteAllRuIndicationTemplate');
    const successToastSpy = vi.spyOn(mockToastService, 'success');
    const templates: RuIndicationTemplate[] = [
      ruIndicationTemplate,
      {
        id: 2,
        category: 'Other',
        de: { title: 'Andere', text: 'Text' },
      },
    ];

    await service.deleteAll(templates);

    expect(apiSpy).toHaveBeenCalledWith([1, 2]);
    expect(successToastSpy).toHaveBeenCalled();
  });

  it('deleteAll failed should show error toast', async () => {
    vi.spyOn(mockRuAdminApi, 'deleteAllRuIndicationTemplate').mockReturnValueOnce(
      throwError(() => new Error('API error')),
    );
    const errorToastSpy = vi.spyOn(mockToastService, 'error');

    await service.deleteAll([ruIndicationTemplate]);

    expect(errorToastSpy).toHaveBeenCalled();
  });
});
