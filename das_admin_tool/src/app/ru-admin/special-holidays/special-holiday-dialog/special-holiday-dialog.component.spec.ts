import { TestBed } from '@angular/core/testing';
import { SBB_OVERLAY_DATA } from '@sbb-esta/lyne-angular/core';
import { SpecialHoliday } from '~ru-admin/ru-admin-api';
import { RecentCompaniesStore } from '~shared/recent-companies.store';
import { expectError } from '~src/testing/utils';
import { SpecialHolidayDialog } from './special-holiday-dialog.component';

function createDialog(data?: SpecialHoliday, recentCompanies: string[] = []): SpecialHolidayDialog {
  const recentCompaniesStoreMock = { get: vi.fn(() => recentCompanies) };
  TestBed.configureTestingModule({
    providers: [
      SpecialHolidayDialog,
      { provide: SBB_OVERLAY_DATA, useValue: data ?? null },
      { provide: RecentCompaniesStore, useValue: recentCompaniesStoreMock },
    ],
  });
  return TestBed.inject(SpecialHolidayDialog);
}

const existingHoliday: SpecialHoliday = {
  id: 1,
  name: 'Auffahrt',
  date: '2026-05-14',
  scheduleType: 'SUNDAY_SCHEDULE',
  companies: ['1085', '1087'],
};

describe('SpecialHolidayDialog', () => {
  beforeEach(() => vi.clearAllMocks());

  it('should initialize in create mode without overlay data', () => {
    const dialog = createDialog();

    expect(dialog['dialogData']?.id).toBeFalsy();
    expect(dialog['specialHolidayForm'].name().value()).toBe('');
    expect(dialog['specialHolidayForm'].scheduleType().value()).toBe('SUNDAY_SCHEDULE');
  });

  it('should initialize in edit mode and patch existing values', () => {
    const dialog = createDialog(existingHoliday, ['9999']);

    expect(dialog['dialogData']?.id).toBeDefined();
    expect(dialog['specialHolidayForm']().value()).toEqual({
      name: 'Auffahrt',
      date: new Date('2026-05-14'),
      scheduleType: 'SUNDAY_SCHEDULE',
      companies: ['1085', '1087'],
    });
  });

  it('companies should be invalid when empty', () => {
    const dialog = createDialog();

    dialog['specialHolidayForm'].companies().value.set([]);

    expect(expectError(dialog['specialHolidayForm'].companies(), 'arrayRequired')).toBe(true);
  });
});
