import {TestBed} from '@angular/core/testing';
import {SpecialHolidayDialog} from './special-holiday-dialog.component';
import {SBB_OVERLAY_DATA} from '@sbb-esta/lyne-angular/core/overlay';
import {SpecialHoliday} from '../../ru-admin-api';

function createDialog(data?: SpecialHoliday): SpecialHolidayDialog {
  TestBed.configureTestingModule({
    providers: [
      SpecialHolidayDialog,
      {provide: SBB_OVERLAY_DATA, useValue: data ?? null},
    ],
  });
  return TestBed.inject(SpecialHolidayDialog);
}

const existingHoliday: SpecialHoliday = {
  id: 1,
  name: 'Auffahrt',
  date: new Date('2026-05-14'),
  scheduleType: 'SUNDAY_SCHEDULE',
  companies: ['1085', '1087'],
};

describe('SpecialHolidayDialog', () => {
  beforeEach(() => vi.clearAllMocks());

  it('should initialize in create mode without overlay data', () => {
    const dialog = createDialog();

    expect(dialog['isEdit']).toBe(false);
    expect(dialog['specialHolidayForm'].value.name).toBe('');
    expect(dialog['specialHolidayForm'].value.scheduleType).toBe('SUNDAY_SCHEDULE');
  });

  it('should initialize in edit mode and patch existing values', () => {
    const dialog = createDialog(existingHoliday);

    expect(dialog['isEdit']).toBe(true);
    expect(dialog['specialHolidayForm'].value).toEqual({
      name: 'Auffahrt',
      date: new Date('2026-05-14'),
      scheduleType: 'SUNDAY_SCHEDULE',
      companies: ['1085', '1087'],
    });
  });

  it('companies should be invalid when empty', () => {
    const dialog = createDialog();

    dialog['specialHolidayForm'].get('companies')!.setValue([]);

    expect(dialog['specialHolidayForm'].get('companies')!.errors).toEqual({required: true});
  });
});

