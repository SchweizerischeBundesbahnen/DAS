import { Component, inject } from '@angular/core';
import { FormControl, FormGroup, NonNullableFormBuilder, ReactiveFormsModule, Validators } from '@angular/forms';
import { SBB_OVERLAY_DATA } from '@sbb-esta/lyne-angular/core/overlay';
import { LanguageCode, LanguageProvider } from '../../../shared/language-provider';
import { SbbDialogModule } from '@sbb-esta/lyne-angular/dialog';
import { SbbFormField, SbbError } from '@sbb-esta/lyne-angular/form-field';
import { SbbTabsModule } from '@sbb-esta/lyne-angular/tabs';
import { CompaniesInputComponent } from '../../../shared/companies-input/companies-input.component';
import { UpperCasePipe } from '@angular/common';
import { languageRequired, oneLanguageRequired, url } from '../../../shared/form-validators.util';
import { SbbActionGroup } from '@sbb-esta/lyne-angular/action-group';
import { ExternalLink } from '../../ru-admin-api';
import { SbbButtonModule } from '@sbb-esta/lyne-angular/button';

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
    SbbDialogModule,
    SbbFormField,
    SbbTabsModule,
    CompaniesInputComponent,
    UpperCasePipe,
    ReactiveFormsModule,
    SbbButtonModule,
    SbbError,
    SbbActionGroup,
  ],
  templateUrl: './external-link-dialog.html',
  styleUrl: './external-link-dialog.css',
})
export class ExternalLinkDialog {
  protected readonly languageProvider = inject(LanguageProvider);
  private readonly formBuilder = inject(NonNullableFormBuilder);

  protected readonly dialogTitle: string;

  protected readonly isEdit: boolean;

  private readonly dialogData = inject<ExternalLink>(SBB_OVERLAY_DATA, { optional: true });

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
    this.isEdit = this.dialogData?.id !== undefined;
    this.dialogTitle = this.isEdit
      ? $localize`:@@external_links_dialog_title_edit:Externen Absprung bearbeiten`
      : $localize`:@@external_links_dialog_title_create:Externen Absprung erfassen`;

    if (this.isEdit && this.dialogData) {
      this.externalLinkForm.patchValue(this.dialogData);
    }
  }

  protected isLanguageEmpty(language: LanguageCode): boolean {
    const controls = Object.values((this.externalLinkForm.get(language) as FormGroup)?.controls);
    return controls.every((control) => !control.value?.trim());
  }
}
