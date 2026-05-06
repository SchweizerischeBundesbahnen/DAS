import {Component, effect, inject, viewChild} from '@angular/core';
import {
  SbbSort,
  SbbTableDataSource,
  SbbTableFilter,
  SbbTableModule
} from '@sbb-esta/lyne-angular/table';
import {SbbSecondaryButton} from '@sbb-esta/lyne-angular/button/secondary-button';
import {NoticeTemplate} from '../../ru-admin-api';
import {takeUntilDestroyed} from '@angular/core/rxjs-interop';
import {SbbCompactPaginator} from '@sbb-esta/lyne-angular/paginator/compact-paginator';
import {NoticeTemplateService} from '../notice-template.service';
import {SbbMiniButton} from '@sbb-esta/lyne-angular/button/mini-button';
import {SelectionModel} from '@angular/cdk/collections';
import {SbbCheckboxModule} from '@sbb-esta/lyne-angular/checkbox';
import {SbbFormFieldModule} from '@sbb-esta/lyne-angular/form-field';
import {SbbIconModule} from '@sbb-esta/lyne-angular/icon';
import {SbbSelectModule} from '@sbb-esta/lyne-angular/select';
import {FormControl, FormGroup, ReactiveFormsModule} from '@angular/forms';
import {SbbTransparentButton} from '@sbb-esta/lyne-angular/button/transparent-button';
import {LanguageCode, LanguageProvider} from '../../../shared/language-provider';

interface NoticeTemplateFilter extends SbbTableFilter {
  search: string;
  language: LanguageCode;
}

@Component({
  selector: 'app-notice-templates-table',
  imports: [
    SbbTableModule,
    SbbSecondaryButton,
    SbbTransparentButton,
    SbbCompactPaginator,
    SbbMiniButton,
    SbbCheckboxModule,
    SbbFormFieldModule,
    SbbIconModule,
    SbbSelectModule,
    ReactiveFormsModule
  ],
  templateUrl: './notice-templates-table.html',
  styleUrl: './notice-templates-table.css',
})
export class NoticeTemplatesTable {
  protected readonly languageProvider = inject(LanguageProvider);
  protected dataSource = new SbbTableDataSource<NoticeTemplate, NoticeTemplateFilter>();
  protected columns = ['select', 'category', 'title', 'text', 'lastModifiedBy', 'action'];
  protected selection = new SelectionModel<NoticeTemplate>(true, []);
  protected form = new FormGroup({
    search: new FormControl('', {nonNullable: true}),
    language: new FormControl(this.languageProvider.currentLanguage?.path, {nonNullable: true})
  });
  protected readonly PAGE_SIZE = 20;
  private readonly noticeTemplateService = inject(NoticeTemplateService);
  private readonly paginator = viewChild.required<SbbCompactPaginator>(SbbCompactPaginator);
  private readonly sort = viewChild.required<SbbSort>(SbbSort);

  constructor() {
    effect(() => {
      if (this.noticeTemplateService.noticeTemplatesResource.hasValue()) {
        this.dataSource.data = this.noticeTemplateService.noticeTemplatesResource.value().data;
      }
      this.dataSource.paginator = this.paginator();
      this.dataSource.sort = this.sort();
    });
    this.dataSource.filterPredicate = (data: NoticeTemplate, filter: NoticeTemplateFilter) => this.searchFilter(filter, data);
    this.dataSource.sortingDataAccessor = (data, col) => this.getValue(data, col) ?? '';
    this.form.valueChanges
      .pipe(takeUntilDestroyed())
      .subscribe((form) => {
        this.dataSource.filter = form as NoticeTemplateFilter;
      });
  }

  protected getValue(row: NoticeTemplate, column: string) {
    const language = this.form.value.language;
    if (['title', 'text'].includes(column) && language) {
      return row[language]?.[column];
    }
    return row[column] as string;
  }

  protected async edit(noticeTemplate: NoticeTemplate) {
    await this.noticeTemplateService.edit(noticeTemplate);
  }

  protected async add() {
    await this.noticeTemplateService.add();
  }

  protected isAllSelected() {
    const numSelected = this.selection.selected.length;
    const numRows = this.dataSource.filteredData.length;
    return numSelected === numRows;
  }

  protected parentToggle() {
    if (this.isAllSelected()) {
      this.selection.clear();
    } else {
      this.dataSource.filteredData.forEach((row) => this.selection.select(row));
    }
  }

  protected async deleteSelected() {
    await this.noticeTemplateService.deleteAll(this.selection.selected)
  }

  private searchFilter(filter: NoticeTemplateFilter, data: NoticeTemplate) {
    const search = filter.search.toLowerCase();
    return (
      this.getValue(data, 'title')?.toLowerCase().includes(search) ||
      this.getValue(data, 'text')?.toLowerCase().includes(search) ||
      data.category.toLowerCase().includes(search) ||
      data.lastModifiedBy?.toLowerCase().includes(search)
    ) ?? true;
  }
}
