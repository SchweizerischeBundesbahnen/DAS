import { HttpResourceRef } from '@angular/common/http';
import { TestBed } from '@angular/core/testing';
import { SbbDialogService } from '@sbb-esta/lyne-angular/dialog';
import { SbbOverlayCloseEvent } from '@sbb-esta/lyne-elements/overlay.js';
import { of, throwError } from 'rxjs';
import { RecentCompaniesStore } from '~shared/recent-companies.store';
import { ToastService } from '~shared/toast-service';
import {
	RuAdminApi,
	RuIndication,
	RuIndicationApiResponse,
	RuIndicationTemplate,
	RuIndicationTemplateApiResponse,
} from '../ru-admin-api';
import { RuIndicationDialogEditResult, RuIndicationService } from './ru-indication.service';

const ruIndicationSample: RuIndication = {
	id: 1,
	content: {},
	scope: { companies: [] },
	periods: [],
};

const mockRuAdminApi: Partial<RuAdminApi> = {
	postRuIndication: () => of({} as RuIndicationApiResponse),
	putRuIndication: () => of({} as RuIndicationApiResponse),
	deleteAllRuIndications: () => of(undefined),
	ruIndications: { reload: () => true } as HttpResourceRef<RuIndicationApiResponse | undefined>,
	ruIndicationTemplates: {
		value: () => ({ data: [] as RuIndicationTemplate[] }),
	} as HttpResourceRef<RuIndicationTemplateApiResponse | undefined>,
};

const mockToastService: Partial<ToastService> = { success: vi.fn(), error: vi.fn() };

const openSpy = vi.fn();
const mockSbbDialogService: Partial<SbbDialogService> = { open: openSpy };

const mockRecentCompaniesStore: Partial<RecentCompaniesStore> = { save: vi.fn() };

function mockDialogResult(result: RuIndicationDialogEditResult | null) {
	openSpy.mockReturnValue({ afterClosed: of({ result } as SbbOverlayCloseEvent) });
}

describe('RuIndicationService', () => {
	let service: RuIndicationService;

	beforeEach(() => {
		vi.clearAllMocks();

		TestBed.configureTestingModule({
			providers: [
				RuIndicationService,
				{ provide: RuAdminApi, useValue: mockRuAdminApi },
				{ provide: SbbDialogService, useValue: mockSbbDialogService },
				{ provide: ToastService, useValue: mockToastService },
				{ provide: RecentCompaniesStore, useValue: mockRecentCompaniesStore },
			],
		});

		service = TestBed.inject(RuIndicationService);
	});

	it('edit should delete when dialog returns delete', async () => {
		const apiDeleteSpy = vi.spyOn(mockRuAdminApi, 'deleteAllRuIndications');
		const successToastSpy = vi.spyOn(mockToastService, 'success');
		mockDialogResult('delete');

		await service.edit(ruIndicationSample);

		expect(successToastSpy).toHaveBeenCalled();
		expect(apiDeleteSpy).toHaveBeenCalledWith([ruIndicationSample.id]);
	});

	it('edit should call put when dialog returns a result', async () => {
		const apiSpy = vi.spyOn(mockRuAdminApi, 'putRuIndication');
		const successToastSpy = vi.spyOn(mockToastService, 'success');
		mockDialogResult({
			...ruIndicationSample,
			content: { category: 'x' },
			scope: { companies: ['1085'] },
		});

		await service.edit(ruIndicationSample);

		expect(successToastSpy).toHaveBeenCalled();
		expect(apiSpy).toHaveBeenCalled();
		expect(mockRecentCompaniesStore.save).toHaveBeenCalledWith(['1085']);
	});

	it('edit should do nothing when dialog closed without result', async () => {
		const apiSpy = vi.spyOn(mockRuAdminApi, 'putRuIndication');
		mockDialogResult(null);

		await service.edit(ruIndicationSample);

		expect(apiSpy).not.toHaveBeenCalled();
	});

	it('add should post when dialog returns result', async () => {
		const apiSpy = vi.spyOn(mockRuAdminApi, 'postRuIndication');
		const successToastSpy = vi.spyOn(mockToastService, 'success');
		mockDialogResult(null);
		openSpy.mockReturnValueOnce({
			afterClosed: of({ result: { content: {}, scope: { companies: ['1087'] }, periods: [] } }),
		});

		await service.add();

		expect(successToastSpy).toHaveBeenCalled();
		expect(apiSpy).toHaveBeenCalled();
		expect(mockRecentCompaniesStore.save).toHaveBeenCalledWith(['1087']);
	});

	it('deleteAll should call API and show toast', async () => {
		const apiSpy = vi.spyOn(mockRuAdminApi, 'deleteAllRuIndications');
		const successToastSpy = vi.spyOn(mockToastService, 'success');

		await service.deleteAll([
			{ id: 5, content: {}, scope: { companies: [] }, periods: [] },
			{ id: 6, content: {}, scope: { companies: [] }, periods: [] },
		] as RuIndication[]);

		expect(apiSpy).toHaveBeenCalledWith([5, 6]);
		expect(successToastSpy).toHaveBeenCalled();
	});

	it('edit should show error toast when delete API fails', async () => {
		vi.spyOn(mockRuAdminApi, 'deleteAllRuIndications').mockReturnValueOnce(
			throwError(() => new Error('API error')),
		);
		const errorToastSpy = vi.spyOn(mockToastService, 'error');
		mockDialogResult('delete');

		await service.edit(ruIndicationSample);

		expect(errorToastSpy).toHaveBeenCalled();
	});

	it('edit should show error toast when put API fails', async () => {
		vi.spyOn(mockRuAdminApi, 'putRuIndication').mockReturnValueOnce(
			throwError(() => new Error('API error')),
		);
		const errorToastSpy = vi.spyOn(mockToastService, 'error');
		mockDialogResult({ ...ruIndicationSample, scope: { companies: ['1085'] } });

		await service.edit(ruIndicationSample);

		expect(errorToastSpy).toHaveBeenCalled();
	});

	it('add should show error toast when post API fails', async () => {
		vi.spyOn(mockRuAdminApi, 'postRuIndication').mockReturnValueOnce(
			throwError(() => new Error('API error')),
		);
		const errorToastSpy = vi.spyOn(mockToastService, 'error');
		openSpy.mockReturnValueOnce({
			afterClosed: of({ result: { content: {}, scope: { companies: ['1087'] }, periods: [] } }),
		});

		await service.add();

		expect(errorToastSpy).toHaveBeenCalled();
	});

	it('deleteAll should show error toast when API fails', async () => {
		vi.spyOn(mockRuAdminApi, 'deleteAllRuIndications').mockReturnValueOnce(
			throwError(() => new Error('API error')),
		);
		const errorToastSpy = vi.spyOn(mockToastService, 'error');

		await service.deleteAll([
			{ id: 20, content: {}, scope: { companies: [] }, periods: [] },
		] as RuIndication[]);

		expect(errorToastSpy).toHaveBeenCalled();
	});
});
