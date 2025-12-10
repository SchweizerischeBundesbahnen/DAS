import {TestBed} from '@angular/core/testing';
import {App} from './app';
import {OidcSecurityService} from 'angular-auth-oidc-client';

// Mock ineum function
// eslint-disable-next-line @typescript-eslint/no-explicit-any
(globalThis as any).ineum = () => null;

const authServiceMock: Partial<OidcSecurityService> = {};

describe('App', () => {
  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [App],
      providers: [{
        provide: OidcSecurityService,
        useValue: authServiceMock
      }],
    }).compileComponents();
  });

  it('should create the app', () => {
    const fixture = TestBed.createComponent(App);
    const app = fixture.componentInstance;
    expect(app).toBeTruthy();
  });

});
