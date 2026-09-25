import { Component, inject, signal } from '@angular/core';
import { form, FormField, required } from '@angular/forms/signals';
import { SBB_OVERLAY_DATA } from '@sbb-esta/lyne-angular/core';
import { SbbRadioButtonModule } from '@sbb-esta/lyne-angular/radio-button';
import { SbbTitleModule } from '@sbb-esta/lyne-angular/title';
import { SbbToggleCheckModule } from '@sbb-esta/lyne-angular/toggle-check';
import { RU_FEATURE_KEY_LABELS, RuFeature, RuFeatureKey } from '~ru-admin/ru-admin-api';
import { BaseDialog } from '~shared/base-dialog/base-dialog.component';
import { CompaniesInputComponent } from '~shared/companies-input/companies-input.component';

export interface RuFeatureData {
  companyCode: string;
  key: RuFeatureKey;
  enabled: boolean;
}

export type RuFeatureDialogEditResult = RuFeature | 'delete';

@Component({
  selector: 'app-ru-feature-toggle-dialog',
  imports: [
    FormField,
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
  protected readonly dialogData =
    inject<RuFeature>(SBB_OVERLAY_DATA, { optional: true }) ?? undefined;

  protected readonly dialogTitle: string;

  protected readonly ruFeatureModel = signal<RuFeatureData>({
    companyCode: '',
    key: 'WARNAPP',
    enabled: false,
  });
  protected readonly ruFeatureForm = form(this.ruFeatureModel, (ruFeature) => {
    required(ruFeature.companyCode);

    required(ruFeature.key);
  });

  protected readonly featureKeys = RU_FEATURE_KEY_LABELS();

  constructor() {
    const isEdit = this.dialogData?.id !== undefined;
    this.dialogTitle = isEdit
      ? $localize`:@@ru_feature_toggles_dialog_title_edit:DAS Mobile App Feature bearbeiten`
      : $localize`:@@ru_feature_toggles_dialog_title_create:DAS Mobile App Feature erfassen`;

    if (isEdit && this.dialogData) {
      this.ruFeatureModel.update(() => ({
        companyCode: this.dialogData!.companyCode,
        key: this.dialogData!.key,
        enabled: this.dialogData!.enabled,
      }));
    }
  }
}
