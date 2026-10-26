import { Component, inject, signal } from '@angular/core';
import { form, FormField, required, validate } from '@angular/forms/signals';
import { SbbMiniButton } from '@sbb-esta/lyne-angular/button';
import { SBB_OVERLAY_DATA } from '@sbb-esta/lyne-angular/core';
import { SbbDateInputModule } from '@sbb-esta/lyne-angular/date-input';
import { SbbDatepickerModule } from '@sbb-esta/lyne-angular/datepicker';
import { SbbFormFieldModule } from '@sbb-esta/lyne-angular/form-field';
import { SbbPopoverModule } from '@sbb-esta/lyne-angular/popover';
import { SbbTitleModule } from '@sbb-esta/lyne-angular/title';
import { SbbToggleCheckModule } from '@sbb-esta/lyne-angular/toggle-check';
import { AppVersion } from '~app/das-admin/das-admin.api';
import { BaseDialog } from '~shared/components/base-dialog/base-dialog';
import { toUtcDateOnly } from '~shared/utils/date.util';

interface AppVersionData {
  version: string;
  minimalVersion: boolean;
  expiryDate: Date | null;
}

/**
 * Trims the version and strips leading zeros of each part, e.g. ' 01.002.3 ' becomes '1.2.3'.
 */
export function normalizeVersion(version: string): string {
  return version.trim().replaceAll(/(^|\.)0+(?=\d)/g, '$1');
}

export type AppVersionDialogEditResult = AppVersion | 'delete';

@Component({
  selector: 'app-version-dialog',
  imports: [
    FormField,
    SbbFormFieldModule,
    SbbToggleCheckModule,
    SbbDateInputModule,
    SbbDatepickerModule,
    SbbPopoverModule,
    SbbTitleModule,
    SbbMiniButton,
    BaseDialog,
  ],
  templateUrl: './app-version-dialog.html',
  styleUrl: './app-version-dialog.css',
})
export class AppVersionDialog {
  protected readonly dialogData =
    inject<AppVersion>(SBB_OVERLAY_DATA, { optional: true }) ?? undefined;

  // Must match SemanticVersion.SEM_VERSION_PATTERN in das_backend: 0-99999 per part, no leading zeros.
  private static readonly APP_VERSION_REGEX =
    /^(0|[1-9]\d{0,4})\.(0|[1-9]\d{0,4})\.(0|[1-9]\d{0,4})$/;

  protected readonly dialogTitle: string;

  protected readonly appVersionModel = signal<AppVersionData>({
    version: '',
    minimalVersion: false,
    expiryDate: null,
  });
  protected readonly appVersionForm = form(this.appVersionModel, (appVersion) => {
    required(appVersion.version, {
      message: $localize`:@@form_field_error_required:Feld darf nicht leer sein`,
    });
    validate(appVersion.version, ({ value }) =>
      AppVersionDialog.APP_VERSION_REGEX.test(normalizeVersion(value()))
        ? null
        : {
            kind: 'pattern',
            message: $localize`:@@app_versions_form_version_error_pattern:Feld muss dem Format MAJOR.MINOR.PATCH entsprechen, jeweils 0 bis 99999 (z.B. 1.2.3)`,
          },
    );
  });

  protected minDate = new Date();

  constructor() {
    const isEdit = this.dialogData?.id !== undefined;
    this.dialogTitle = isEdit
      ? $localize`:@@app_versions_dialog_title_edit:Blockierte App Version bearbeiten`
      : $localize`:@@app_versions_dialog_title_create:App Version blockieren`;

    if (isEdit && this.dialogData) {
      this.appVersionModel.update((initial) => ({
        version: this.dialogData!.version,
        minimalVersion: this.dialogData!.minimalVersion,
        expiryDate: this.dialogData!.expiryDate
          ? new Date(this.dialogData!.expiryDate)
          : initial.expiryDate,
      }));
    }
  }

  get formValue(): AppVersion {
    const formValue = this.appVersionModel();
    return {
      ...formValue,
      version: normalizeVersion(formValue.version),
      expiryDate: formValue.expiryDate ? toUtcDateOnly(formValue.expiryDate).toJSON() : undefined,
    };
  }
}
