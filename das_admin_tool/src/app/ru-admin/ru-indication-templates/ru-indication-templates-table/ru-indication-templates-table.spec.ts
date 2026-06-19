import { ComponentFixture, TestBed } from '@angular/core/testing';
import { RuIndicationTemplatesTable } from './ru-indication-templates-table';
import { RuIndicationTemplateService } from '../ru-indication-template.service';
import { LOCALE_ID } from '@angular/core';
import { RuIndicationTemplate } from '../../ru-admin-api';

const templates: RuIndicationTemplate[] = [
  {
    id: 1,
    category: 'General',
    de: { title: 'Titel DE', text: 'Text DE' },
    fr: { title: 'Titre FR', text: 'Texte FR' },
    it: { title: 'Titolo IT', text: 'Testo IT' },
    lastModifiedBy: 'user1',
    lastModifiedAt: new Date(),
  },
  {
    id: 2,
    category: 'Safety',
    de: { title: 'Sicherheit', text: 'Inhalt' },
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

describe('RuIndicationTemplatesTable', () => {
  let component: RuIndicationTemplatesTable;
  let fixture: ComponentFixture<RuIndicationTemplatesTable>;

  beforeEach(async () => {
    vi.clearAllMocks();

    await TestBed.configureTestingModule({
      imports: [RuIndicationTemplatesTable],
      providers: [
        { provide: RuIndicationTemplateService, useValue: mockRuIndicationTemplateService },
        { provide: LOCALE_ID, useValue: 'de-CH' },
      ],
    }).compileComponents();

    fixture = TestBed.createComponent(RuIndicationTemplatesTable);
    component = fixture.componentInstance;
    await fixture.whenStable();
  });

  describe('currentLanguage', () => {
    it('should return language-specific value for "title" column', () => {
      component['form'].patchValue({ language: 'de' });
      expect(component['currentLanguage'](templates[0])?.title).toBe('Titel DE');
    });

    it('should return language-specific value for "text" column', () => {
      component['form'].patchValue({ language: 'fr' });
      expect(component['currentLanguage'](templates[0])?.text).toBe('Texte FR');
    });

    it('should return undefined for missing language content', () => {
      component['form'].patchValue({ language: 'it' });
      expect(component['currentLanguage'](templates[1])?.title).toBeUndefined();
    });
  });

  describe('searchFilter', () => {
    it('should match on DE title', () => {
      component['form'].patchValue({ language: 'de' });
      expect(component['searchFilter']({ search: 'titel de', language: 'de' }, templates[0])).toBe(
        true,
      );
    });

    it('should match on DE text', () => {
      component['form'].patchValue({ language: 'de' });
      expect(component['searchFilter']({ search: 'text de', language: 'de' }, templates[0])).toBe(
        true,
      );
    });

    it('should match on category', () => {
      component['form'].patchValue({ language: 'de' });
      expect(component['searchFilter']({ search: 'safety', language: 'de' }, templates[1])).toBe(
        true,
      );
    });

    it('should match on lastModifiedBy', () => {
      component['form'].patchValue({ language: 'de' });
      expect(component['searchFilter']({ search: 'user2', language: 'de' }, templates[1])).toBe(
        true,
      );
    });

    it('should be case-insensitive', () => {
      component['form'].patchValue({ language: 'de' });
      expect(component['searchFilter']({ search: 'GENERAL', language: 'de' }, templates[0])).toBe(
        true,
      );
    });

    it('should return false when search does not match anything', () => {
      component['form'].patchValue({ language: 'de' });
      expect(
        component['searchFilter'](
          {
            search: 'xyz-nomatch',
            language: 'de',
          },
          templates[0],
        ),
      ).toBe(false);
    });

    it('should return true when search is empty', () => {
      component['form'].patchValue({ language: 'de' });
      expect(component['searchFilter']({ search: '', language: 'de' }, templates[0])).toBe(true);
    });
  });

  describe('isAllSelected', () => {
    it('should return false when nothing is selected', () => {
      component['dataSource'].data = templates;
      expect(component['isAllSelected']()).toBe(false);
    });

    it('should return false when only some rows are selected', () => {
      component['dataSource'].data = templates;
      component['selection'].select(templates[0]);
      expect(component['isAllSelected']()).toBe(false);
    });

    it('should return true when all rows are selected', () => {
      component['dataSource'].data = templates;
      component['selection'].select(...templates);
      expect(component['isAllSelected']()).toBe(true);
    });
  });

  describe('parentToggle', () => {
    it('should select all rows when none are selected', () => {
      component['dataSource'].data = templates;
      component['parentToggle']();
      expect(component['selection'].selected).toEqual(templates);
    });

    it('should select all rows when only some are selected', () => {
      component['dataSource'].data = templates;
      component['selection'].select(templates[0]);
      component['parentToggle']();
      expect(component['selection'].selected.length).toBe(templates.length);
    });

    it('should clear selection when all rows are already selected', () => {
      component['dataSource'].data = templates;
      component['selection'].select(...templates);
      component['parentToggle']();
      expect(component['selection'].selected).toEqual([]);
    });
  });
});
