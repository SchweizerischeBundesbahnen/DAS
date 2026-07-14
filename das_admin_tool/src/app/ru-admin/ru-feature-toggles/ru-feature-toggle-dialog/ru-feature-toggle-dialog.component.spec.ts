import {TestBed} from '@angular/core/testing';
import {RuFeatureToggleDialog} from './ru-feature-toggle-dialog.component';
import {SBB_OVERLAY_DATA} from '@sbb-esta/lyne-angular/core/overlay';
import {RuFeature} from '../../ru-admin-api';
import {Company, CompanyService} from '../../../shared/companies-input/company.service';

const companies: Company[] = [
  {code: '1085', shortName: 'SBB'},
  {code: '1087', shortName: 'BLS'},
];

function createDialog(data?: RuFeature): RuFeatureToggleDialog {
  TestBed.configureTestingModule({
    providers: [RuFeatureToggleDialog, {provide: SBB_OVERLAY_DATA, useValue: data ?? null}],
  });
  const companyService = TestBed.inject(CompanyService);
  ((companyService as unknown) as {
    companiesResource: { hasValue: () => boolean; value: () => { data: Company[] } };
  }).companiesResource = {hasValue: () => true, value: () => ({data: companies})};
  return TestBed.inject(RuFeatureToggleDialog);
}

const existingRuFeature: RuFeature = {
  id: 1,
  companyCode: '1085',
  key: 'WARNAPP',
  enabled: true,
};

describe('RuFeatureToggleDialog', () => {
  it('should initialize in create mode without overlay data', () => {
    const dialog = createDialog();

    expect(dialog['dialogData']?.id).toBeFalsy();
    expect(dialog['ruFeatureForm'].value).toEqual({
      companyCode: '',
      key: 'WARNAPP',
      enabled: false,
    });
  });

  it('should initialize in edit mode and patch existing values', () => {
    const dialog = createDialog(existingRuFeature);

    expect(dialog['dialogData']?.id).toBeDefined();
    expect(dialog['ruFeatureForm'].value).toEqual({
      companyCode: '1085',
      key: 'WARNAPP',
      enabled: true,
    });
  });

  it('companyCode should be invalid when empty', () => {
    const dialog = createDialog();

    dialog['ruFeatureForm'].get('companyCode')!.setValue('');
    dialog['ruFeatureForm'].get('companyCode')!.markAsTouched();

    expect(dialog['ruFeatureForm'].get('companyCode')!.errors).toEqual({required: true});
  });

  it('should filter companies by search term', () => {
    const dialog = createDialog();

    dialog['searchTerm'].set('sbb');

    expect(dialog['filteredCompanies']().map((company) => company.code)).toEqual(['1085']);
  });

  it('formValue should reflect the current form state', () => {
    const dialog = createDialog();

    dialog['ruFeatureForm'].patchValue({
      companyCode: '1087',
      key: 'CHECKLIST_DEPARTURE_PROCESS',
      enabled: true,
    });

    expect(dialog.formValue).toEqual({
      companyCode: '1087',
      key: 'CHECKLIST_DEPARTURE_PROCESS',
      enabled: true,
    });
  });

  it('companyDisplayWith should resolve a code to the company name', () => {
    const dialog = createDialog();

    expect(dialog['companyDisplayWith']('1085')).toBe('SBB');
    expect(dialog['companyDisplayWith']('9999')).toBe('9999');
    expect(dialog['companyDisplayWith'](undefined)).toBe('');
  });
});
