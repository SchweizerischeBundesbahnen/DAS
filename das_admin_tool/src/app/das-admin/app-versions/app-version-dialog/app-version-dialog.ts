import {Component, inject} from '@angular/core';
import {SbbButton} from '@sbb-esta/lyne-angular/button/button';
import {SbbSecondaryButton} from '@sbb-esta/lyne-angular/button/secondary-button';
import {SbbToggleCheckModule} from '@sbb-esta/lyne-angular/toggle-check';
import {SbbDatepickerModule} from '@sbb-esta/lyne-angular/datepicker';
import {SbbDateInputModule} from '@sbb-esta/lyne-angular/date-input';
import {FormControl, FormGroup, ReactiveFormsModule, Validators} from '@angular/forms';
import {AppVersion} from '../../das-admin-api';
import {SBB_OVERLAY_DATA} from '@sbb-esta/lyne-angular/core/overlay';
import {SbbTransparentButton} from '@sbb-esta/lyne-angular/button/transparent-button';
import {SbbPopoverModule} from '@sbb-esta/lyne-angular/popover';
import {SbbTitleModule} from '@sbb-esta/lyne-angular/title';
import {SbbMiniButton} from '@sbb-esta/lyne-angular/button/mini-button';
import {toUtcDateOnly} from '../../../shared/date-util';
import {SbbDialogModule} from '@sbb-esta/lyne-angular/dialog';
import {SbbFormFieldModule} from '@sbb-esta/lyne-angular/form-field';

export type VersionDialogEditResult = AppVersion | 'delete';

@Component({
  selector: 'app-app-version-dialog',
  imports: [
    SbbDialogModule,
    SbbButton,
    SbbSecondaryButton,
    SbbFormFieldModule,
    SbbToggleCheckModule,
    SbbDateInputModule,
    SbbDatepickerModule,
    ReactiveFormsModule,
    SbbTransparentButton,
    SbbPopoverModule,
    SbbTitleModule,
    SbbMiniButton
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
      validators: [Validators.required, Validators.pattern(AppVersionDialog.VERSION_REGEX)]
    }),
    minimalVersion: new FormControl(false, {nonNullable: true}),
    expiryDate: new FormControl<Date | null>(null)
  });
  protected minDate = new Date();
  private readonly dialogData = inject<AppVersion>(SBB_OVERLAY_DATA, {optional: true}) ?? null;

  constructor() {
    this.isEdit = this.dialogData?.id != null;
    this.title = this.isEdit ? $localize`:@@app_versions_dialog_title_edit:Blockierte App Version bearbeiten` : $localize`:@@app_versions_dialog_title_create:App Version blockieren`;

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
      expiryDate: formValue.expiryDate ? toUtcDateOnly(formValue.expiryDate) : undefined
    } as AppVersion;
  }
}
