import { Component, inject, input } from '@angular/core';
import { FormControl, FormGroup, ReactiveFormsModule } from "@angular/forms";
import { SbbError, SbbFormField } from "@sbb-esta/lyne-angular/form-field";
import { SbbMiniButton } from "@sbb-esta/lyne-angular/button";
import { SbbTab, SbbTabGroup, SbbTabLabel } from "@sbb-esta/lyne-angular/tabs";
import { SbbTooltipDirective } from "@sbb-esta/lyne-angular/tooltip";
import { LanguageCode, LanguageProvider } from '../../shared/language-provider';
import { RuIndication, RuIndicationContent, RuIndicationLanguageContent } from '../ru-admin-api';
import { UpperCasePipe } from '@angular/common';
import { oneLanguageRequired, titleRequired } from '../../shared/form-validators.util';

interface LanguageContentForm {
  title: FormControl<string>;
  text: FormControl<string>;
}

export function createContentFormGroup() {
  return new FormGroup({
    de: createLanguageGroup(),
    fr: createLanguageGroup(),
    it: createLanguageGroup(),
  }, {validators: oneLanguageRequired})
}

function createLanguageGroup(): FormGroup<LanguageContentForm> {
  return new FormGroup({
    title: new FormControl('', {nonNullable: true}),
    text: new FormControl('', {nonNullable: true}),
  }, {validators: titleRequired('text')});
}

@Component({
  selector: 'app-ru-indication-content-form',
  imports: [
    ReactiveFormsModule,
    SbbError,
    SbbFormField,
    SbbMiniButton,
    SbbTab,
    SbbTabGroup,
    SbbTabLabel,
    SbbTooltipDirective,
    UpperCasePipe
  ],
  templateUrl: './ru-indication-content-form.component.html',
  styleUrl: './ru-indication-content-form.component.css',
})
export class RuIndicationContentForm {
  form = input.required<FormGroup>();
  protected readonly languageProvider = inject(LanguageProvider);

  public get formValue(): Partial<RuIndicationContent> {
    const mapLanguage = (language: keyof RuIndication['content']): RuIndicationLanguageContent | undefined => {
      const title = this.form().get(language)?.get('title')?.value?.trim() ?? '';
      const text = this.form().get(language)?.get('text')?.value?.trim() ?? '';
      if (!title && !text) {
        return undefined;
      }
      return {title, text: text || undefined};
    };

    return {
      de: mapLanguage('de'),
      fr: mapLanguage('fr'),
      it: mapLanguage('it'),
    };
  }

  protected isLanguageEmpty(language: LanguageCode): boolean {
    const titleValue = this.form().get(language)?.get('title')?.value ?? '';
    return !titleValue.trim();
  }

  protected insertLink(language: LanguageCode, textarea: HTMLTextAreaElement): void {
    const textControl = this.form().get(`${language}.text`) as FormControl<string> | null;
    if (!textControl) {
      return;
    }

    const markdownLink = '[](url)';
    const currentValue = textControl.value ?? '';
    const selectionStart = textarea.selectionStart ?? currentValue.length;
    const selectionEnd = textarea.selectionEnd ?? currentValue.length;

    const nextValue =
      currentValue.slice(0, selectionStart) + markdownLink + currentValue.slice(selectionEnd);

    textControl.setValue(nextValue);
    textControl.markAsDirty();
    textControl.markAsTouched();

    // keep focus and preselect link
    globalThis.queueMicrotask(() => {
      const cursorPosition = selectionStart + 1;
      textarea.focus();
      textarea.setSelectionRange(cursorPosition, cursorPosition);
    });
  }
}
