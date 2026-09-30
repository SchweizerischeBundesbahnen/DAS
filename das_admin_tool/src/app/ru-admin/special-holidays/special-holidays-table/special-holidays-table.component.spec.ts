import { ComponentFixture, TestBed } from '@angular/core/testing';
import { SpecialHoliday } from '~ru-admin/ru-admin-api';
import { CompanyService } from '~shared/companies-input/company.service';
import { SpecialHolidayService } from '../special-holiday.service';
import { SpecialHolidaysTable } from './special-holidays-table.component';

const holidays: SpecialHoliday[] = [
  {
    id: 1,
    name: 'Auffahrt',
    date: '2026-05-14',
    scheduleType: 'SUNDAY_SCHEDULE',
    companies: ['1085', '1087'],
    lastModifiedBy: 'admin',
    lastModifiedAt: new Date('2026-01-15'),
  },
  {
    id: 2,
    name: '1. Mai',
    date: '2026-05-01',
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

describe('SpecialHolidaysTable', () => {
  let component: SpecialHolidaysTable;
  let fixture: ComponentFixture<SpecialHolidaysTable>;

  beforeEach(async () => {
    vi.clearAllMocks();

    await TestBed.configureTestingModule({
      imports: [SpecialHolidaysTable],
      providers: [
        SpecialHolidaysTable,
        { provide: SpecialHolidayService, useValue: mockHolidayService },
        { provide: CompanyService, useValue: mockCompanyService },
      ],
    }).compileComponents();

    fixture = TestBed.createComponent(SpecialHolidaysTable);
    component = fixture.componentInstance;
    await fixture.whenStable();
  });

  describe('scheduleTypeLabel', () => {
    it('should return label for SUNDAY_SCHEDULE', () => {
      const label = component['scheduleTypeLabel']('SUNDAY_SCHEDULE');
      expect(label).toBeTruthy();
      expect(label).toContain('Sonntag');
    });

    it('should return label for MONDAY_SCHEDULE', () => {
      const label = component['scheduleTypeLabel']('MONDAY_SCHEDULE');
      expect(label).toBeTruthy();
      expect(label).toContain('Montag');
    });

    it('should return empty string for unknown schedule type', () => {
      const label = component['scheduleTypeLabel']('UNKNOWN' as never);
      expect(label).toBe('');
    });
  });

  describe('companiesValue', () => {
    it('should delegate to CompanyService.formatCompanies', () => {
      const result = component['companiesValue'](['1085', '1087']);
      expect(mockCompanyService.formatCompanies).toHaveBeenCalledWith(['1085', '1087']);
      expect(result).toBe('1085, 1087');
    });

    it('should handle empty array', () => {
      const result = component['companiesValue']([]);
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
      expect(component['searchFilter']({ search }, holidays[0])).toBe(expected);
    });
  });

  describe('edit', () => {
    it('should call specialHolidayService.edit with the holiday', async () => {
      await component['edit'](holidays[0]);
      expect(mockHolidayService.edit).toHaveBeenCalledWith(holidays[0]);
    });
  });

  describe('add', () => {
    it('should call specialHolidayService.add', async () => {
      await component['add']();
      expect(mockHolidayService.add).toHaveBeenCalled();
    });
  });

  describe('deleteSelected', () => {
    it('should call specialHolidayService.deleteAll with selected items and clear selection', async () => {
      component['dataSource'].data = holidays;
      component['selection'].select(...holidays);
      await component['deleteSelected']();
      expect(mockHolidayService.deleteAll).toHaveBeenCalledWith(holidays);
      expect(component['selection'].selected).toEqual([]);
    });

    it('should set isDeleting flag during deletion', async () => {
      let resolveFn: () => void;
      mockHolidayService.deleteAll.mockReturnValue(new Promise<void>((r) => (resolveFn = r)));
      component['dataSource'].data = holidays;
      component['selection'].select(holidays[0]);

      const promise = component['deleteSelected']();
      expect(component['isDeleting']).toBe(true);

      resolveFn!();
      await promise;
      expect(component['isDeleting']).toBe(false);
    });

    it('should not call deleteAll when already deleting', async () => {
      component['isDeleting'] = true;
      component['selection'].select(holidays[0]);
      await component['deleteSelected']();
      expect(mockHolidayService.deleteAll).not.toHaveBeenCalled();
    });

    it('should reset isDeleting even when deleteAll throws', async () => {
      mockHolidayService.deleteAll.mockRejectedValue(new Error('API error'));
      component['dataSource'].data = holidays;
      component['selection'].select(holidays[0]);

      await component['deleteSelected']().catch(() => {
        // expected
      });
      expect(component['isDeleting']).toBe(false);
    });
  });

  describe('isAllSelected', () => {
    it('should return false when nothing is selected', () => {
      component['dataSource'].data = holidays;
      expect(component['isAllSelected']()).toBe(false);
    });

    it('should return false when only some rows are selected', () => {
      component['dataSource'].data = holidays;
      component['selection'].select(holidays[0]);
      expect(component['isAllSelected']()).toBe(false);
    });

    it('should return true when all rows are selected', () => {
      component['dataSource'].data = holidays;
      component['selection'].select(...holidays);
      expect(component['isAllSelected']()).toBe(true);
    });
  });

  describe('parentToggle', () => {
    it('should select all rows when none are selected', () => {
      component['dataSource'].data = holidays;
      component['parentToggle']();
      expect(component['selection'].selected).toEqual(holidays);
    });

    it('should select all rows when only some are selected', () => {
      component['dataSource'].data = holidays;
      component['selection'].select(holidays[0]);
      component['parentToggle']();
      expect(component['selection'].selected).toHaveLength(holidays.length);
    });

    it('should clear selection when all rows are already selected', () => {
      component['dataSource'].data = holidays;
      component['selection'].select(...holidays);
      component['parentToggle']();
      expect(component['selection'].selected).toEqual([]);
    });
  });

  describe('filterForm.search integration (regression)', () => {
    it('should show all entries again after clearing search text', async () => {
      component['dataSource'].data = holidays;

      // Type a filter that matches only one entry
      component['filterForm'].search().value.set('Auffahrt');
      await fixture.whenStable();
      expect(component['dataSource'].filteredData).toHaveLength(1);
      expect(component['dataSource'].filteredData[0].name).toBe('Auffahrt');

      // Clear the search - should show all entries again
      component['filterForm'].search().value.set('');
      await fixture.whenStable();
      expect(component['dataSource'].filteredData).toHaveLength(holidays.length);
    });
  });
});
