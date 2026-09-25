import { UpperCasePipe } from '@angular/common';
import { Component, inject, signal } from '@angular/core';
import { form, FormField } from '@angular/forms/signals';
import { SBB_OVERLAY_DATA } from '@sbb-esta/lyne-angular/core';
import { SbbFormFieldModule } from '@sbb-esta/lyne-angular/form-field';
import { SbbTabsModule } from '@sbb-esta/lyne-angular/tabs';
import { ExternalLink } from '~ru-admin/ru-admin-api';
import { BaseDialog } from '~shared/base-dialog/base-dialog.component';
import { CompaniesInputComponent } from '~shared/companies-input/companies-input.component';
import {
  arrayRequired,
  languageRequired,
  oneLanguageRequired,
  url,
} from '~shared/form-validators.util';
import { LanguageCode, LanguageProvider } from '~shared/language-provider';

interface ExternalLinkContentData {
  title: string;
  link: string;
}

export interface ExternalLinkData {
  companies: string[];
  de: ExternalLinkContentData;
  fr: ExternalLinkContentData;
  it: ExternalLinkContentData;
}

export type ExternalLinkDialogEditResult = ExternalLink | 'delete';

@Component({
  selector: 'app-external-link-dialog',
  imports: [
    FormField,
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

  protected readonly dialogTitle: string;

  protected readonly externalLinkModel = signal<ExternalLinkData>({
    companies: [],
    de: { title: '', link: '' },
    fr: { title: '', link: '' },
    it: { title: '', link: '' },
  });
  protected readonly externalLinkForm = form(this.externalLinkModel, (externalLink) => {
    oneLanguageRequired(externalLink, {
      message: $localize`:@@external_links_form_error_one_language_required:Eine Sprache muss ausgefüllt sein`,
    });

    arrayRequired(externalLink.companies, {
      message: $localize`:@@form_field_error_required:Feld darf nicht leer sein`,
    });

    languageRequired(externalLink.de, {
      message: $localize`:@@form_field_error_required:Feld darf nicht leer sein`,
    });
    languageRequired(externalLink.fr, {
      message: $localize`:@@form_field_error_required:Feld darf nicht leer sein`,
    });
    languageRequired(externalLink.it, {
      message: $localize`:@@form_field_error_required:Feld darf nicht leer sein`,
    });

    url(externalLink.de.link, {
      message: $localize`:@@external_links_form_field_error_url:Webadresse muss eine gültige URL sein`,
    });
    url(externalLink.fr.link, {
      message: $localize`:@@external_links_form_field_error_url:Webadresse muss eine gültige URL sein`,
    });
    url(externalLink.it.link, {
      message: $localize`:@@external_links_form_field_error_url:Webadresse muss eine gültige URL sein`,
    });
  });

  constructor() {
    const isEdit = this.dialogData?.id !== undefined;
    this.dialogTitle = isEdit
      ? $localize`:@@external_links_dialog_title_edit:Externen Absprung bearbeiten`
      : $localize`:@@external_links_dialog_title_create:Externen Absprung erfassen`;

    if (isEdit && this.dialogData) {
      this.externalLinkModel.update((initial) => ({
        companies: this.dialogData!.companies,
        de: {
          title: this.dialogData!.de?.title ?? initial.de.title,
          link: this.dialogData!.de?.link ?? initial.de.link,
        },
        fr: {
          title: this.dialogData!.fr?.title ?? initial.fr.title,
          link: this.dialogData!.fr?.link ?? initial.fr.link,
        },
        it: {
          title: this.dialogData!.it?.title ?? initial.it.title,
          link: this.dialogData!.it?.link ?? initial.it.link,
        },
      }));
    }
  }

  protected isLanguageEmpty(language: LanguageCode): boolean {
    const languageContent = this.externalLinkModel()[language];
    return [languageContent.title, languageContent.link].every((field) => !field.trim());
  }
}
