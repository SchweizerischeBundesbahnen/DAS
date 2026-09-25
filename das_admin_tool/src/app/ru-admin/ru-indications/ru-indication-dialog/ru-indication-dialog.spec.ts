import { ComponentFixture, TestBed } from '@angular/core/testing';
import { SBB_OVERLAY_DATA } from '@sbb-esta/lyne-angular/core';
import { CompanyService } from '~shared/companies-input/company.service';
import { RecentCompaniesStore } from '~shared/recent-companies.store';
import { expectError } from '~src/testing/utils';
import { RuIndicationDialogData } from '../ru-indication.service';
import { RuIndicationDialog } from './ru-indication-dialog.component';

const mockRecentCompaniesStore = { get: () => [] };

const mockCompanyService = {
  filterCompanies: vi.fn(),
};

const dialogData: RuIndicationDialogData = { ruIndication: undefined, templates: [] };

describe('RuIndicationDialog', () => {
  let component: RuIndicationDialog;
  let fixture: ComponentFixture<RuIndicationDialog>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [RuIndicationDialog],
      providers: [
        { provide: SBB_OVERLAY_DATA, useValue: dialogData },
        { provide: CompanyService, useValue: mockCompanyService },
        { provide: RecentCompaniesStore, useValue: mockRecentCompaniesStore },
      ],
    }).compileComponents();

    fixture = TestBed.createComponent(RuIndicationDialog);
    component = fixture.componentInstance;
    await fixture.whenStable();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });

  describe('field validation - content', () => {
    it('should be invalid when form is empty', () => {
      const form = component['ruIndicationForm'];

      expect(form().invalid()).toBe(true);
    });

    it('should have oneLanguageRequired error when no language content is provided', () => {
      const form = component['ruIndicationForm'];

      expect(expectError(form.content(), 'oneLanguageRequired')).toBe(true);
    });

    it('should disable the next button when content form is empty', () => {
      expect(component['isStepDisabled']()).toBe(true);
    });

    it('should require text when title is set (languageRequired)', () => {
      const form = component['ruIndicationForm'];
      form.content.de.title().value.set('Titel');

      expect(expectError(form.content.de.text(), 'languageRequired')).toBe(true);
    });

    it('should require title when text is set (languageRequired)', () => {
      const form = component['ruIndicationForm'];
      form.content.de.text().value.set('Some text');

      expect(expectError(form.content.de.title(), 'languageRequired')).toBe(true);
    });

    it('should be valid when both title and text are provided in one language', () => {
      const form = component['ruIndicationForm'];
      form.content.de.title().value.set('Titel');
      form.content.de.text().value.set('Text');

      expect(form.content().errors()).toEqual([]);
      expect(form.content.de().errors()).toEqual([]);
    });

    it('should enable the next button when content form is valid', () => {
      const form = component['ruIndicationForm'];
      form.content.de.title().value.set('Titel');
      form.content.de.text().value.set('Text');
      fixture.detectChanges();

      expect(component['isStepDisabled']()).toBe(false);
    });

    it('should remain invalid when title contains only whitespace', () => {
      const form = component['ruIndicationForm'];
      form.content.de.title().value.set('  ');
      form.content.de.text().value.set('  ');

      expect(form().invalid()).toBe(true);
    });
  });

  describe('field validation - operationalTrainNumber', () => {
    it('should be valid when mode is set to filtered and then back to all', () => {
      const form = component['ruIndicationForm'];
      form.scope.operationalTrainNumber.mode().value.set('filtered');

      expect(expectError(form.scope.operationalTrainNumber.filters(), 'arrayRequired')).toBe(true);

      form.scope.operationalTrainNumber.mode().value.set('all');

      expect(form.scope.operationalTrainNumber.filters().errors()).toEqual([]);
    });

    it('should be valid when mode is set to filtered and filters are not empty', () => {
      const form = component['ruIndicationForm'];
      form.scope.operationalTrainNumber.mode().value.set('filtered');
      form.scope.operationalTrainNumber.filters().value.set([{ expression: '1', parity: 'ANY' }]);

      expect(form.scope.operationalTrainNumber.filters().errors()).toEqual([]);
    });
  });
});
