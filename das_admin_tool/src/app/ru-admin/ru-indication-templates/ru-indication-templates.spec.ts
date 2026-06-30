import { ComponentFixture, TestBed } from '@angular/core/testing';
import { RuIndicationTemplateService } from './ru-indication-template.service';
import { RuIndicationTemplates } from './ru-indication-templates';

const mockRuIndicationTemplateService = {
	ruIndicationTemplatesResource: new Proxy({}, { get: () => vi.fn() }),
};

describe('RuIndicationTemplates', () => {
	let component: RuIndicationTemplates;
	let fixture: ComponentFixture<RuIndicationTemplates>;

	beforeEach(async () => {
		await TestBed.configureTestingModule({
			imports: [RuIndicationTemplates],
			providers: [
				{ provide: RuIndicationTemplateService, useValue: mockRuIndicationTemplateService },
			],
		}).compileComponents();

		fixture = TestBed.createComponent(RuIndicationTemplates);
		component = fixture.componentInstance;
		await fixture.whenStable();
	});

	it('should create', () => {
		expect(component).toBeTruthy();
	});
});
