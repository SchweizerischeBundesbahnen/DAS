import { Component, inject } from '@angular/core';
import { FormControl, FormGroup, ReactiveFormsModule, Validators } from '@angular/forms';
import { RuIndicationTemplate } from '../../ru-admin-api';
import { SBB_OVERLAY_DATA } from '@sbb-esta/lyne-angular/core/overlay';
import { SbbTitleModule } from '@sbb-esta/lyne-angular/title';
import { SbbFormFieldModule } from '@sbb-esta/lyne-angular/form-field';
import {
  contentFormValue,
  createContentFormGroup,
  RuIndicationContentForm
} from '../../ru-indication-content-form/ru-indication-content-form.component';
import { BaseDialog } from '../../../shared/base-dialog/base-dialog.component';
import { CompaniesInputComponent } from '../../../shared/companies-input/companies-input.component';

export type RuIndicationTemplateDialogEditResult = RuIndicationTemplate | 'delete';

@Component({
  selector: 'app-ru-indication-template-dialog',
  imports: [
    ReactiveFormsModule,
    SbbFormFieldModule,
    SbbTitleModule,
    BaseDialog,
    RuIndicationContentForm,
    CompaniesInputComponent,
  ],
  templateUrl: './ru-indication-template-dialog.html',
  styleUrl: './ru-indication-template-dialog.css',
})
export class RuIndicationTemplateDialog {
  protected readonly title: string;
  protected ruIndicationTemplateForm = new FormGroup({
    category: new FormControl('', {nonNullable: true, validators: [Validators.required]}),
    content: createContentFormGroup(),
    companies: new FormControl<string[]>([], {
      nonNullable: true,
      validators: [Validators.required]
    }),
  });
  protected readonly dialogData = inject<RuIndicationTemplate>(SBB_OVERLAY_DATA, {optional: true}) ?? undefined;

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
          }
        },
        companies: this.dialogData.companies
      });
    }
  }

  get formValue(): RuIndicationTemplate {
    const companies = this.ruIndicationTemplateForm.controls.companies.value
      .map((company) => company.trim())
      .filter((company) => company.length > 0);
    return {
      category: this.ruIndicationTemplateForm.value.category ?? '',
      ...contentFormValue(this.ruIndicationTemplateForm.controls.content),
      companies
    };
  }
}
