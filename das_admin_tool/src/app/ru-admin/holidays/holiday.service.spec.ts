import {TestBed} from '@angular/core/testing';

import {HolidayService} from './holiday.service';
import {Holiday, HolidayApiResponse, RuAdminApi} from '../ru-admin-api';
import {SbbDialogService} from '@sbb-esta/lyne-angular/dialog';
import {ToastService} from '../../shared/toast-service';
import {HttpResourceRef} from '@angular/common/http';
import {of, throwError} from 'rxjs';
import {HolidayDialogEditResult} from './holiday-dialog/holiday-dialog';
import {SbbOverlayCloseEvent} from '@sbb-esta/lyne-elements/overlay.js';

const holiday: Holiday = {
  id: 1,
  name: 'Auffahrt',
  validAt: new Date('2026-05-14'),
  type: 'SUNDAY',
  companies: ['1085', '1087'],
};

const mockRuAdminApi: Partial<RuAdminApi> = {
  putHoliday: () => of({} as HolidayApiResponse),
  deleteHoliday: () => of(undefined),
  postHoliday: () => of({} as HolidayApiResponse),
  deleteAllHolidays: () => of(undefined),
  holidays: {reload: () => true} as HttpResourceRef<HolidayApiResponse | undefined>,
};

const mockToastService: Partial<ToastService> = {
  success: vi.fn(),
  error: vi.fn()
};

const openSpy = vi.fn();

const mockSbbDialogService: Partial<SbbDialogService> = {open: openSpy};

function mockDialogResult(result: HolidayDialogEditResult | null): void {
  openSpy.mockReturnValue({
    afterClosed: of({result} as SbbOverlayCloseEvent)
  });
}

describe('HolidayService', () => {
  let service: HolidayService;

  beforeEach(() => {
    vi.clearAllMocks();

    TestBed.configureTestingModule({
      providers: [
        HolidayService,
        {provide: RuAdminApi, useValue: mockRuAdminApi},
        {provide: SbbDialogService, useValue: mockSbbDialogService},
        {provide: ToastService, useValue: mockToastService},
      ],
    });

    service = TestBed.inject(HolidayService);
  });

  it('should be created', () => {
    expect(service).toBeTruthy();
  });

  it('edit should update holiday', async () => {
    const apiSpy = vi.spyOn(mockRuAdminApi, 'putHoliday');
    const toastSpy = vi.spyOn(mockToastService, 'success');
    mockDialogResult({...holiday, name: 'Updated'});

    await service.edit(holiday);

    expect(toastSpy).toHaveBeenCalled();
    expect(apiSpy).toHaveBeenCalledWith(1, {
      id: 1,
      name: 'Updated',
      validAt: new Date('2026-05-14'),
      type: 'SUNDAY',
      companies: ['1085', '1087'],
    });
  });

  it('edit with delete should delete holiday', async () => {
    const apiDeleteSpy = vi.spyOn(mockRuAdminApi, 'deleteHoliday');
    const successToastSpy = vi.spyOn(mockToastService, 'success');
    mockDialogResult('delete');

    await service.edit(holiday);

    expect(successToastSpy).toHaveBeenCalled();
    expect(apiDeleteSpy).toHaveBeenCalledWith(holiday.id);
  });

  it('edit with dialog close should do nothing', async () => {
    const apiSpy = vi.spyOn(mockRuAdminApi, 'putHoliday');
    const successToastSpy = vi.spyOn(mockToastService, 'success');
    mockDialogResult(null);

    await service.edit(holiday);

    expect(apiSpy).not.toHaveBeenCalled();
    expect(successToastSpy).not.toHaveBeenCalled();
  });

  it('edit failed should show error toast', async () => {
    vi.spyOn(mockRuAdminApi, 'putHoliday').mockReturnValueOnce(throwError(() => new Error('API error')));
    const errorToastSpy = vi.spyOn(mockToastService, 'error');
    mockDialogResult({...holiday, name: 'Updated'});

    await service.edit(holiday);

    expect(errorToastSpy).toHaveBeenCalled();
  });

  it('add should create holiday', async () => {
    const apiSpy = vi.spyOn(mockRuAdminApi, 'postHoliday');
    const successToastSpy = vi.spyOn(mockToastService, 'success');
    const holidayToCreate: Holiday = {
      name: 'Nationalfeiertag',
      validAt: new Date('2026-08-01'),
      type: 'MONDAY',
      companies: ['1085'],
    };
    mockDialogResult(holidayToCreate);

    await service.add();

    expect(successToastSpy).toHaveBeenCalled();
    expect(apiSpy).toHaveBeenCalledWith(holidayToCreate);
  });

  it('add with dialog close should do nothing', async () => {
    const apiSpy = vi.spyOn(mockRuAdminApi, 'postHoliday');
    mockDialogResult(null);

    await service.add();

    expect(apiSpy).not.toHaveBeenCalled();
  });

  it('deleteAll should delete by ids', async () => {
    const apiSpy = vi.spyOn(mockRuAdminApi, 'deleteAllHolidays');
    const successToastSpy = vi.spyOn(mockToastService, 'success');

    await service.deleteAll([
      holiday,
      {
        id: 2,
        name: 'Berchtoldstag',
        validAt: new Date('2026-01-02'),
        type: 'MONDAY',
        companies: ['1087']
      },
    ]);

    expect(apiSpy).toHaveBeenCalledWith([1, 2]);
    expect(successToastSpy).toHaveBeenCalled();
  });

  it('deleteAll failed should show error toast', async () => {
    vi.spyOn(mockRuAdminApi, 'deleteAllHolidays').mockReturnValueOnce(throwError(() => new Error('API error')));
    const errorToastSpy = vi.spyOn(mockToastService, 'error');

    await service.deleteAll([holiday]);

    expect(errorToastSpy).toHaveBeenCalled();
  });
});

