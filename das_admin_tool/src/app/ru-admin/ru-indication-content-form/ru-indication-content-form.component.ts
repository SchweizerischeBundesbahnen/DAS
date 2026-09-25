import { UpperCasePipe } from '@angular/common';
import { Component, inject, input } from '@angular/core';
import { FieldTree, FormField } from '@angular/forms/signals';
import { SbbMiniButton } from '@sbb-esta/lyne-angular/button';
import { SbbError, SbbFormField } from '@sbb-esta/lyne-angular/form-field';
import { SbbTab, SbbTabGroup, SbbTabLabel } from '@sbb-esta/lyne-angular/tabs';
import { SbbTooltipDirective } from '@sbb-esta/lyne-angular/tooltip';
import { RuIndicationContent, RuIndicationLanguageContent } from '~ru-admin/ru-admin-api';
import { LanguageCode, LanguageProvider } from '~shared/language-provider';

export interface RuIndicationLanguageContentData {
  title: string;
  text: string;
}

export interface RuIndicationContentData {
  de: RuIndicationLanguageContentData;
  fr: RuIndicationLanguageContentData;
  it: RuIndicationLanguageContentData;
}

interface Category {
  category: string;
}

export type RuIndicationContentWithCategoryData = RuIndicationContentData & Category;

export function createContentFormTree(withCategory?: true): RuIndicationContentWithCategoryData;
export function createContentFormTree(withCategory?: false): RuIndicationContentData;
export function createContentFormTree(
  withCategory = true,
): RuIndicationContentWithCategoryData | RuIndicationContentData {
  const content: RuIndicationContentData & Partial<Category> = {
    de: { title: '', text: '' },
    fr: { title: '', text: '' },
    it: { title: '', text: '' },
  };
  if (withCategory) {
    content.category = '';
  }
  return content;
}

export function contentFormValue(
  content: RuIndicationContentWithCategoryData,
  withCategory?: true,
): RuIndicationContentWithCategoryData;
export function contentFormValue(
  content: RuIndicationContentData,
  withCategory?: false,
): RuIndicationContentData;
export function contentFormValue(
  content: RuIndicationContentWithCategoryData | RuIndicationContentData,
  withCategory = true,
): RuIndicationContent {
  const mapLanguage = (language: LanguageCode): RuIndicationLanguageContent | undefined => {
    const title = content[language].title.trim();
    const text = content[language].text.trim();
    if (!title && !text) {
      return undefined;
    }
    return { title, text: text || undefined };
  };

  const mappedContent: RuIndicationContent = {
    de: mapLanguage('de'),
    fr: mapLanguage('fr'),
    it: mapLanguage('it'),
  };
  if (withCategory) {
    mappedContent.category = (content as RuIndicationContentWithCategoryData).category;
  }
  return mappedContent;
}

@Component({
  selector: 'app-ru-indication-content-form',
  imports: [
    FormField,
    SbbError,
    SbbFormField,
    SbbMiniButton,
    SbbTab,
    SbbTabGroup,
    SbbTabLabel,
    SbbTooltipDirective,
    UpperCasePipe,
  ],
  templateUrl: './ru-indication-content-form.component.html',
  styleUrl: './ru-indication-content-form.component.css',
})
export class RuIndicationContentForm {
  protected readonly languageProvider = inject(LanguageProvider);

  readonly form =
    input.required<FieldTree<RuIndicationContentWithCategoryData | RuIndicationContentData>>();

  protected isLanguageEmpty(language: LanguageCode): boolean {
    return !this.form()[language].title().value().trim();
  }

  protected insertLink(language: LanguageCode, textarea: HTMLTextAreaElement): void {
    const textField = this.form()[language].text();
    if (!textField) {
      return;
    }

    const markdownLink = '[](url)';
    const currentValue = textField.value() ?? '';
    const selectionStart = textarea.selectionStart ?? currentValue.length;
    const selectionEnd = textarea.selectionEnd ?? currentValue.length;

    const nextValue =
      currentValue.slice(0, selectionStart) + markdownLink + currentValue.slice(selectionEnd);

    textField.value.set(nextValue);
    textField.markAsTouched();
    textField.markAsDirty();

    // keep focus and preselect link
    globalThis.queueMicrotask(() => {
      const cursorPosition = selectionStart + 1;
      textarea.focus();
      textarea.setSelectionRange(cursorPosition, cursorPosition);
    });
  }
}
