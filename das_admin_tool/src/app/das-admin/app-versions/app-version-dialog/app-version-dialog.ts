import { Component, inject } from '@angular/core';
import { FormControl, FormGroup, ReactiveFormsModule, Validators } from '@angular/forms';
import { SbbMiniButton } from '@sbb-esta/lyne-angular/button/mini-button';
import { SBB_OVERLAY_DATA } from '@sbb-esta/lyne-angular/core/overlay';
import { SbbDateInputModule } from '@sbb-esta/lyne-angular/date-input';
import { SbbDatepickerModule } from '@sbb-esta/lyne-angular/datepicker';
import { SbbFormFieldModule } from '@sbb-esta/lyne-angular/form-field';
import { SbbPopoverModule } from '@sbb-esta/lyne-angular/popover';
import { SbbTitleModule } from '@sbb-esta/lyne-angular/title';
import { SbbToggleCheckModule } from '@sbb-esta/lyne-angular/toggle-check';
import { AppVersion } from '~app/das-admin/das-admin-api';
import { BaseDialog } from '~shared/base-dialog/base-dialog.component';
import { toUtcDateOnly } from '~shared/date-util';

export type VersionDialogEditResult = AppVersion | 'delete';

@Component({
  selector: 'app-app-version-dialog',
  imports: [
    ReactiveFormsModule,
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
  private static readonly VERSION_REGEX = /^\d+\.\d+\.\d+$/;

  protected readonly title: string;
  protected readonly isEdit: boolean;

  protected versionForm = new FormGroup({
    version: new FormControl('', {
      nonNullable: true,
      validators: [Validators.required, Validators.pattern(AppVersionDialog.VERSION_REGEX)],
    }),
    minimalVersion: new FormControl(false, { nonNullable: true }),
    expiryDate: new FormControl<Date | null>(null),
  });
  protected minDate = new Date();
  protected readonly dialogData =
    inject<AppVersion>(SBB_OVERLAY_DATA, { optional: true }) ?? undefined;

  constructor() {
    this.isEdit = this.dialogData?.id !== undefined;
    this.title = this.isEdit
      ? $localize`:@@app_versions_dialog_title_edit:Blockierte App Version bearbeiten`
      : $localize`:@@app_versions_dialog_title_create:App Version blockieren`;

    if (this.isEdit && this.dialogData) {
      this.versionForm.patchValue({
        version: this.dialogData.version,
        minimalVersion: this.dialogData.minimalVersion,
        expiryDate: this.dialogData.expiryDate ? new Date(this.dialogData.expiryDate) : null,
      });
    }
  }

  get formValue(): AppVersion {
    const formValue = this.versionForm.value;
    return {
      ...formValue,
      expiryDate: formValue.expiryDate ? toUtcDateOnly(formValue.expiryDate) : undefined,
    } as AppVersion;
  }
}
