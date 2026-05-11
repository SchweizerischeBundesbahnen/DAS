import {TestBed} from '@angular/core/testing';
import {HolidayDialog} from './holiday-dialog';
import {SBB_OVERLAY_DATA} from '@sbb-esta/lyne-angular/core/overlay';
import {Holiday} from '../../ru-admin-api';

function createDialog(data?: Holiday): HolidayDialog {
  TestBed.configureTestingModule({
    providers: [
      HolidayDialog,
      {provide: SBB_OVERLAY_DATA, useValue: data ?? null},
    ],
  });
  return TestBed.inject(HolidayDialog);
}

const existingHoliday: Holiday = {
  id: 1,
  name: 'Auffahrt',
  validAt: new Date('2026-05-14'),
  type: 'SUNDAY',
  companies: ['1085', '1087'],
};

describe('HolidayDialog', () => {
  beforeEach(() => vi.clearAllMocks());

  it('should initialize in create mode without overlay data', () => {
    const dialog = createDialog();

    expect(dialog['isEdit']).toBe(false);
    expect(dialog['holidayForm'].value.name).toBe('');
    expect(dialog['holidayForm'].value.type).toBe('SUNDAY');
  });

  it('should initialize in edit mode and patch existing values', () => {
    const dialog = createDialog(existingHoliday);

    expect(dialog['isEdit']).toBe(true);
    expect(dialog['holidayForm'].value).toEqual({
      name: 'Auffahrt',
      validAt: new Date('2026-05-14'),
      type: 'SUNDAY',
      companies: ['1085', '1087'],
    });
  });

  it('companies should be invalid when empty', () => {
    const dialog = createDialog();

    dialog['holidayForm'].get('companies')!.setValue([]);

    expect(dialog['holidayForm'].get('companies')!.errors).toEqual({required: true});
  });
});

