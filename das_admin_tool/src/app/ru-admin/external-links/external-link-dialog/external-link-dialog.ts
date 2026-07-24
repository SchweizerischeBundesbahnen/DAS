import { UpperCasePipe } from '@angular/common';
import { Component, inject } from '@angular/core';
import {
  FormControl,
  FormGroup,
  NonNullableFormBuilder,
  ReactiveFormsModule,
  Validators,
} from '@angular/forms';
import { SBB_OVERLAY_DATA } from '@sbb-esta/lyne-angular/core';
import { SbbFormFieldModule } from '@sbb-esta/lyne-angular/form-field';
import { SbbTabsModule } from '@sbb-esta/lyne-angular/tabs';
import { ExternalLink } from '~ru-admin/ru-admin-api';
import { BaseDialog } from '~shared/base-dialog/base-dialog.component';
import { CompaniesInputComponent } from '~shared/companies-input/companies-input.component';
import { languageRequired, oneLanguageRequired, url } from '~shared/form-validators.util';
import { LanguageCode, LanguageProvider } from '~shared/language-provider';

interface FormGroupExternalLinkContent {
  title: FormControl<string>;
  link: FormControl<string>;
}

export interface FormGroupExternalLink {
  companies: FormControl<string[]>;
  de: FormGroup<FormGroupExternalLinkContent>;
  fr: FormGroup<FormGroupExternalLinkContent>;
  it: FormGroup<FormGroupExternalLinkContent>;
}

export type ExternalLinkDialogEditResult = ExternalLink | 'delete';

@Component({
  selector: 'app-external-link-dialog',
  imports: [
    ReactiveFormsModule,
    UpperCasePipe,
    SbbFormFieldModule,
    SbbTabsModule,
    BaseDialog,
    CompaniesInputComponent,
  ],
  templateUrl: './external-link-dialog.html',
  styleUrl: './external-link-dialog.css',
})
export class ExternalLinkDialog {
  protected readonly languageProvider = inject(LanguageProvider);
  protected readonly dialogData =
    inject<ExternalLink>(SBB_OVERLAY_DATA, { optional: true }) ?? undefined;
  private readonly formBuilder = inject(NonNullableFormBuilder);

  protected readonly dialogTitle: string;
  protected externalLinkForm = this.formBuilder.group<FormGroupExternalLink>(
    {
      companies: this.formBuilder.control<string[]>([], Validators.required),
      de: this.formBuilder.group(
        { title: '', link: ['', { validators: url }] },
        { validators: languageRequired },
      ),
      fr: this.formBuilder.group(
        { title: '', link: ['', { validators: url }] },
        { validators: languageRequired },
      ),
      it: this.formBuilder.group(
        { title: '', link: ['', { validators: url }] },
        { validators: languageRequired },
      ),
    },
    { validators: oneLanguageRequired },
  );

  constructor() {
    const isEdit = this.dialogData?.id !== undefined;
    this.dialogTitle = isEdit
      ? $localize`:@@external_links_dialog_title_edit:Externen Absprung bearbeiten`
      : $localize`:@@external_links_dialog_title_create:Externen Absprung erfassen`;

    if (isEdit && this.dialogData) {
      this.externalLinkForm.patchValue(this.dialogData);
    }
  }

  protected isLanguageEmpty(language: LanguageCode): boolean {
    const controls = Object.values(
      (this.externalLinkForm.get(language) as FormGroup).controls as Record<
        string,
        FormControl<string>
      >,
    );
    return controls.every((control) => !control.value.trim());
  }
}
