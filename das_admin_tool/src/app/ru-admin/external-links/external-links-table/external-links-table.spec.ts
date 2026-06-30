import { HttpResourceRef } from '@angular/common/http';
import { LOCALE_ID } from '@angular/core';
import { ComponentFixture, TestBed } from '@angular/core/testing';
import { ExternalLink, ExternalLinkApiResponse } from '~ru-admin/ru-admin-api';
import { ExternalLinksService } from '../external-links.service';
import { ExternalLinksTable } from './external-links-table';

const externalLinks: ExternalLink[] = [
	{
		id: 1,
		companies: ['2185'],
		de: { title: 'Titel DE', link: 'https://sbb.ch' },
		fr: { title: 'Titre FR', link: 'https://sbb.ch' },
		it: { title: 'Titolo IT', link: 'https://sbb.ch' },
	},
	{ id: 2, companies: ['1080'], de: { title: 'Sicherheit', link: 'https://sbb.ch' } },
];

const mockExternalLinksService: Partial<ExternalLinksService> = {
	edit: vi.fn(),
	add: vi.fn(),
	deleteAllByIds: vi.fn(),
	externalLinksResource: {
		hasValue: () => false,
		value: () => ({ data: [] }) as ExternalLinkApiResponse,
		reload: () => true,
	} as unknown as HttpResourceRef<ExternalLinkApiResponse | undefined>,
};

describe('ExternalLinksTable', () => {
	let component: ExternalLinksTable;
	let fixture: ComponentFixture<ExternalLinksTable>;

	beforeEach(async () => {
		vi.clearAllMocks();

		await TestBed.configureTestingModule({
			imports: [ExternalLinksTable],
			providers: [
				{ provide: ExternalLinksService, useValue: mockExternalLinksService },
				{ provide: LOCALE_ID, useValue: 'de-CH' },
			],
		}).compileComponents();

		fixture = TestBed.createComponent(ExternalLinksTable);
		component = fixture.componentInstance;
		await fixture.whenStable();
	});

	describe('isAllSelected', () => {
		it('should return false when nothing is selected', () => {
			component['dataSource'].data = externalLinks;
			expect(component['isAllSelected']()).toBe(false);
		});

		it('should return false when only some rows are selected', () => {
			component['dataSource'].data = externalLinks;
			component['selection'].select(externalLinks[0]);
			expect(component['isAllSelected']()).toBe(false);
		});

		it('should return true when all rows are selected', () => {
			component['dataSource'].data = externalLinks;
			component['selection'].select(...externalLinks);
			expect(component['isAllSelected']()).toBe(true);
		});
	});

	describe('parentToggle', () => {
		it('should select all rows when none are selected', () => {
			component['dataSource'].data = externalLinks;
			component['parentToggle']();
			expect(component['selection'].selected).toEqual(externalLinks);
		});

		it('should select all rows when only some are selected', () => {
			component['dataSource'].data = externalLinks;
			component['selection'].select(externalLinks[0]);
			component['parentToggle']();
			expect(component['selection'].selected).toHaveLength(externalLinks.length);
		});

		it('should clear selection when all rows are already selected', () => {
			component['dataSource'].data = externalLinks;
			component['selection'].select(...externalLinks);
			component['parentToggle']();
			expect(component['selection'].selected).toEqual([]);
		});
	});
});
