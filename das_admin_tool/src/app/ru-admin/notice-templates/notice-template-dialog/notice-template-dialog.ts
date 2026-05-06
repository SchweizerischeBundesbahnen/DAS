import {Component, inject} from '@angular/core';
import {SbbButton} from '@sbb-esta/lyne-angular/button/button';
import {SbbSecondaryButton} from '@sbb-esta/lyne-angular/button/secondary-button';
import {
  AbstractControl,
  FormControl,
  FormGroup,
  ReactiveFormsModule,
  ValidationErrors,
  Validators
} from '@angular/forms';
import {NoticeTemplate} from '../../ru-admin-api';
import {SBB_OVERLAY_DATA} from '@sbb-esta/lyne-angular/core/overlay';
import {SbbTransparentButton} from '@sbb-esta/lyne-angular/button/transparent-button';
import {SbbTitleModule} from '@sbb-esta/lyne-angular/title';
import {SbbDialogModule} from '@sbb-esta/lyne-angular/dialog';
import {SbbFormFieldModule} from '@sbb-esta/lyne-angular/form-field';
import {SbbTabsModule} from '@sbb-esta/lyne-angular/tabs';

export type NoticeTemplateDialogEditResult = NoticeTemplate | 'delete';

function oneLanguageRequired(control: AbstractControl): ValidationErrors | null {
  const de = control.get('de.title')?.value?.trim();
  const fr = control.get('fr.title')?.value?.trim();
  const it = control.get('it.title')?.value?.trim();
  return de || fr || it ? null : {oneLanguageRequired: true};
}

function titleRequired(control: AbstractControl): ValidationErrors | null {
  const titleControl = control.get('title');
  const title = titleControl?.value?.trim();
  const text = control.get('text')?.value?.trim();
  const error = text && !title ? {titleRequired: true} : null;
  titleControl?.setErrors(error);
  return error;
}

@Component({
  selector: 'app-notice-template-dialog',
  imports: [
    SbbDialogModule,
    SbbButton,
    SbbSecondaryButton,
    SbbFormFieldModule,
    ReactiveFormsModule,
    SbbTransparentButton,
    SbbTitleModule,
    SbbTabsModule,
  ],
  templateUrl: './notice-template-dialog.html',
  styleUrl: './notice-template-dialog.css',
})
export class NoticeTemplateDialog {

  protected readonly title: string;
  protected readonly isEdit: boolean;

  protected noticeTemplateForm = new FormGroup({
    category: new FormControl('', {nonNullable: true, validators: [Validators.required]}),
    de: new FormGroup({
      title: new FormControl('', {nonNullable: true}),
      text: new FormControl('', {nonNullable: true}),
    }, {validators: titleRequired}),
    fr: new FormGroup({
      title: new FormControl('', {nonNullable: true}),
      text: new FormControl('', {nonNullable: true}),
    }, {validators: titleRequired}),
    it: new FormGroup({
      title: new FormControl('', {nonNullable: true}),
      text: new FormControl('', {nonNullable: true}),
    }, {validators: titleRequired}),
  }, {validators: oneLanguageRequired});

  private readonly dialogData = inject<NoticeTemplate>(SBB_OVERLAY_DATA, {optional: true}) ?? null;

  constructor() {
    this.isEdit = this.dialogData?.id != null;
    this.title = this.isEdit
      ? $localize`:@@notice_templates_dialog_title_edit:Titel und Text bearbeiten`
      : $localize`:@@notice_templates_dialog_title_create:Titel und Text erfassen`;

    if (this.isEdit && this.dialogData) {
      this.noticeTemplateForm.patchValue({
        category: this.dialogData.category,
        de: {
          title: this.dialogData.de?.title ?? '',
          text: this.dialogData.de?.text ?? '',
        },
        fr: {
          title: this.dialogData.fr?.title ?? '',
          text: this.dialogData.fr?.text ?? '',
        },
        it: {
          title: this.dialogData.it?.title ?? '',
          text: this.dialogData.it?.text ?? '',
        },
      });
    }
  }

  get formValue(): NoticeTemplate {
    return this.noticeTemplateForm.value as NoticeTemplate;
  }

  isLanguageEmpty(language: 'de' | 'fr' | 'it'): boolean {
    const titleValue = this.noticeTemplateForm.get(language)?.get('title')?.value ?? '';
    return !titleValue.trim();
  }
}
