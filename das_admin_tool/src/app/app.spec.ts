import { TestBed } from '@angular/core/testing';
import { OidcSecurityService } from 'angular-auth-oidc-client';
import { App } from './app';

// Mock ineum function
// eslint-disable-next-line unicorn/no-global-object-property-assignment
globalThis.ineum = vi.fn();

const authServiceMock: Partial<OidcSecurityService> = {};

describe('App', () => {
	beforeEach(async () => {
		await TestBed.configureTestingModule({
			imports: [App],
			providers: [{ provide: OidcSecurityService, useValue: authServiceMock }],
		}).compileComponents();
	});

	it('should create the app', () => {
		const fixture = TestBed.createComponent(App);
		const app = fixture.componentInstance;
		expect(app).toBeTruthy();
	});
});
