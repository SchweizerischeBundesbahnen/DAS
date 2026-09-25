import { Component, inject, signal } from '@angular/core';
import { form, FormField, pattern, required } from '@angular/forms/signals';
import { SbbMiniButton } from '@sbb-esta/lyne-angular/button';
import { SBB_OVERLAY_DATA } from '@sbb-esta/lyne-angular/core';
import { SbbDateInputModule } from '@sbb-esta/lyne-angular/date-input';
import { SbbDatepickerModule } from '@sbb-esta/lyne-angular/datepicker';
import { SbbFormFieldModule } from '@sbb-esta/lyne-angular/form-field';
import { SbbPopoverModule } from '@sbb-esta/lyne-angular/popover';
import { SbbTitleModule } from '@sbb-esta/lyne-angular/title';
import { SbbToggleCheckModule } from '@sbb-esta/lyne-angular/toggle-check';
import { AppVersion } from '~app/das-admin/das-admin-api';
import { BaseDialog } from '~shared/base-dialog/base-dialog.component';
import { toUtcDateOnly } from '~shared/date-util';

interface VersionData {
  version: string;
  minimalVersion: boolean;
  expiryDate: Date | null;
}

export type VersionDialogEditResult = AppVersion | 'delete';

@Component({
  selector: 'app-app-version-dialog',
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

  private static readonly VERSION_REGEX = /^\d+\.\d+\.\d+$/;

  protected readonly dialogTitle: string;

  protected readonly versionModel = signal<VersionData>({
    version: '',
    minimalVersion: false,
    expiryDate: null,
  });
  protected readonly versionForm = form(this.versionModel, (version) => {
    required(version.version, {
      message: $localize`:@@form_field_error_required:Feld darf nicht leer sein`,
    });
    pattern(version.version, AppVersionDialog.VERSION_REGEX, {
      message: $localize`:@@app_versions_form_version_error_pattern:Feld muss dem Format MAJOR.MINOR.PATCH entsprechen`,
    });
  });

  protected minDate = new Date();

  constructor() {
    const isEdit = this.dialogData?.id !== undefined;
    this.dialogTitle = isEdit
      ? $localize`:@@app_versions_dialog_title_edit:Blockierte App Version bearbeiten`
      : $localize`:@@app_versions_dialog_title_create:App Version blockieren`;

    if (isEdit && this.dialogData) {
      this.versionModel.update((initial) => ({
        version: this.dialogData!.version,
        minimalVersion: this.dialogData!.minimalVersion,
        expiryDate: this.dialogData!.expiryDate
          ? new Date(this.dialogData!.expiryDate)
          : initial.expiryDate,
      }));
    }
  }

  get formValue(): AppVersion {
    const formValue = this.versionModel();
    return {
      ...formValue,
      expiryDate: formValue.expiryDate ? toUtcDateOnly(formValue.expiryDate).toJSON() : undefined,
    };
  }
}
