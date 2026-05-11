import {TestBed} from '@angular/core/testing';
import {HolidaysTable} from './holidays-table';
import {HolidayService} from '../holiday.service';
import {Holiday, HolidayApiResponse} from '../../ru-admin-api';
import {HttpResourceRef} from '@angular/common/http';

const holidays: Holiday[] = [
  {
    id: 1,
    name: 'Auffahrt',
    validAt: new Date('2026-05-14'),
    type: 'SUNDAY',
    companies: ['1085', '1087'],
  },
  {
    id: 2,
    name: '1. Mai',
    validAt: new Date('2026-05-01'),
    type: 'MONDAY',
    companies: ['1089'],
  },
];

const mockHolidayService: Partial<HolidayService> = {
  edit: vi.fn(),
  add: vi.fn(),
  deleteAll: vi.fn(),
  holidaysResource: {
    hasValue: () => false,
    value: () => ({data: []} as HolidayApiResponse),
    reload: () => true,
  } as unknown as HttpResourceRef<HolidayApiResponse | undefined>,
};

function createComponent(): HolidaysTable {
  TestBed.configureTestingModule({
    providers: [
      HolidaysTable,
      {provide: HolidayService, useValue: mockHolidayService},
    ],
  });
  return TestBed.inject(HolidaysTable);
}

describe('HolidaysTable', () => {
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

