import {TestBed} from '@angular/core/testing';

import {NoticeTemplateService} from './notice-template.service';
import {NoticeTemplate, NoticeTemplateApiResponse, RuAdminApi} from '../ru-admin-api';
import {SbbDialogService} from '@sbb-esta/lyne-angular/dialog';
import {ToastService} from '../../shared/toast-service';
import {HttpResourceRef} from '@angular/common/http';
import {of, throwError} from 'rxjs';
import {NoticeTemplateDialogEditResult} from './notice-template-dialog/notice-template-dialog';
import {SbbOverlayCloseEvent} from '@sbb-esta/lyne-elements/overlay.js';

const noticeTemplate: NoticeTemplate = {
  id: 1,
  category: 'General',
  de: {title: 'Titel', text: 'Text'},
};

const mockRuAdminApi: Partial<RuAdminApi> = {
  putNoticeTemplate: () => of({} as NoticeTemplateApiResponse),
  deleteNoticeTemplate: () => of(undefined),
  postNoticeTemplate: () => of({} as NoticeTemplateApiResponse),
  deleteAllNoticeTemplate: () => of(undefined),
  noticeTemplates: {reload: () => true} as HttpResourceRef<NoticeTemplateApiResponse | undefined>,
};

const mockToastService: Partial<ToastService> = {
  success: vi.fn(),
  error: vi.fn()
};

const openSpy = vi.fn();

const mockSbbDialogService: Partial<SbbDialogService> = {open: openSpy};

function mockDialogResult(result: NoticeTemplateDialogEditResult | null): void {
  openSpy.mockReturnValue({
    afterClosed: of({result} as SbbOverlayCloseEvent)
  });
}

describe('NoticeTemplateService', () => {
  let service: NoticeTemplateService;

  beforeEach(() => {
    vi.clearAllMocks();

    TestBed.configureTestingModule({
      providers: [
        NoticeTemplateService,
        {provide: RuAdminApi, useValue: mockRuAdminApi},
        {provide: SbbDialogService, useValue: mockSbbDialogService},
        {provide: ToastService, useValue: mockToastService},
      ],
    });

    service = TestBed.inject(NoticeTemplateService);
  });

  it('should be created', () => {
    expect(service).toBeTruthy();
  });

  it('edit should update notice template', async () => {
    const apiSpy = vi.spyOn(mockRuAdminApi, 'putNoticeTemplate');
    const toastSpy = vi.spyOn(mockToastService, 'success');
    mockDialogResult({
      ...noticeTemplate,
      category: 'Updated',
    });

    await service.edit(noticeTemplate);

    expect(toastSpy).toHaveBeenCalled();
    expect(apiSpy).toHaveBeenCalledWith(1, {
      id: 1,
      category: 'Updated',
      de: {title: 'Titel', text: 'Text'},
    });
  });

  it('edit with delete should delete notice template', async () => {
    const apiDeleteSpy = vi.spyOn(mockRuAdminApi, 'deleteNoticeTemplate');
    const successToastSpy = vi.spyOn(mockToastService, 'success');
    mockDialogResult('delete');

    await service.edit(noticeTemplate);

    expect(successToastSpy).toHaveBeenCalled();
    expect(apiDeleteSpy).toHaveBeenCalledWith(noticeTemplate.id);
  });

  it('edit with dialog close should do nothing', async () => {
    const apiSpy = vi.spyOn(mockRuAdminApi, 'putNoticeTemplate');
    const successToastSpy = vi.spyOn(mockToastService, 'success');
    mockDialogResult(null);

    await service.edit(noticeTemplate);

    expect(apiSpy).not.toHaveBeenCalled();
    expect(successToastSpy).not.toHaveBeenCalled();
  });

  it('edit failed should show error toast', async () => {
    vi.spyOn(mockRuAdminApi, 'putNoticeTemplate').mockReturnValueOnce(throwError(() => new Error('API error')));
    const errorToastSpy = vi.spyOn(mockToastService, 'error');
    mockDialogResult({...noticeTemplate, category: 'Updated'});

    await service.edit(noticeTemplate);

    expect(errorToastSpy).toHaveBeenCalled();
  });

  it('add should create notice template', async () => {
    const apiSpy = vi.spyOn(mockRuAdminApi, 'postNoticeTemplate');
    const successToastSpy = vi.spyOn(mockToastService, 'success');
    const templateToCreate: NoticeTemplate = {
      category: 'New',
      de: {title: 'Neu', text: 'Inhalt'},
    };
    mockDialogResult(templateToCreate);

    await service.add();

    expect(successToastSpy).toHaveBeenCalled();
    expect(apiSpy).toHaveBeenCalledWith(templateToCreate);
  });

  it('add with dialog close should do nothing', async () => {
    const apiSpy = vi.spyOn(mockRuAdminApi, 'postNoticeTemplate');
    mockDialogResult(null);

    await service.add();

    expect(apiSpy).not.toHaveBeenCalled();
  });

  it('deleteAll should delete by ids', async () => {
    const apiSpy = vi.spyOn(mockRuAdminApi, 'deleteAllNoticeTemplate');
    const successToastSpy = vi.spyOn(mockToastService, 'success');
    const templates: NoticeTemplate[] = [
      noticeTemplate,
      {id: 2, category: 'Other', de: {title: 'Andere', text: 'Text'}},
    ];

    await service.deleteAll(templates);

    expect(apiSpy).toHaveBeenCalledWith([1, 2]);
    expect(successToastSpy).toHaveBeenCalled();
  });

  it('deleteAll failed should show error toast', async () => {
    vi.spyOn(mockRuAdminApi, 'deleteAllNoticeTemplate').mockReturnValueOnce(throwError(() => new Error('API error')));
    const errorToastSpy = vi.spyOn(mockToastService, 'error');

    await service.deleteAll([noticeTemplate]);

    expect(errorToastSpy).toHaveBeenCalled();
  });
});
