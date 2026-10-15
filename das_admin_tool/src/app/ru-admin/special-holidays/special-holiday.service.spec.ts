import { HttpResourceRef } from '@angular/common/http';
import { TestBed } from '@angular/core/testing';
import { SbbDialogService } from '@sbb-esta/lyne-angular/dialog';
import { SbbOverlayCloseEvent } from '@sbb-esta/lyne-elements/overlay.js';
import { of, throwError } from 'rxjs';
import { RecentCompaniesService } from '~shared/services/recent-companies.service';
import { ToastService } from '~shared/services/toast.service';
import { RuAdminApi, SpecialHoliday, SpecialHolidayApiResponse } from '../ru-admin.api';
import { SpecialHolidayDialogEditResult } from './special-holiday-dialog/special-holiday-dialog';
import { SpecialHolidayService } from './special-holiday.service';

const specialHoliday: SpecialHoliday = {
  id: 1,
  name: 'Auffahrt',
  date: '2026-05-14',
  scheduleType: 'SUNDAY_SCHEDULE',
  companies: ['1085', '1087'],
};

const mockRuAdminApi: Partial<RuAdminApi> = {
  putSpecialHoliday: () => of({} as SpecialHolidayApiResponse),
  postSpecialHoliday: () => of({} as SpecialHolidayApiResponse),
  deleteAllSpecialHolidays: () => of(undefined),
  specialHolidays: { reload: () => true } as HttpResourceRef<SpecialHolidayApiResponse | undefined>,
};

const mockToastService: Partial<ToastService> = {
  success: vi.fn(),
  error: vi.fn(),
};

const openSpy = vi.fn();

const mockSbbDialogService: Partial<SbbDialogService> = { open: openSpy };

const mockRecentCompaniesService: Partial<RecentCompaniesService> = { save: vi.fn() };

function mockDialogResult(result: SpecialHolidayDialogEditResult | null): void {
  openSpy.mockReturnValue({
    afterClosed: of({ result } as SbbOverlayCloseEvent),
  });
}

