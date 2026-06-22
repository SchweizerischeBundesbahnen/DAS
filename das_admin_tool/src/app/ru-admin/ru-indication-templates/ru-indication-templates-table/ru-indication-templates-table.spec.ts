import { LOCALE_ID } from '@angular/core';
import { TestBed } from '@angular/core/testing';
import { RuIndicationTemplate } from '~ru-admin/ru-admin-api';
import { RuIndicationTemplateService } from '../ru-indication-template.service';
import { RuIndicationTemplatesTable } from './ru-indication-templates-table';

const templates: RuIndicationTemplate[] = [
  {
    id: 1,
    category: 'General',
    de: { title: 'Titel DE', text: 'Text DE' },
    fr: { title: 'Titre FR', text: 'Texte FR' },
    it: { title: 'Titolo IT', text: 'Testo IT' },
    companies: ['COMPA'],
    lastModifiedBy: 'user1',
    lastModifiedAt: new Date(),
  },
  {
    id: 2,
    category: 'Safety',
    de: { title: 'Sicherheit', text: 'Inhalt' },
    companies: ['COMPA', 'COMPB'],
    lastModifiedBy: 'user2',
    lastModifiedAt: new Date(),
  },
];

const mockRuIndicationTemplateService = {
  edit: vi.fn(),
  add: vi.fn(),
  deleteAll: vi.fn(),
  ruIndicationTemplatesResource: new Proxy({}, { get: () => vi.fn() }),
};

function createComponent(): RuIndicationTemplatesTable {
  TestBed.configureTestingModule({
    providers: [
      RuIndicationTemplatesTable,
      { provide: RuIndicationTemplateService, useValue: mockRuIndicationTemplateService },
      { provide: LOCALE_ID, useValue: 'de-CH' },
    ],
  });
  return TestBed.inject(RuIndicationTemplatesTable);
}

describe('RuIndicationTemplatesTable', () => {
  beforeEach(() => vi.clearAllMocks());

  describe('getValue', () => {
    it('should return language-specific title for "title" column', () => {
      const comp = createComponent();
      comp['form'].patchValue({ language: 'de' });
      expect(comp['getValue'](templates[0], 'title')).toBe('Titel DE');
    });

    it('should return language-specific text for "text" column', () => {
      const comp = createComponent();
      comp['form'].patchValue({ language: 'fr' });
      expect(comp['getValue'](templates[0], 'text')).toBe('Texte FR');
    });

    it('should return undefined for missing language content', () => {
      const comp = createComponent();
      comp['form'].patchValue({ language: 'it' });
      expect(comp['getValue'](templates[1], 'title')).toBeUndefined();
    });

    it('should return plain string for non-language columns', () => {
      const comp = createComponent();
      expect(comp['getValue'](templates[0], 'category')).toBe('General');
    });

    it('should return lastModifiedBy as plain string', () => {
      const comp = createComponent();
      expect(comp['getValue'](templates[0], 'lastModifiedBy')).toBe('user1');
    });
  });

  describe('searchFilter', () => {
    it('should match on DE title', () => {
      const comp = createComponent();
      comp['form'].patchValue({ language: 'de' });
      expect(comp['searchFilter']({ search: 'titel de', language: 'de' }, templates[0])).toBe(true);
    });

    it('should match on DE text', () => {
      const comp = createComponent();
      comp['form'].patchValue({ language: 'de' });
      expect(comp['searchFilter']({ search: 'text de', language: 'de' }, templates[0])).toBe(true);
    });

    it('should match on category', () => {
      const comp = createComponent();
      comp['form'].patchValue({ language: 'de' });
      expect(comp['searchFilter']({ search: 'safety', language: 'de' }, templates[1])).toBe(true);
    });

    it('should match on lastModifiedBy', () => {
      const comp = createComponent();
      comp['form'].patchValue({ language: 'de' });
      expect(comp['searchFilter']({ search: 'user2', language: 'de' }, templates[1])).toBe(true);
    });

    it('should be case-insensitive', () => {
      const comp = createComponent();
      comp['form'].patchValue({ language: 'de' });
      expect(comp['searchFilter']({ search: 'GENERAL', language: 'de' }, templates[0])).toBe(true);
    });

    it('should return false when search does not match anything', () => {
      const comp = createComponent();
      comp['form'].patchValue({ language: 'de' });
      expect(comp['searchFilter']({ search: 'xyz-nomatch', language: 'de' }, templates[0])).toBe(
        false,
      );
    });

    it('should return true when search is empty', () => {
      const comp = createComponent();
      comp['form'].patchValue({ language: 'de' });
      expect(comp['searchFilter']({ search: '', language: 'de' }, templates[0])).toBe(true);
    });
  });

  describe('isAllSelected', () => {
    it('should return false when nothing is selected', () => {
      const comp = createComponent();
      comp['dataSource'].data = templates;
      expect(comp['isAllSelected']()).toBe(false);
    });

    it('should return false when only some rows are selected', () => {
      const comp = createComponent();
      comp['dataSource'].data = templates;
      comp['selection'].select(templates[0]);
      expect(comp['isAllSelected']()).toBe(false);
    });

    it('should return true when all rows are selected', () => {
      const comp = createComponent();
      comp['dataSource'].data = templates;
      comp['selection'].select(...templates);
      expect(comp['isAllSelected']()).toBe(true);
    });
  });

  describe('parentToggle', () => {
    it('should select all rows when none are selected', () => {
      const comp = createComponent();
      comp['dataSource'].data = templates;
      comp['parentToggle']();
      expect(comp['selection'].selected).toEqual(templates);
    });

    it('should select all rows when only some are selected', () => {
      const comp = createComponent();
      comp['dataSource'].data = templates;
      comp['selection'].select(templates[0]);
      comp['parentToggle']();
      expect(comp['selection'].selected).toHaveLength(templates.length);
    });

    it('should clear selection when all rows are already selected', () => {
      const comp = createComponent();
      comp['dataSource'].data = templates;
      comp['selection'].select(...templates);
      comp['parentToggle']();
      expect(comp['selection'].selected).toEqual([]);
    });
  });
});
