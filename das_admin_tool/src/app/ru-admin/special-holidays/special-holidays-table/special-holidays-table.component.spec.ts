import { TestBed } from '@angular/core/testing';
import { SpecialHolidaysTable } from './special-holidays-table.component';
import { SpecialHolidayService } from '../special-holiday.service';
import { SpecialHoliday } from '../../ru-admin-api';

const holidays: SpecialHoliday[] = [
  {
    id: 1,
    name: 'Auffahrt',
    date: new Date('2026-05-14'),
    scheduleType: 'SUNDAY_SCHEDULE',
    companies: ['1085', '1087'],
  },
  {
    id: 2,
    name: '1. Mai',
    date: new Date('2026-05-01'),
    scheduleType: 'MONDAY_SCHEDULE',
    companies: ['1089'],
  },
];

const mockHolidayService = {
  edit: vi.fn(),
  add: vi.fn(),
  deleteAll: vi.fn(),
  specialHolidaysResource: new Proxy({}, {get: () => vi.fn()})
};

function createComponent(): SpecialHolidaysTable {
  TestBed.configureTestingModule({
    providers: [
      SpecialHolidaysTable,
      {provide: SpecialHolidayService, useValue: mockHolidayService},
    ],
  });
  return TestBed.inject(SpecialHolidaysTable);
}

describe('SpecialHolidaysTable', () => {
  beforeEach(() => vi.clearAllMocks());

  describe('isAllSelected', () => {
    it('should return false when nothing is selected', () => {
      const comp = createComponent();
      comp['dataSource'].data = holidays;
      expect(comp['isAllSelected']()).toBe(false);
    });

    it('should return true when all rows are selected', () => {
      const comp = createComponent();
      comp['dataSource'].data = holidays;
      comp['selection'].select(...holidays);
      expect(comp['isAllSelected']()).toBe(true);
    });
  });

  describe('parentToggle', () => {
    it('should select all rows when none are selected', () => {
      const comp = createComponent();
      comp['dataSource'].data = holidays;
      comp['parentToggle']();
      expect(comp['selection'].selected).toEqual(holidays);
    });

    it('should clear selection when all rows are selected', () => {
      const comp = createComponent();
      comp['dataSource'].data = holidays;
      comp['selection'].select(...holidays);
      comp['parentToggle']();
      expect(comp['selection'].selected).toEqual([]);
    });
  });
});
