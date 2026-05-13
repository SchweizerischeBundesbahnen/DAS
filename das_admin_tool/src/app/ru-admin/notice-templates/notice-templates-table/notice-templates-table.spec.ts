import {TestBed} from '@angular/core/testing';
import {NoticeTemplatesTable} from './notice-templates-table';
import {NoticeTemplateService} from '../notice-template.service';
import {LOCALE_ID} from '@angular/core';
import {NoticeTemplate, NoticeTemplateApiResponse} from '../../ru-admin-api';
import {HttpResourceRef} from '@angular/common/http';

const templates: NoticeTemplate[] = [
  {
    id: 1,
    category: 'General',
    de: {title: 'Titel DE', text: 'Text DE'},
    fr: {title: 'Titre FR', text: 'Texte FR'},
    it: {title: 'Titolo IT', text: 'Testo IT'},
    lastModifiedBy: 'user1',
  },
  {
    id: 2,
    category: 'Safety',
    de: {title: 'Sicherheit', text: 'Inhalt'},
    lastModifiedBy: 'user2',
  },
];

const mockNoticeTemplateService: Partial<NoticeTemplateService> = {
  edit: vi.fn(),
  add: vi.fn(),
  deleteAll: vi.fn(),
  noticeTemplatesResource: {
    hasValue: () => false,
    value: () => ({data: []} as NoticeTemplateApiResponse),
    reload: () => true,
  } as unknown as HttpResourceRef<NoticeTemplateApiResponse | undefined>,
};

function createComponent(): NoticeTemplatesTable {
  TestBed.configureTestingModule({
    providers: [
      NoticeTemplatesTable,
      {provide: NoticeTemplateService, useValue: mockNoticeTemplateService},
      {provide: LOCALE_ID, useValue: 'de-CH'},
    ],
  });
  return TestBed.inject(NoticeTemplatesTable);
}

describe('NoticeTemplatesTable', () => {
  beforeEach(() => vi.clearAllMocks());

  describe('getValue', () => {
    it('should return language-specific title for "title" column', () => {
      const comp = createComponent();
      comp['form'].patchValue({language: 'de'});
      expect(comp['getValue'](templates[0], 'title')).toBe('Titel DE');
    });

    it('should return language-specific text for "text" column', () => {
      const comp = createComponent();
      comp['form'].patchValue({language: 'fr'});
      expect(comp['getValue'](templates[0], 'text')).toBe('Texte FR');
    });

    it('should return undefined for missing language content', () => {
      const comp = createComponent();
      comp['form'].patchValue({language: 'it'});
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
      comp['form'].patchValue({language: 'de'});
      expect(comp['searchFilter']({search: 'titel de', language: 'de'}, templates[0])).toBe(true);
    });

    it('should match on DE text', () => {
      const comp = createComponent();
      comp['form'].patchValue({language: 'de'});
      expect(comp['searchFilter']({search: 'text de', language: 'de'}, templates[0])).toBe(true);
    });

    it('should match on category', () => {
      const comp = createComponent();
      comp['form'].patchValue({language: 'de'});
      expect(comp['searchFilter']({search: 'safety', language: 'de'}, templates[1])).toBe(true);
    });

    it('should match on lastModifiedBy', () => {
      const comp = createComponent();
      comp['form'].patchValue({language: 'de'});
      expect(comp['searchFilter']({search: 'user2', language: 'de'}, templates[1])).toBe(true);
    });

    it('should be case-insensitive', () => {
      const comp = createComponent();
      comp['form'].patchValue({language: 'de'});
      expect(comp['searchFilter']({search: 'GENERAL', language: 'de'}, templates[0])).toBe(true);
    });

    it('should return false when search does not match anything', () => {
      const comp = createComponent();
      comp['form'].patchValue({language: 'de'});
      expect(comp['searchFilter']({
        search: 'xyz-nomatch',
        language: 'de'
      }, templates[0])).toBe(false);
    });

    it('should return true when search is empty', () => {
      const comp = createComponent();
      comp['form'].patchValue({language: 'de'});
      expect(comp['searchFilter']({search: '', language: 'de'}, templates[0])).toBe(true);
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
      expect(comp['selection'].selected.length).toBe(templates.length);
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

