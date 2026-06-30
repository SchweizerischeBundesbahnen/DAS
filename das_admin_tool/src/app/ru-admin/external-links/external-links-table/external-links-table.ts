import { SelectionModel } from '@angular/cdk/collections';
import { DatePipe, formatDate } from '@angular/common';
import { Component, effect, inject, LOCALE_ID, viewChild } from '@angular/core';
import { NonNullableFormBuilder, ReactiveFormsModule } from '@angular/forms';
import { SbbButtonModule } from '@sbb-esta/lyne-angular/button';
import { SbbCheckbox } from '@sbb-esta/lyne-angular/checkbox';
import { SbbFormField } from '@sbb-esta/lyne-angular/form-field';
import { SbbIcon } from '@sbb-esta/lyne-angular/icon';
import { SbbCompactPaginator } from '@sbb-esta/lyne-angular/paginator/compact-paginator';
import { SbbSelectModule } from '@sbb-esta/lyne-angular/select';
import { SbbSort, SbbTableDataSource, SbbTableModule } from '@sbb-esta/lyne-angular/table';
import { ExternalLink } from '~ru-admin/ru-admin-api';
import { LanguageProvider } from '~shared/language-provider';
import { ExternalLinksService } from '../external-links.service';

@Component({
	selector: 'app-external-links-table',
	imports: [
		SbbTableModule,
		SbbCheckbox,
		SbbButtonModule,
		SbbCompactPaginator,
		DatePipe,
		SbbSelectModule,
		SbbIcon,
		SbbFormField,
		ReactiveFormsModule,
	],
	templateUrl: './external-links-table.html',
	styleUrl: './external-links-table.css',
})
export class ExternalLinksTable {
	protected readonly languageProvider = inject(LanguageProvider);
	private readonly externalLinksService = inject(ExternalLinksService);
	private readonly localeId = inject(LOCALE_ID);
	private readonly formBuilder = inject(NonNullableFormBuilder);

	protected form = this.formBuilder.group({
		language: [this.languageProvider.currentLanguage.path],
	});

	private readonly externalLinksResource = this.externalLinksService.externalLinksResource;

	private readonly paginator = viewChild.required<SbbCompactPaginator>(SbbCompactPaginator);
	private readonly sort = viewChild.required<SbbSort>(SbbSort);

	protected dataSource = new SbbTableDataSource<ExternalLink>();
	protected columns = ['select', 'title', 'link', 'lastModifiedAt', 'lastModifiedBy', 'action'];
	protected selection = new SelectionModel<ExternalLink>(true, []);
	protected readonly PAGE_SIZE = 20;
	protected isDeleting = false;

	constructor() {
		effect(() => {
			if (this.externalLinksResource.hasValue()) {
				this.dataSource.data = this.externalLinksResource.value().data;
			}

			this.dataSource.paginator = this.paginator();
			this.dataSource.sort = this.sort();
		});
		this.dataSource.sortingDataAccessor = (data: ExternalLink, column: string) => {
			switch (column) {
				case 'title':
				case 'link': {
					return this.currentLanguage(data)?.[column] ?? '';
				}
				case 'lastModifiedAt': {
					return formatDate(data[column]!, 'short', this.localeId);
				}
				default: {
					return data[column as keyof ExternalLink] as string;
				}
			}
		};
	}

	protected currentLanguage(externalLink: ExternalLink) {
		return externalLink[this.form.get('language')!.value];
	}

	protected async edit(externalLink: ExternalLink): Promise<void> {
		await this.externalLinksService.edit(externalLink);
	}

	protected async add(): Promise<void> {
		await this.externalLinksService.add();
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
			for (const row of this.dataSource.filteredData) this.selection.select(row);
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
}
