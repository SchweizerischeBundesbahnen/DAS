import {TestBed} from '@angular/core/testing';
import {App} from './app';
import {provideZonelessChangeDetection} from '@angular/core';
import {OidcSecurityService} from 'angular-auth-oidc-client';

const authServiceMock: Partial<OidcSecurityService> = {};

describe('App', () => {
  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [App],
      providers: [provideZonelessChangeDetection(), {
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
