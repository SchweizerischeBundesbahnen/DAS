import {TestBed} from '@angular/core/testing';
import {RuFeatureTogglesTable} from './ru-feature-toggles-table.component';
import {RuFeatureService} from '../ru-feature.service';
import {RuFeature} from '../../ru-admin-api';
import {CompanyService} from '../../../shared/companies-input/company.service';

const ruFeatures: RuFeature[] = [
  {
    id: 1,
    companyCode: '1085',
    key: 'WARNAPP',
    enabled: true,
    lastModifiedBy: 'admin',
    lastModifiedAt: new Date('2026-01-15'),
  },
  {
    id: 2,
    companyCode: '1087',
    key: 'CHECKLIST_DEPARTURE_PROCESS',
    enabled: false,
    lastModifiedBy: 'editor',
    lastModifiedAt: new Date('2026-02-20'),
  },
];

const mockRuFeatureService = {
  edit: vi.fn(),
  add: vi.fn(),
  ruFeaturesResource: new Proxy({}, {get: () => vi.fn()}),
};

const mockCompanyService: Partial<CompanyService> = {
  getName: vi.fn((code: string) => (code === '1085' ? 'SBB' : undefined)),
};

function createComponent(): RuFeatureTogglesTable {
  TestBed.configureTestingModule({
    providers: [
      RuFeatureTogglesTable,
      {provide: RuFeatureService, useValue: mockRuFeatureService},
      {provide: CompanyService, useValue: mockCompanyService},
    ],
  });
  return TestBed.inject(RuFeatureTogglesTable);
}

describe('RuFeatureTogglesTable', () => {
  beforeEach(() => vi.clearAllMocks());

  describe('companyName', () => {
    it('should resolve a known company code to its name', () => {
      const comp = createComponent();
      expect(comp['companyName']('1085')).toBe('SBB');
    });

    it('should fall back to the raw code when unknown', () => {
      const comp = createComponent();
      expect(comp['companyName']('9999')).toBe('9999');
    });
  });

  describe('featureKeyLabel', () => {
    it('should return a label for a known key', () => {
      const comp = createComponent();
      expect(comp['featureKeyLabel']('WARNAPP')).toBeTruthy();
    });
  });

  describe('searchFilter', () => {
    it.each([
      {search: '', expected: true, description: 'empty search returns all'},
      {search: 'sbb', expected: true, description: 'matches on company name'},
      {search: '1085', expected: true, description: 'matches on company code'},
      {search: 'warnapp', expected: true, description: 'matches on key label'},
      {search: 'admin', expected: true, description: 'matches on lastModifiedBy'},
      {search: 'SBB', expected: true, description: 'is case-insensitive'},
      {search: 'xyz-nomatch', expected: false, description: 'returns false when no match'},
    ])('$description (search="$search")', ({search, expected}) => {
      const comp = createComponent();
      expect(comp['searchFilter']({search}, ruFeatures[0])).toBe(expected);
    });
  });

  describe('edit', () => {
    it('should call ruFeatureService.edit with the ru feature', async () => {
      const comp = createComponent();
      await comp['edit'](ruFeatures[0]);
      expect(mockRuFeatureService.edit).toHaveBeenCalledWith(ruFeatures[0]);
    });
  });

  describe('add', () => {
    it('should call ruFeatureService.add', async () => {
      const comp = createComponent();
      await comp['add']();
      expect(mockRuFeatureService.add).toHaveBeenCalled();
    });
  });

  describe('searchControl integration (regression)', () => {
    it('should show all entries again after clearing search text', () => {
      const comp = createComponent();
      comp['dataSource'].data = ruFeatures;

      comp['searchControl'].setValue('1085');
      expect(comp['dataSource'].filteredData).toHaveLength(1);
      expect(comp['dataSource'].filteredData[0].companyCode).toBe('1085');

      comp['searchControl'].setValue('');
      expect(comp['dataSource'].filteredData).toHaveLength(ruFeatures.length);
    });
  });
});
