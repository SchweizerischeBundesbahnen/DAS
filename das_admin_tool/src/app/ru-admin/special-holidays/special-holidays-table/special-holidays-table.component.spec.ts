import { TestBed } from '@angular/core/testing';
import { SpecialHolidaysTable } from './special-holidays-table.component';
import { SpecialHolidayService } from '../special-holiday.service';
import { SpecialHoliday } from '../../ru-admin-api';
import { CompanyService } from '../../../shared/companies-input/company.service';

const holidays: SpecialHoliday[] = [
  {
    id: 1,
    name: 'Auffahrt',
    date: new Date('2026-05-14'),
    scheduleType: 'SUNDAY_SCHEDULE',
    companies: ['1085', '1087'],
    lastModifiedBy: 'admin',
    lastModifiedAt: new Date('2026-01-15'),
  },
  {
    id: 2,
    name: '1. Mai',
    date: new Date('2026-05-01'),
    scheduleType: 'MONDAY_SCHEDULE',
    companies: ['1089'],
    lastModifiedBy: 'editor',
    lastModifiedAt: new Date('2026-02-20'),
  },
];

const mockHolidayService = {
  edit: vi.fn(),
  add: vi.fn(),
  deleteAll: vi.fn(() => Promise.resolve()),
  specialHolidaysResource: new Proxy({}, { get: () => vi.fn() }),
};

const mockCompanyService: Partial<CompanyService> = {
  formatCompanies: vi.fn((codes: string[]) => codes.join(', ')),
};

function createComponent(): SpecialHolidaysTable {
  TestBed.configureTestingModule({
    providers: [
      SpecialHolidaysTable,
      { provide: SpecialHolidayService, useValue: mockHolidayService },
      { provide: CompanyService, useValue: mockCompanyService },
    ],
  });
  return TestBed.inject(SpecialHolidaysTable);
}

