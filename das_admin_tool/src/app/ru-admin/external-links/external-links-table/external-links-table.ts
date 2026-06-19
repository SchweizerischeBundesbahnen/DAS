import { Component, effect, inject, viewChild } from '@angular/core';
import {
  SbbSort,
  SbbTableDataSource,
  SbbTableFilter,
  SbbTableModule,
} from '@sbb-esta/lyne-angular/table';
import { SbbCheckbox } from '@sbb-esta/lyne-angular/checkbox';
import { ExternalLinksService } from '../external-links.service';
import { SelectionModel } from '@angular/cdk/collections';
import { LanguageCode, LanguageProvider } from '../../../shared/language-provider';
import { DatePipe } from '@angular/common';
import { ExternalLink } from '../../ru-admin-api';
import { FormControl, FormGroup } from '@angular/forms';
import { SbbMiniButton } from '@sbb-esta/lyne-angular/button/mini-button';
import { TableBottomBar } from '../../../shared/table-bottom-bar/table-bottom-bar';
import { TableSearchHeader } from '../../../shared/table-search-header/table-search-header';
import { takeUntilDestroyed } from '@angular/core/rxjs-interop';
import { startWith } from 'rxjs';

interface ExternalLinkFilter extends SbbTableFilter {
  search: string;
  language: LanguageCode;
}

@Component({
  selector: 'app-external-links-table',
  imports: [
    SbbTableModule,
    SbbCheckbox,
    SbbMiniButton,
    DatePipe,
    TableBottomBar,
    TableSearchHeader,
  ],
  templateUrl: './external-links-table.html',
  styleUrl: './external-links-table.css',
})
export class ExternalLinksTable {
  protected dataSource = new SbbTableDataSource<ExternalLink, ExternalLinkFilter>();
  protected columns = ['select', 'title', 'link', 'lastModifiedAt', 'lastModifiedBy', 'action'];
  protected selection = new SelectionModel<ExternalLink>(true, []);
  protected isDeleting = false;
  private readonly externalLinksService = inject(ExternalLinksService);
  private readonly languageProvider = inject(LanguageProvider);
  protected form = new FormGroup({
    search: new FormControl('', { nonNullable: true }),
    language: new FormControl(this.languageProvider.currentLanguage.path, { nonNullable: true }),
  });
  private readonly externalLinksResource = this.externalLinksService.externalLinksResource;
  private readonly sort = viewChild.required<SbbSort>(SbbSort);
  private readonly bottomBar = viewChild.required(TableBottomBar);

  constructor() {
    effect(() => {
      if (this.externalLinksResource.hasValue()) {
        this.dataSource.data = this.externalLinksResource.value().data;
      }

      this.dataSource.paginator = this.bottomBar().paginator();
      this.dataSource.sort = this.sort();
    });
    this.dataSource.filterPredicate = (data: ExternalLink, filter: ExternalLinkFilter) =>
      this.searchFilter(filter, data);
    this.dataSource.sortingDataAccessor = (data: ExternalLink, column: string) => {
      if (column === 'title' || column === 'link') {
        return this.currentLanguage(data)?.[column] ?? '';
      }
      return data[column as keyof ExternalLink] as string;
    };
    this.form.valueChanges
      .pipe(startWith(this.form.value), takeUntilDestroyed())
      .subscribe((form) => {
        this.dataSource.filter = form as ExternalLinkFilter;
      });
  }

  protected currentLanguage(externalLink: ExternalLink) {
    return externalLink[this.form.controls.language.value];
  }

  protected async edit(externalLink: ExternalLink): Promise<void> {
    await this.externalLinksService.edit(externalLink);
  }

  protected async add(): Promise<void> {
    await this.externalLinksService.add();
  }

  protected isAllSelected() {
    return this.selection.selected.length === this.dataSource.filteredData.length;
  }

  protected parentToggle() {
    if (this.isAllSelected()) {
      this.selection.clear();
    } else {
      this.dataSource.filteredData.forEach((row) => this.selection.select(row));
    }
  }

  protected async deleteSelected(): Promise<void> {
    if (this.isDeleting) return;
    this.isDeleting = true;
    try {
      await this.externalLinksService.deleteAllByIds(
        this.selection.selected.map((externalLink) => externalLink.id!),
      );
      this.selection.clear();
    } finally {
      this.isDeleting = false;
    }
  }

  private searchFilter(filter: ExternalLinkFilter, data: ExternalLink): boolean {
    const language = filter.language;
    if (language && !data[language]?.title) {
      return false;
    }
    const search = filter.search.toLowerCase();
    if (!search) return true;
    return (
      ((this.currentLanguage(data)?.title ?? '').toLowerCase().includes(search)
        || (this.currentLanguage(data)?.link ?? '').toLowerCase().includes(search)
        || (data.lastModifiedBy ?? '').toLowerCase().includes(search)
        || (data.lastModifiedAt ?? '').toString().toLowerCase().includes(search))
      ?? false
    );
  }
}
