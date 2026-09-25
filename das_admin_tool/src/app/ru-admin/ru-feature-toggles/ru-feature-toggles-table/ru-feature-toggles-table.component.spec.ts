import { ComponentFixture, TestBed } from '@angular/core/testing';
import { RU_FEATURE_KEY_LABELS, RuFeature } from '~ru-admin/ru-admin-api';
import { CompanyService } from '~shared/companies-input/company.service';
import { RuFeatureService } from '../ru-feature.service';
import { RuFeatureTogglesTable } from './ru-feature-toggles-table.component';

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
  ruFeaturesResource: new Proxy({}, { get: () => vi.fn() }),
};

const mockCompanyService: Partial<CompanyService> = {
  getName: vi.fn((code: string) => (code === '1085' ? 'SBB' : undefined)),
};

describe('RuFeatureTogglesTable', () => {
  let component: RuFeatureTogglesTable;
  let fixture: ComponentFixture<RuFeatureTogglesTable>;

  beforeEach(async () => {
    vi.clearAllMocks();

    await TestBed.configureTestingModule({
      imports: [RuFeatureTogglesTable],
      providers: [
        RuFeatureTogglesTable,
        { provide: RuFeatureService, useValue: mockRuFeatureService },
        { provide: CompanyService, useValue: mockCompanyService },
      ],
    }).compileComponents();

    fixture = TestBed.createComponent(RuFeatureTogglesTable);
    component = fixture.componentInstance;
    await fixture.whenStable();
  });

  describe('companyName', () => {
    it('should resolve a known company code to its name', () => {
      expect(component['companyName']('1085')).toBe('SBB');
    });

    it('should fall back to the raw code when unknown', () => {
      expect(component['companyName']('9999')).toBe('9999');
    });
  });

  describe('featureKeyLabel', () => {
    it('should return a label for a known key', () => {
      expect(component['featureKeyLabel']('WARNAPP')).toBeTruthy();
    });

    it('should return a label for every known key', () => {
      for (const { value, label } of RU_FEATURE_KEY_LABELS()) {
        expect(component['featureKeyLabel'](value)).toBe(label);
      }
    });
  });

  describe('searchFilter', () => {
    it.each([
      { search: '', expected: true, description: 'empty search returns all' },
      { search: 'sbb', expected: true, description: 'matches on company name' },
      { search: '1085', expected: true, description: 'matches on company code' },
      { search: 'warnfunktion', expected: true, description: 'matches on key label' },
      { search: 'admin', expected: true, description: 'matches on lastModifiedBy' },
      { search: 'SBB', expected: true, description: 'is case-insensitive' },
      { search: 'xyz-nomatch', expected: false, description: 'returns false when no match' },
    ])('$description (search="$search")', ({ search, expected }) => {
      expect(component['searchFilter']({ search }, ruFeatures[0])).toBe(expected);
    });
  });

  describe('edit', () => {
    it('should call ruFeatureService.edit with the ru feature', async () => {
      await component['edit'](ruFeatures[0]);
      expect(mockRuFeatureService.edit).toHaveBeenCalledWith(ruFeatures[0]);
    });
  });

  describe('add', () => {
    it('should call ruFeatureService.add', async () => {
      await component['add']();
      expect(mockRuFeatureService.add).toHaveBeenCalled();
    });
  });

  describe('filterForm.search integration (regression)', () => {
    it('should show all entries again after clearing search text', async () => {
      component['dataSource'].data = ruFeatures;

      component['filterForm'].search().value.set('1085');
      await fixture.whenStable();
      expect(component['dataSource'].filteredData).toHaveLength(1);
      expect(component['dataSource'].filteredData[0].companyCode).toBe('1085');

      component['filterForm'].search().value.set('');
      await fixture.whenStable();
      expect(component['dataSource'].filteredData).toHaveLength(ruFeatures.length);
    });
  });
});