describe('SpecialHolidayService', () => {
  let specialHolidayService: SpecialHolidayService;

  beforeEach(() => {
    vi.clearAllMocks();

    TestBed.configureTestingModule({
      providers: [
        SpecialHolidayService,
        { provide: RuAdminApi, useValue: mockRuAdminApi },
        { provide: SbbDialogService, useValue: mockSbbDialogService },
        { provide: ToastService, useValue: mockToastService },
        { provide: RecentCompaniesService, useValue: mockRecentCompaniesService },
      ],
    });

    specialHolidayService = TestBed.inject(SpecialHolidayService);
  });

  it('should be created', () => {
    expect(specialHolidayService).toBeTruthy();
  });

  it('edit should update holiday', async () => {
    const apiSpy = vi.spyOn(mockRuAdminApi, 'putSpecialHoliday');
    const toastSpy = vi.spyOn(mockToastService, 'success');
    const recentCompaniesSaveSpy = vi.spyOn(mockRecentCompaniesService, 'save');
    mockDialogResult({ ...specialHoliday, name: 'Updated', companies: ['1085', '1087', '1090'] });

    await specialHolidayService.edit(specialHoliday);

    expect(toastSpy).toHaveBeenCalled();
    expect(apiSpy).toHaveBeenCalledWith(1, {
      id: 1,
      name: 'Updated',
      date: '2026-05-14',
      scheduleType: 'SUNDAY_SCHEDULE',
      companies: ['1085', '1087', '1090'],
    });
    expect(recentCompaniesSaveSpy).toHaveBeenCalledWith(['1085', '1087', '1090']);
  });

  it('edit with delete should delete holiday', async () => {
    const apiDeleteSpy = vi.spyOn(mockRuAdminApi, 'deleteAllSpecialHolidays');
    const successToastSpy = vi.spyOn(mockToastService, 'success');
    const recentCompaniesSaveSpy = vi.spyOn(mockRecentCompaniesService, 'save');
    mockDialogResult('delete');

    await specialHolidayService.edit(specialHoliday);

    expect(successToastSpy).toHaveBeenCalled();
    expect(apiDeleteSpy).toHaveBeenCalledWith([specialHoliday.id]);
    expect(recentCompaniesSaveSpy).not.toHaveBeenCalled();
  });

  it('edit with dialog close should do nothing', async () => {
    const apiSpy = vi.spyOn(mockRuAdminApi, 'putSpecialHoliday');
    const successToastSpy = vi.spyOn(mockToastService, 'success');
    const recentCompaniesSaveSpy = vi.spyOn(mockRecentCompaniesService, 'save');
    mockDialogResult(null);

    await specialHolidayService.edit(specialHoliday);

    expect(apiSpy).not.toHaveBeenCalled();
    expect(successToastSpy).not.toHaveBeenCalled();
    expect(recentCompaniesSaveSpy).not.toHaveBeenCalled();
  });

  it('edit failed should show error toast', async () => {
    vi.spyOn(mockRuAdminApi, 'putSpecialHoliday').mockReturnValueOnce(
      throwError(() => new Error('API error')),
    );
    const errorToastSpy = vi.spyOn(mockToastService, 'error');
    mockDialogResult({ ...specialHoliday, name: 'Updated' });

    await specialHolidayService.edit(specialHoliday);

    expect(errorToastSpy).toHaveBeenCalled();
  });

  it('add should create holiday', async () => {
    const apiSpy = vi.spyOn(mockRuAdminApi, 'postSpecialHoliday');
    const successToastSpy = vi.spyOn(mockToastService, 'success');
    const recentCompaniesSaveSpy = vi.spyOn(mockRecentCompaniesService, 'save');
    const holidayToCreate: SpecialHoliday = {
      name: 'Nationalfeiertag',
      date: '2026-08-01',
      scheduleType: 'MONDAY_SCHEDULE',
      companies: ['1085'],
    };
    mockDialogResult(holidayToCreate);

    await specialHolidayService.add();

    expect(successToastSpy).toHaveBeenCalled();
    expect(apiSpy).toHaveBeenCalledWith(holidayToCreate);
    expect(recentCompaniesSaveSpy).toHaveBeenCalledWith(['1085']);
  });

  it('add with dialog close should do nothing', async () => {
    const apiSpy = vi.spyOn(mockRuAdminApi, 'postSpecialHoliday');
    const recentCompaniesSaveSpy = vi.spyOn(mockRecentCompaniesService, 'save');
    mockDialogResult(null);

    await specialHolidayService.add();

    expect(apiSpy).not.toHaveBeenCalled();
    expect(recentCompaniesSaveSpy).not.toHaveBeenCalled();
  });

  it('deleteAll should delete by ids', async () => {
    const apiSpy = vi.spyOn(mockRuAdminApi, 'deleteAllSpecialHolidays');
    const successToastSpy = vi.spyOn(mockToastService, 'success');

    await specialHolidayService.deleteAll([
      specialHoliday,
      {
        id: 2,
        name: 'Berchtoldstag',
        date: '2026-01-02',
        scheduleType: 'MONDAY_SCHEDULE',
        companies: ['1087'],
      },
    ]);

    expect(apiSpy).toHaveBeenCalledWith([1, 2]);
    expect(successToastSpy).toHaveBeenCalled();
  });

  it('deleteAll failed should show error toast', async () => {
    vi.spyOn(mockRuAdminApi, 'deleteAllSpecialHolidays').mockReturnValueOnce(
      throwError(() => new Error('API error')),
    );
    const errorToastSpy = vi.spyOn(mockToastService, 'error');

    await specialHolidayService.deleteAll([specialHoliday]);

    expect(errorToastSpy).toHaveBeenCalled();
  });
});
