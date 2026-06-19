import { Component, inject } from '@angular/core';
import {
  FormControl,
  FormGroup,
  NonNullableFormBuilder,
  ReactiveFormsModule,
  Validators,
} from '@angular/forms';
import { SBB_OVERLAY_DATA } from '@sbb-esta/lyne-angular/core/overlay';
import { LanguageCode, LanguageProvider } from '../../../shared/language-provider';
import { SbbFormFieldModule } from '@sbb-esta/lyne-angular/form-field';
import { CompaniesInputComponent } from '../../../shared/companies-input/companies-input.component';
import { UpperCasePipe } from '@angular/common';
import { languageRequired, oneLanguageRequired, url } from '../../../shared/form-validators.util';
import { ExternalLink } from '../../ru-admin-api';
import { BaseDialog } from '../../../shared/base-dialog/base-dialog.component';
import { SbbTabsModule } from '@sbb-esta/lyne-angular/tabs';

interface FormGroupExternalLinkContent {
  title: FormControl<string>;
  link: FormControl<string>;

  [key: string]: FormControl<string>;
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
  protected readonly dialogTitle: string;
  protected readonly dialogData =
    inject<ExternalLink>(SBB_OVERLAY_DATA, { optional: true }) ?? undefined;
  private readonly formBuilder = inject(NonNullableFormBuilder);
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
      (this.externalLinkForm.get(language) as FormGroup<FormGroupExternalLinkContent>).controls,
    );
    return controls.every((control) => !control.value.trim());
  }
}
