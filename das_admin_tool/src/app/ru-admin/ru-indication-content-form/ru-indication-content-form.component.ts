import { Component, input } from '@angular/core';
import {
  AbstractControl,
  FormControl,
  FormGroup,
  ReactiveFormsModule,
  ValidationErrors
} from "@angular/forms";
import { SbbError, SbbFormField } from "@sbb-esta/lyne-angular/form-field";
import { SbbMiniButton } from "@sbb-esta/lyne-angular/button";
import { SbbTab, SbbTabGroup, SbbTabLabel } from "@sbb-esta/lyne-angular/tabs";
import { SbbTooltipDirective } from "@sbb-esta/lyne-angular/tooltip";
import { LanguageCode } from '../../shared/language-provider';
import { RuIndication, RuIndicationContent, RuIndicationLanguageContent } from '../ru-admin-api';

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
  }, {validators: titleRequired});
}

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
  selector: 'app-ru-indication-content-form',
  imports: [
    ReactiveFormsModule,
    SbbError,
    SbbFormField,
    SbbMiniButton,
    SbbTab,
    SbbTabGroup,
    SbbTabLabel,
    SbbTooltipDirective
  ],
  templateUrl: './ru-indication-content-form.component.html',
  styleUrl: './ru-indication-content-form.component.css',
})
export class RuIndicationContentForm {
  form = input.required<FormGroup>();

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
    queueMicrotask(() => {
      const cursorPosition = selectionStart + 1;
      textarea.focus();
      textarea.setSelectionRange(cursorPosition, cursorPosition);
    });
  }
}
