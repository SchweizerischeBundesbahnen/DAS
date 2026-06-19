import { Component, inject } from '@angular/core';
import { FormControl, FormGroup, ReactiveFormsModule, Validators } from '@angular/forms';
import { SBB_OVERLAY_DATA } from '@sbb-esta/lyne-angular/core/overlay';
import { SbbRadioButtonModule } from '@sbb-esta/lyne-angular/radio-button';
import { SbbTitleModule } from '@sbb-esta/lyne-angular/title';
import { SbbToggleCheckModule } from '@sbb-esta/lyne-angular/toggle-check';
import { RU_FEATURE_KEY_LABELS, RuFeature, RuFeatureKey } from '~ru-admin/ru-admin-api';
import { BaseDialog } from '~shared/base-dialog/base-dialog.component';
import { CompaniesInputComponent } from '~shared/companies-input/companies-input.component';

export type RuFeatureDialogEditResult = RuFeature | 'delete';

@Component({
  selector: 'app-ru-feature-toggle-dialog',
  imports: [
    ReactiveFormsModule,
    SbbTitleModule,
    SbbRadioButtonModule,
    SbbToggleCheckModule,
    BaseDialog,
    CompaniesInputComponent,
  ],
  templateUrl: './ru-feature-toggle-dialog.component.html',
  styleUrl: './ru-feature-toggle-dialog.component.css',
})
export class RuFeatureToggleDialog {
  protected readonly title: string;

  protected ruFeatureForm = new FormGroup({
    companyCode: new FormControl('', { nonNullable: true, validators: [Validators.required] }),
    key: new FormControl<RuFeatureKey>('WARNAPP', {
      nonNullable: true,
      validators: [Validators.required],
    }),
    enabled: new FormControl(false, { nonNullable: true }),
  });
  protected readonly featureKeys = RU_FEATURE_KEY_LABELS();
  protected readonly dialogData =
    inject<RuFeature>(SBB_OVERLAY_DATA, { optional: true }) ?? undefined;

  constructor() {
    const isEdit = this.dialogData?.id !== undefined;
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
}