describe('SpecialHolidaysTable', () => {
  beforeEach(() => vi.clearAllMocks());

  describe('scheduleTypeLabel', () => {
    it('should return label for SUNDAY_SCHEDULE', () => {
      const comp = createComponent();
      const label = comp['scheduleTypeLabel']('SUNDAY_SCHEDULE');
      expect(label).toBeTruthy();
      expect(label).toContain('Sonntag');
    });

    it('should return label for MONDAY_SCHEDULE', () => {
      const comp = createComponent();
      const label = comp['scheduleTypeLabel']('MONDAY_SCHEDULE');
      expect(label).toBeTruthy();
      expect(label).toContain('Montag');
    });

    it('should return empty string for unknown schedule type', () => {
      const comp = createComponent();
      const label = comp['scheduleTypeLabel']('UNKNOWN' as never);
      expect(label).toBe('');
    });
  });

  describe('companiesValue', () => {
    it('should delegate to CompanyService.formatCompanies', () => {
      const comp = createComponent();
      const result = comp['companiesValue'](['1085', '1087']);
      expect(mockCompanyService.formatCompanies).toHaveBeenCalledWith(['1085', '1087']);
      expect(result).toBe('1085, 1087');
    });

    it('should handle empty array', () => {
      const comp = createComponent();
      const result = comp['companiesValue']([]);
      expect(mockCompanyService.formatCompanies).toHaveBeenCalledWith([]);
      expect(result).toBe('');
    });
  });

  describe('searchFilter', () => {
    it.each([
      { search: '', expected: true, description: 'empty search returns all' },
      { search: 'auffahrt', expected: true, description: 'matches on name' },
      { search: '2026', expected: true, description: 'matches on date' },
      { search: 'sonntag', expected: true, description: 'matches on schedule type label' },
      { search: '1085', expected: true, description: 'matches on companies value' },
      { search: 'admin', expected: true, description: 'matches on lastModifiedBy' },
      { search: 'AUFFAHRT', expected: true, description: 'is case-insensitive' },
      { search: 'xyz-nomatch', expected: false, description: 'returns false when no match' },
    ])('$description (search="$search")', ({ search, expected }) => {
      const comp = createComponent();
      expect(comp['searchFilter']({ search }, holidays[0])).toBe(expected);
    });
  });

  describe('edit', () => {
    it('should call specialHolidayService.edit with the holiday', async () => {
      const comp = createComponent();
      await comp['edit'](holidays[0]);
      expect(mockHolidayService.edit).toHaveBeenCalledWith(holidays[0]);
    });
  });

  describe('add', () => {
    it('should call specialHolidayService.add', async () => {
      const comp = createComponent();
      await comp['add']();
      expect(mockHolidayService.add).toHaveBeenCalled();
    });
  });

  describe('deleteSelected', () => {
    it('should call specialHolidayService.deleteAll with selected items and clear selection', async () => {
      const comp = createComponent();
      comp['dataSource'].data = holidays;
      comp['selection'].select(...holidays);
      await comp['deleteSelected']();
      expect(mockHolidayService.deleteAll).toHaveBeenCalledWith(holidays);
      expect(comp['selection'].selected).toEqual([]);
    });

    it('should set isDeleting flag during deletion', async () => {
      let resolveFn: () => void;
      mockHolidayService.deleteAll.mockReturnValue(new Promise<void>((r) => (resolveFn = r)));
      const comp = createComponent();
      comp['dataSource'].data = holidays;
      comp['selection'].select(holidays[0]);

      const promise = comp['deleteSelected']();
      expect(comp['isDeleting']).toBe(true);

      resolveFn!();
      await promise;
      expect(comp['isDeleting']).toBe(false);
    });

    it('should not call deleteAll when already deleting', async () => {
      const comp = createComponent();
      comp['isDeleting'] = true;
      comp['selection'].select(holidays[0]);
      await comp['deleteSelected']();
      expect(mockHolidayService.deleteAll).not.toHaveBeenCalled();
    });

    it('should reset isDeleting even when deleteAll throws', async () => {
      mockHolidayService.deleteAll.mockRejectedValue(new Error('API error'));
      const comp = createComponent();
      comp['dataSource'].data = holidays;
      comp['selection'].select(holidays[0]);

      await comp['deleteSelected']().catch(() => {
        /* expected */
      });
      expect(comp['isDeleting']).toBe(false);
    });
  });

  describe('isAllSelected', () => {
    it('should return false when nothing is selected', () => {
      const comp = createComponent();
      comp['dataSource'].data = holidays;
      expect(comp['isAllSelected']()).toBe(false);
    });

    it('should return false when only some rows are selected', () => {
      const comp = createComponent();
      comp['dataSource'].data = holidays;
      comp['selection'].select(holidays[0]);
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

    it('should select all rows when only some are selected', () => {
      const comp = createComponent();
      comp['dataSource'].data = holidays;
      comp['selection'].select(holidays[0]);
      comp['parentToggle']();
      expect(comp['selection'].selected).toHaveLength(holidays.length);
    });

    it('should clear selection when all rows are already selected', () => {
      const comp = createComponent();
      comp['dataSource'].data = holidays;
      comp['selection'].select(...holidays);
      comp['parentToggle']();
      expect(comp['selection'].selected).toEqual([]);
    });
  });

  describe('searchControl integration (regression)', () => {
    it('should show all entries again after clearing search text', () => {
      const comp = createComponent();
      comp['dataSource'].data = holidays;

      // Type a filter that matches only one entry
      comp['searchControl'].setValue('Auffahrt');
      expect(comp['dataSource'].filteredData).toHaveLength(1);
      expect(comp['dataSource'].filteredData[0].name).toBe('Auffahrt');

      // Clear the search - should show all entries again
      comp['searchControl'].setValue('');
      expect(comp['dataSource'].filteredData).toHaveLength(holidays.length);
    });
  });
});
