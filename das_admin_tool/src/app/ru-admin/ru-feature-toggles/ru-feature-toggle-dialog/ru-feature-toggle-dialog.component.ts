import {Component, computed, inject, signal} from '@angular/core';
import {SbbTitleModule} from '@sbb-esta/lyne-angular/title';
import {SbbFormFieldModule} from '@sbb-esta/lyne-angular/form-field';
import {SbbAutocompleteModule} from '@sbb-esta/lyne-angular/autocomplete';
import {SbbOptionModule} from '@sbb-esta/lyne-angular/option';
import {SbbRadioButtonModule} from '@sbb-esta/lyne-angular/radio-button';
import {SbbToggleCheckModule} from '@sbb-esta/lyne-angular/toggle-check';
import {SBB_OVERLAY_DATA} from '@sbb-esta/lyne-angular/core/overlay';
import {FormControl, FormGroup, ReactiveFormsModule, Validators} from '@angular/forms';
import {RU_FEATURE_KEY_LABELS, RuFeature, RuFeatureKey} from '../../ru-admin-api';
import {BaseDialog} from '../../../shared/base-dialog/base-dialog.component';
import {CompanyService} from '../../../shared/companies-input/company.service';

export type RuFeatureDialogEditResult = RuFeature | 'delete';

@Component({
  selector: 'app-ru-feature-toggle-dialog',
  imports: [
    ReactiveFormsModule,
    SbbTitleModule,
    SbbFormFieldModule,
    SbbAutocompleteModule,
    SbbOptionModule,
    SbbRadioButtonModule,
    SbbToggleCheckModule,
    BaseDialog,
  ],
  templateUrl: './ru-feature-toggle-dialog.component.html',
  styleUrl: './ru-feature-toggle-dialog.component.css',
})
export class RuFeatureToggleDialog {
  protected readonly title: string;

  protected ruFeatureForm = new FormGroup({
    companyCode: new FormControl('', {nonNullable: true, validators: [Validators.required]}),
    key: new FormControl<RuFeatureKey>('WARNAPP', {nonNullable: true, validators: [Validators.required]}),
    enabled: new FormControl(false, {nonNullable: true}),
  });
  protected readonly featureKeys = RU_FEATURE_KEY_LABELS;
  protected readonly dialogData = inject<RuFeature>(SBB_OVERLAY_DATA, {optional: true}) ?? undefined;

  private readonly companyService = inject(CompanyService);
  protected readonly searchTerm = signal<string>('');
  protected filteredCompanies = computed(() => {
    const term = this.searchTerm();
    return this.companyService.filterCompanies(term);
  });

  constructor() {
    const isEdit = this.dialogData?.id != null;
    this.title = isEdit
      ? $localize`:@@ru_feature_toggles_dialog_title_edit:DAS Mobile App Feature bearbeiten`
      : $localize`:@@ru_feature_toggles_dialog_title_create:DAS Mobile App Feature erfassen`;

    if (isEdit && this.dialogData) {
      this.ruFeatureForm.patchValue({
        companyCode: this.dialogData.companyCode,
        key: this.dialogData.key,
        enabled: this.dialogData.enabled,
      });
    }
  }

  get formValue(): RuFeature {
    return {
      companyCode: this.ruFeatureForm.value.companyCode ?? '',
      key: this.ruFeatureForm.value.key ?? 'WARNAPP',
      enabled: this.ruFeatureForm.value.enabled ?? false,
    };
  }

  protected onCompanyCodeInput(event: Event): void {
    const input = event.target as HTMLInputElement;
    this.searchTerm.set(input.value);
  }

  protected companyDisplayWith = (code: string | undefined): string => {
    if (!code) return '';
    return this.companyService.getName(code) ?? code;
  };
}
