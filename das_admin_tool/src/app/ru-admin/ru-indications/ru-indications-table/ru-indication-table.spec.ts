import { HttpResourceRef } from '@angular/common/http';
import { TestBed } from '@angular/core/testing';
import { RuIndication, RuIndicationApiResponse } from '~ru-admin/ru-admin-api';
import { CompanyService } from '~shared/companies-input/company.service';
import { LanguageProvider } from '~shared/language-provider';
import { LocationService } from '../ru-indication-dialog/locations-input/location.service';
import { displayPeriod } from '../ru-indication-dialog/periods-input/periods-input';
import { RuIndicationService } from '../ru-indication.service';
import { RuIndicationFilter, RuIndicationsTable } from './ru-indications-table';

const sample: RuIndication = {
  id: 1,
  content: {
    category: 'General',
    de: { title: 'Titel DE', text: 'Text DE' },
    fr: { title: 'Titre FR', text: 'Texte FR' },
  },
  scope: {
    companies: ['1085', '1087'],
    operationalTrainNumberFilters: [{ expression: '100', parity: 'ANY' }],
    tafTapLocationReferences: ['LOC1'],
  },
  periods: [{ validFrom: new Date('2026-01-10'), validTo: new Date('2026-01-10') }],
  status: 'ACTIVE',
  lastModifiedBy: 'tester',
  lastModifiedAt: new Date('2026-01-01'),
};

const mockRuIndicationService: Partial<RuIndicationService> = {
  ruIndicationsResource: new Proxy({}, { get: () => vi.fn() }) as HttpResourceRef<
    RuIndicationApiResponse | undefined
  >,
  edit: vi.fn(),
  add: vi.fn(),
  deleteAll: vi.fn(() => Promise.resolve()),
};

const mockLanguageProvider = {
  currentLanguage: { localeId: 'de-CH', path: 'de', label: 'Deutsch' },
} satisfies Partial<LanguageProvider>;

const mockCompanyService: Partial<CompanyService> = {
  formatCompanies: () => 'SBB, BLS',
};

const mockLocationService: Partial<LocationService> = {
  getLocation: (ref: string) => ({
    locationReference: ref,
    primaryLocationName: 'X',
    locationAbbreviation: 'XAB',
  }),
};

function createComponent(): RuIndicationsTable {
  TestBed.configureTestingModule({
    providers: [
      RuIndicationsTable,
      { provide: RuIndicationService, useValue: mockRuIndicationService },
      { provide: LanguageProvider, useValue: mockLanguageProvider },
      { provide: CompanyService, useValue: mockCompanyService },
      { provide: LocationService, useValue: mockLocationService },
    ],
  });
  return TestBed.inject(RuIndicationsTable);
}

describe('RuIndicationsTable', () => {
  beforeEach(() => vi.clearAllMocks());

  it('titleValue/textValue should return language specific values', () => {
    const comp = createComponent();
    comp['form'].patchValue({ language: 'de' });
    expect(comp['titleValue'](sample)).toBe('Titel DE');
    expect(comp['textValue'](sample)).toBe('Text DE');

    comp['form'].patchValue({ language: 'fr' });
    expect(comp['titleValue'](sample)).toBe('Titre FR');
    expect(comp['textValue'](sample)).toBe('Texte FR');
  });

  it('statusValue should map status to label', () => {
    const comp = createComponent();
    const label = comp['statusValue'](sample);
    expect(label).toBeTruthy();
  });

  it('locationsValue should map location abbreviations', () => {
    const comp = createComponent();
    const value = comp['locationsValue'](sample);
    expect(value).toBe('XAB');
  });

  it('trainNumbersValue should format train number filters', () => {
    const comp = createComponent();
    const value = comp['trainNumbersValue'](sample);
    expect(value).toContain('100');
  });

  it('periodsValue should format periods using displayPeriod', () => {
    const comp = createComponent();
    const expected = displayPeriod(
      sample.periods[0],
      mockLanguageProvider.currentLanguage.localeId,
    );
    expect(comp['periodsValue'](sample)).toBe(expected);
  });

  describe('searchFilter and property filters', () => {
    it('should match on title, text, category, status and lastModifiedBy', () => {
      const comp = createComponent();
      const filter: RuIndicationFilter = {
        companies: '',
        locations: '',
        periods: '',
        trainNumbers: '',
        search: 'general',
        language: 'de',
        category: '',
      };
      expect(comp['searchFilter'](filter, sample)).toBe(true);

      expect(
        comp['searchFilter'](
          {
            ...filter,
            search: 'general',
          },
          sample,
        ),
      ).toBe(true);
      expect(
        comp['searchFilter'](
          {
            ...filter,
            search: 'aktiv',
          },
          sample,
        ),
      ).toBe(true);
      expect(
        comp['searchFilter'](
          {
            ...filter,
            search: 'tester',
          },
          sample,
        ),
      ).toBe(true);
    });

    it('filterProperties should respect individual property filters', () => {
      const comp = createComponent();
      const filter: RuIndicationFilter = {
        search: '',
        language: 'de',
        category: 'general',
        companies: 'sbb',
        trainNumbers: '100',
        locations: 'xab',
        periods: '',
      };
      expect(comp['searchFilter'](filter, sample)).toBe(true);
    });
  });

  describe('selection helpers', () => {
    it('isAllSelected/parentToggle should manage selection', () => {
      const comp = createComponent();
      comp['dataSource'].data = [sample];
      expect(comp['isAllSelected']()).toBe(false);

      comp['parentToggle']();
      expect(comp['selection'].selected).toEqual([sample]);

      comp['parentToggle']();
      expect(comp['selection'].selected).toEqual([]);
    });
  });
});
