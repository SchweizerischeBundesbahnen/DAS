import { TestBed } from '@angular/core/testing';
import { SBB_OVERLAY_DATA } from '@sbb-esta/lyne-angular/core';
import { RuFeature } from '~ru-admin/ru-admin-api';
import { Company, CompanyService } from '~shared/companies-input/company.service';
import { expectError } from '~src/testing/utils';
import { RuFeatureToggleDialog } from './ru-feature-toggle-dialog.component';

const companies: Company[] = [
  { code: '1085', shortName: 'SBB' },
  { code: '1087', shortName: 'BLS' },
];

function createDialog(data?: RuFeature): RuFeatureToggleDialog {
  TestBed.configureTestingModule({
    providers: [RuFeatureToggleDialog, { provide: SBB_OVERLAY_DATA, useValue: data ?? null }],
  });
  const companyService = TestBed.inject(CompanyService);
  (
    companyService as unknown as {
      companiesResource: {
        hasValue: () => boolean;
        value: () => { data: Company[] };
        error: () => unknown;
      };
    }
  ).companiesResource = {
    hasValue: () => true,
    value: () => ({ data: companies }),
    error: vi.fn(),
  };
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
    expect(dialog['ruFeatureForm']().value()).toEqual({
      companyCode: '',
      key: 'WARNAPP',
      enabled: false,
    });
  });

  it('should initialize in edit mode and patch existing values', () => {
    const dialog = createDialog(existingRuFeature);

    expect(dialog['dialogData']?.id).toBeDefined();
    expect(dialog['ruFeatureForm']().value()).toEqual({
      companyCode: '1085',
      key: 'WARNAPP',
      enabled: true,
    });
  });

  it('companyCode should be invalid when empty', () => {
    const dialog = createDialog();

    dialog['ruFeatureForm'].companyCode().value.set('');

    expect(expectError(dialog['ruFeatureForm'].companyCode(), 'required')).toBe(true);
  });

  it('companyCode should be valid when it matches a known company', () => {
    const dialog = createDialog();

    dialog['ruFeatureForm'].companyCode().value.set('1085');

    expect(dialog['ruFeatureForm'].companyCode().errors()).toEqual([]);
  });
});
