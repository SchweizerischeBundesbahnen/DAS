import { Component, inject } from '@angular/core';
import { FormControl, FormGroup, ReactiveFormsModule, Validators } from '@angular/forms';
import { SBB_OVERLAY_DATA } from '@sbb-esta/lyne-angular/core/overlay';
import { SbbFormFieldModule } from '@sbb-esta/lyne-angular/form-field';
import { SbbTitleModule } from '@sbb-esta/lyne-angular/title';
import { RuIndicationTemplate } from '~ru-admin/ru-admin-api';
import {
  contentFormValue,
  createContentFormGroup,
  RuIndicationContentForm,
} from '~ru-admin/ru-indication-content-form/ru-indication-content-form.component';
import { BaseDialog } from '~shared/base-dialog/base-dialog.component';

export type RuIndicationTemplateDialogEditResult = RuIndicationTemplate | 'delete';

@Component({
  selector: 'app-ru-indication-template-dialog',
  imports: [
    ReactiveFormsModule,
    SbbFormFieldModule,
    SbbTitleModule,
    BaseDialog,
    RuIndicationContentForm,
  ],
  templateUrl: './ru-indication-template-dialog.html',
  styleUrl: './ru-indication-template-dialog.css',
})
export class RuIndicationTemplateDialog {
  protected readonly title: string;
  protected ruIndicationTemplateForm = new FormGroup({
    category: new FormControl('', { nonNullable: true, validators: [Validators.required] }),
    content: createContentFormGroup({ textRequired: false }),
  });
  protected readonly dialogData =
    inject<RuIndicationTemplate>(SBB_OVERLAY_DATA, { optional: true }) ?? undefined;

  constructor() {
    const isEdit = this.dialogData?.id != null;
    this.title = isEdit
      ? $localize`:@@ru_indication_templates_dialog_title_edit:Titel und Text bearbeiten`
      : $localize`:@@ru_indication_templates_dialog_title_create:Titel und Text erfassen`;

    if (isEdit && this.dialogData) {
      this.ruIndicationTemplateForm.patchValue({
        category: this.dialogData.category,
        content: {
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
        },
      });
    }
  }

  get formValue(): RuIndicationTemplate {
    return {
      category: this.ruIndicationTemplateForm.value.category ?? '',
      ...contentFormValue(this.ruIndicationTemplateForm.controls.content),
    };
  }
}
