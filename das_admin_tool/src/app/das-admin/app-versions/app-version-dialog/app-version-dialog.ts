import {Component, inject} from '@angular/core';
import {
  SbbDialogActions,
  SbbDialogClose,
  SbbDialogContent,
  SbbDialogTitle
} from '@sbb-esta/lyne-angular/dialog';
import {SbbButton} from '@sbb-esta/lyne-angular/button/button';
import {SbbSecondaryButton} from '@sbb-esta/lyne-angular/button/secondary-button';
import {SbbError, SbbFormField} from '@sbb-esta/lyne-angular/form-field';
import {SbbToggleCheck} from '@sbb-esta/lyne-angular/toggle-check';
import {
  SbbDatepicker,
  SbbDatepickerNextDay,
  SbbDatepickerPreviousDay,
  SbbDatepickerToggle
} from '@sbb-esta/lyne-angular/datepicker';
import {SbbDateInput} from '@sbb-esta/lyne-angular/date-input';
import {FormControl, FormGroup, ReactiveFormsModule, Validators} from '@angular/forms';
import {AppVersion} from '../../das-admin-api';
import {SBB_OVERLAY_DATA} from '@sbb-esta/lyne-angular/core/overlay';
import {SbbTransparentButton} from '@sbb-esta/lyne-angular/button/transparent-button';
import {SbbPopover} from '@sbb-esta/lyne-angular/popover';
import {SbbTitle} from '@sbb-esta/lyne-angular/title';
import {SbbMiniButton} from '@sbb-esta/lyne-angular/button/mini-button';
import {toUtcDateOnly} from '../../../shared/date-util';

export type VersionDialogEditResult = AppVersion | 'delete';

@Component({
  selector: 'app-app-version-dialog',
  imports: [
    SbbDialogTitle,
    SbbDialogActions,
    SbbButton,
    SbbSecondaryButton,
    SbbDialogClose,
    SbbDialogContent,
    SbbFormField,
    SbbError,
    SbbToggleCheck,
    SbbDatepickerPreviousDay,
    SbbDateInput,
    SbbDatepicker,
    SbbDatepickerToggle,
    SbbDatepickerNextDay,
    ReactiveFormsModule,
    SbbTransparentButton,
    SbbPopover,
    SbbTitle,
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
  private dialogData = inject<AppVersion>(SBB_OVERLAY_DATA, {optional: true}) ?? null;

  constructor() {
    this.isEdit = this.dialogData?.id != null;
    this.title = this.isEdit ? $localize`:@@appVersionEditTitle:Blockierte App Version bearbeiten` : $localize`:@@appVersionCreateTitle:App Version blockieren`;

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
