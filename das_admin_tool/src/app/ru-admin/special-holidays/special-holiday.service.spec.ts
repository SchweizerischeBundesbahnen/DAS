import {TestBed} from '@angular/core/testing';

import {SpecialHolidayService} from './special-holiday.service';
import {RuAdminApi, SpecialHoliday, SpecialHolidayApiResponse} from '../ru-admin-api';
import {SbbDialogService} from '@sbb-esta/lyne-angular/dialog';
import {ToastService} from '../../shared/toast-service';
import {HttpResourceRef} from '@angular/common/http';
import {of, throwError} from 'rxjs';
import {
  SpecialHolidayDialogEditResult
} from './special-holiday-dialog/special-holiday-dialog.component';
import {SbbOverlayCloseEvent} from '@sbb-esta/lyne-elements/overlay.js';
import {RecentCompaniesStore} from '../../shared/recent-companies.store';

const specialHoliday: SpecialHoliday = {
  id: 1,
  name: 'Auffahrt',
  date: new Date('2026-05-14'),
  scheduleType: 'SUNDAY_SCHEDULE',
  companies: ['1085', '1087'],
};

const mockRuAdminApi: Partial<RuAdminApi> = {
  putSpecialHoliday: () => of({} as SpecialHolidayApiResponse),
  deleteSpecialHoliday: () => of(undefined),
  postSpecialHoliday: () => of({} as SpecialHolidayApiResponse),
  deleteAllSpecialHolidays: () => of(undefined),
  specialHolidays: {reload: () => true} as HttpResourceRef<SpecialHolidayApiResponse | undefined>,
};

const mockToastService: Partial<ToastService> = {
  success: vi.fn(),
  error: vi.fn()
};

const openSpy = vi.fn();

const mockSbbDialogService: Partial<SbbDialogService> = {open: openSpy};

const mockRecentCompaniesStore: Partial<RecentCompaniesStore> = {
  save: vi.fn(),
};

function mockDialogResult(result: SpecialHolidayDialogEditResult | null): void {
  openSpy.mockReturnValue({
    afterClosed: of({result} as SbbOverlayCloseEvent)
  });
}

describe('SpecialHolidayService', () => {
  let service: SpecialHolidayService;

  beforeEach(() => {
    vi.clearAllMocks();

    TestBed.configureTestingModule({
      providers: [
        SpecialHolidayService,
        {provide: RuAdminApi, useValue: mockRuAdminApi},
        {provide: SbbDialogService, useValue: mockSbbDialogService},
        {provide: ToastService, useValue: mockToastService},
        {provide: RecentCompaniesStore, useValue: mockRecentCompaniesStore},
      ],
    });

    service = TestBed.inject(SpecialHolidayService);
  });

  it('should be created', () => {
    expect(service).toBeTruthy();
  });

  it('edit should update holiday', async () => {
    const apiSpy = vi.spyOn(mockRuAdminApi, 'putSpecialHoliday');
    const toastSpy = vi.spyOn(mockToastService, 'success');
    const recentCompaniesSaveSpy = vi.spyOn(mockRecentCompaniesStore, 'save');
    mockDialogResult({...specialHoliday, name: 'Updated', companies: ['1085', '1087', '1090']});

    await service.edit(specialHoliday);

    expect(toastSpy).toHaveBeenCalled();
    expect(apiSpy).toHaveBeenCalledWith(1, {
      id: 1,
      name: 'Updated',
      date: new Date('2026-05-14'),
      scheduleType: 'SUNDAY_SCHEDULE',
      companies: ['1085', '1087', '1090'],
    });
    expect(recentCompaniesSaveSpy).toHaveBeenCalledWith(['1085', '1087', '1090']);
  });

  it('edit with delete should delete holiday', async () => {
    const apiDeleteSpy = vi.spyOn(mockRuAdminApi, 'deleteSpecialHoliday');
    const successToastSpy = vi.spyOn(mockToastService, 'success');
    const recentCompaniesSaveSpy = vi.spyOn(mockRecentCompaniesStore, 'save');
    mockDialogResult('delete');

    await service.edit(specialHoliday);

    expect(successToastSpy).toHaveBeenCalled();
    expect(apiDeleteSpy).toHaveBeenCalledWith(specialHoliday.id);
    expect(recentCompaniesSaveSpy).not.toHaveBeenCalled();
  });

  it('edit with dialog close should do nothing', async () => {
    const apiSpy = vi.spyOn(mockRuAdminApi, 'putSpecialHoliday');
    const successToastSpy = vi.spyOn(mockToastService, 'success');
    const recentCompaniesSaveSpy = vi.spyOn(mockRecentCompaniesStore, 'save');
    mockDialogResult(null);

    await service.edit(specialHoliday);

    expect(apiSpy).not.toHaveBeenCalled();
    expect(successToastSpy).not.toHaveBeenCalled();
    expect(recentCompaniesSaveSpy).not.toHaveBeenCalled();
  });

  it('edit failed should show error toast', async () => {
    vi.spyOn(mockRuAdminApi, 'putSpecialHoliday').mockReturnValueOnce(throwError(() => new Error('API error')));
    const errorToastSpy = vi.spyOn(mockToastService, 'error');
    mockDialogResult({...specialHoliday, name: 'Updated'});

    await service.edit(specialHoliday);

    expect(errorToastSpy).toHaveBeenCalled();
  });

  it('add should create holiday', async () => {
    const apiSpy = vi.spyOn(mockRuAdminApi, 'postSpecialHoliday');
    const successToastSpy = vi.spyOn(mockToastService, 'success');
    const recentCompaniesSaveSpy = vi.spyOn(mockRecentCompaniesStore, 'save');
    const holidayToCreate: SpecialHoliday = {
      name: 'Nationalfeiertag',
      date: new Date('2026-08-01'),
      scheduleType: 'MONDAY_SCHEDULE',
      companies: ['1085'],
    };
    mockDialogResult(holidayToCreate);

    await service.add();

    expect(successToastSpy).toHaveBeenCalled();
    expect(apiSpy).toHaveBeenCalledWith(holidayToCreate);
    expect(recentCompaniesSaveSpy).toHaveBeenCalledWith(['1085']);
  });

  it('add with dialog close should do nothing', async () => {
    const apiSpy = vi.spyOn(mockRuAdminApi, 'postSpecialHoliday');
    const recentCompaniesSaveSpy = vi.spyOn(mockRecentCompaniesStore, 'save');
    mockDialogResult(null);

    await service.add();

    expect(apiSpy).not.toHaveBeenCalled();
    expect(recentCompaniesSaveSpy).not.toHaveBeenCalled();
  });

  it('deleteAll should delete by ids', async () => {
    const apiSpy = vi.spyOn(mockRuAdminApi, 'deleteAllSpecialHolidays');
    const successToastSpy = vi.spyOn(mockToastService, 'success');

    await service.deleteAll([
      specialHoliday,
      {
        id: 2,
        name: 'Berchtoldstag',
        date: new Date('2026-01-02'),
        scheduleType: 'MONDAY_SCHEDULE',
        companies: ['1087']
      },
    ]);

    expect(apiSpy).toHaveBeenCalledWith([1, 2]);
    expect(successToastSpy).toHaveBeenCalled();
  });

  it('deleteAll failed should show error toast', async () => {
    vi.spyOn(mockRuAdminApi, 'deleteAllSpecialHolidays').mockReturnValueOnce(throwError(() => new Error('API error')));
    const errorToastSpy = vi.spyOn(mockToastService, 'error');

    await service.deleteAll([specialHoliday]);

    expect(errorToastSpy).toHaveBeenCalled();
  });
});

