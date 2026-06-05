import { Component, inject } from '@angular/core';
import { FormControl, FormGroup, ReactiveFormsModule, Validators } from '@angular/forms';
import { RuIndicationTemplate } from '../../ru-admin-api';
import { SBB_OVERLAY_DATA } from '@sbb-esta/lyne-angular/core/overlay';
import { SbbTitleModule } from '@sbb-esta/lyne-angular/title';
import { SbbDialogModule } from '@sbb-esta/lyne-angular/dialog';
import { SbbFormFieldModule } from '@sbb-esta/lyne-angular/form-field';
import { SbbTabsModule } from '@sbb-esta/lyne-angular/tabs';
import { SbbButtonModule } from '@sbb-esta/lyne-angular/button';
import { SbbTooltipModule } from '@sbb-esta/lyne-angular/tooltip';
import {
  contentFormValue,
  createContentFormGroup,
  RuIndicationContentForm
} from '../../ru-indication-content-form/ru-indication-content-form.component';
import { BaseDialog } from '../../../shared/base-dialog/base-dialog.component';

export type RuIndicationTemplateDialogEditResult = RuIndicationTemplate | 'delete';

@Component({
  selector: 'app-ru-indication-template-dialog',
  imports: [
    ReactiveFormsModule,
    SbbDialogModule,
    SbbButtonModule,
    SbbTooltipModule,
    SbbFormFieldModule,
    SbbTitleModule,
    SbbTabsModule,
    RuIndicationContentForm,
    BaseDialog,
  ],
  templateUrl: './ru-indication-template-dialog.html',
  styleUrl: './ru-indication-template-dialog.css',
})
export class RuIndicationTemplateDialog {
  protected readonly title: string;
  protected readonly isEdit: boolean;
  protected ruIndicationTemplateForm = new FormGroup({
    category: new FormControl('', {nonNullable: true, validators: [Validators.required]}),
    content: createContentFormGroup(),
  });
  protected readonly dialogData = inject<RuIndicationTemplate>(SBB_OVERLAY_DATA, {optional: true}) ?? undefined;

  constructor() {
    this.isEdit = this.dialogData?.id != null;
    this.title = this.isEdit
      ? $localize`:@@ru_indication_templates_dialog_title_edit:Titel und Text bearbeiten`
      : $localize`:@@ru_indication_templates_dialog_title_create:Titel und Text erfassen`;

    if (this.isEdit && this.dialogData) {
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
          }
        }
      });
    }
  }

  get formValue(): RuIndicationTemplate {
    return {
      category: this.ruIndicationTemplateForm.value.category ?? '',
      ...contentFormValue(this.ruIndicationTemplateForm.controls.content)
    };
  }
}
