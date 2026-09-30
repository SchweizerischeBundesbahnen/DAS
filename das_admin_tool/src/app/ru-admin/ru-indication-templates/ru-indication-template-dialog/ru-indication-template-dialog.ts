import { Component, inject, signal } from '@angular/core';
import { form, FormField, required } from '@angular/forms/signals';
import { SBB_OVERLAY_DATA } from '@sbb-esta/lyne-angular/core';
import { SbbFormFieldModule } from '@sbb-esta/lyne-angular/form-field';
import { SbbTitleModule } from '@sbb-esta/lyne-angular/title';
import { RuIndicationTemplate } from '~ru-admin/ru-admin-api';
import {
  contentFormValue,
  createContentFormTree,
  RuIndicationContentData,
  RuIndicationContentForm,
} from '~ru-admin/ru-indication-content-form/ru-indication-content-form.component';
import { BaseDialog } from '~shared/base-dialog/base-dialog.component';
import { oneLanguageRequired, titleRequired } from '~shared/form-validators.util';

export interface RuIndicationTemplateData {
  category: string;
  content: RuIndicationContentData;
}

export type RuIndicationTemplateDialogEditResult = RuIndicationTemplate | 'delete';

@Component({
  selector: 'app-ru-indication-template-dialog',
  imports: [FormField, SbbFormFieldModule, SbbTitleModule, BaseDialog, RuIndicationContentForm],
  templateUrl: './ru-indication-template-dialog.html',
  styleUrl: './ru-indication-template-dialog.css',
})
export class RuIndicationTemplateDialog {
  protected readonly dialogData =
    inject<RuIndicationTemplate>(SBB_OVERLAY_DATA, { optional: true }) ?? undefined;

  protected readonly dialogTitle: string;

  protected readonly ruIndicationTemplateModel = signal<RuIndicationTemplateData>({
    category: '',
    content: createContentFormTree(false),
  });
  protected readonly ruIndicationTemplateForm = form(
    this.ruIndicationTemplateModel,
    (ruIndication) => {
      required(ruIndication.category, {
        message: $localize`:@@form_field_error_required:Feld darf nicht leer sein`,
      });

      oneLanguageRequired(ruIndication.content, {
        message: $localize`:@@ru_indications_form_one_language_error:Mindestens eine Sprache muss erfasst werden`,
      });

      titleRequired(ruIndication.content.de, {
        message: $localize`:@@form_field_error_required:Feld darf nicht leer sein`,
      });
      titleRequired(ruIndication.content.fr, {
        message: $localize`:@@form_field_error_required:Feld darf nicht leer sein`,
      });
      titleRequired(ruIndication.content.it, {
        message: $localize`:@@form_field_error_required:Feld darf nicht leer sein`,
      });
    },
  );

  constructor() {
    const isEdit = this.dialogData?.id !== undefined;
    this.dialogTitle = isEdit
      ? $localize`:@@ru_indication_templates_dialog_title_edit:Titel und Text bearbeiten`
      : $localize`:@@ru_indication_templates_dialog_title_create:Titel und Text erfassen`;

    if (isEdit && this.dialogData) {
      this.ruIndicationTemplateModel.update((initial) => ({
        category: this.dialogData!.category,
        content: {
          de: {
            title: this.dialogData!.de?.title ?? initial.content.de.title,
            text: this.dialogData!.de?.text ?? initial.content.de.text,
          },
          fr: {
            title: this.dialogData!.fr?.title ?? initial.content.fr.title,
            text: this.dialogData!.fr?.text ?? initial.content.fr.text,
          },
          it: {
            title: this.dialogData!.it?.title ?? initial.content.it.title,
            text: this.dialogData!.it?.text ?? initial.content.it.text,
          },
        },
      }));
    }
  }

  get formValue(): RuIndicationTemplate {
    const formValue = this.ruIndicationTemplateModel();
    return {
      category: formValue.category,
      ...contentFormValue(formValue.content, false),
    };
  }
}
