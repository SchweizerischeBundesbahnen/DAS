import { ComponentFixture, TestBed } from '@angular/core/testing';
import { SBB_OVERLAY_DATA } from '@sbb-esta/lyne-angular/core';
import { CompanyService } from '~shared/companies-input/company.service';
import { RecentCompaniesStore } from '~shared/recent-companies.store';
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

  describe('content form required field validation', () => {
    it('should have content form invalid when all fields are empty', () => {
      const contentForm = component['ruIndicationForm'].controls.content;
      expect(contentForm.invalid).toBe(true);
    });

    it('should have oneLanguageRequired error when no language content is provided', () => {
      const contentForm = component['ruIndicationForm'].controls.content;
      expect(contentForm.errors).toEqual({ oneLanguageRequired: true });
    });

    it('should disable the next button when content form is empty', () => {
      expect(component['isStepDisabled']()).toBe(true);
    });

    it('should require text when title is set (languageRequired)', () => {
      const contentForm = component['ruIndicationForm'].controls.content;
      contentForm.get('de.title')!.setValue('Titel');
      contentForm.get('de.text')!.setValue('');
      contentForm.get('de')!.updateValueAndValidity();

      expect(contentForm.get('de.text')!.errors).toEqual({ languageRequired: true });
    });

    it('should require title when text is set (languageRequired)', () => {
      const contentForm = component['ruIndicationForm'].controls.content;
      contentForm.get('de.title')!.setValue('');
      contentForm.get('de.text')!.setValue('Some text');
      contentForm.get('de')!.updateValueAndValidity();

      expect(contentForm.get('de.title')!.errors).toEqual({ languageRequired: true });
    });

    it('should be valid when both title and text are provided in one language', () => {
      const contentForm = component['ruIndicationForm'].controls.content;
      contentForm.get('de.title')!.setValue('Titel');
      contentForm.get('de.text')!.setValue('Text');
      contentForm.updateValueAndValidity();

      expect(contentForm.invalid).toBe(false);
    });

    it('should enable the next button when content form is valid', () => {
      const contentForm = component['ruIndicationForm'].controls.content;
      contentForm.get('de.title')!.setValue('Titel');
      contentForm.get('de.text')!.setValue('Text');
      contentForm.updateValueAndValidity();
      fixture.detectChanges();

      expect(component['isStepDisabled']()).toBe(false);
    });

    it('should remain invalid when title contains only whitespace', () => {
      const contentForm = component['ruIndicationForm'].controls.content;
      contentForm.get('de.title')!.setValue('  ');
      contentForm.get('de.text')!.setValue('  ');
      contentForm.updateValueAndValidity();

      expect(contentForm.invalid).toBe(true);
    });
  });
});
