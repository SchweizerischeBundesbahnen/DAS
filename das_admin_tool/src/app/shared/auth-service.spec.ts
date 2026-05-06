import {TestBed} from '@angular/core/testing';
import {Router} from '@angular/router';
import {OidcSecurityService} from 'angular-auth-oidc-client';
import {vi} from 'vitest';

import {AuthService} from './auth-service';
import {environment} from '../../environments/environment';

describe('AuthService', () => {
  let service: AuthService;

  const setup = ({isAuthenticated = false, userData = {}}: {
    isAuthenticated?: boolean;
    userData?: unknown
  } = {}) => {
    const oidcSecurityServiceMock = {
      authenticated: vi.fn(() => ({isAuthenticated})),
      userData: vi.fn(() => ({userData})),
      authorize: vi.fn(),
      logoffLocalMultiple: vi.fn(),
    };

    const routerMock = {
      navigate: vi.fn().mockResolvedValue(true),
    };

    TestBed.configureTestingModule({
      providers: [
        {provide: OidcSecurityService, useValue: oidcSecurityServiceMock},
        {provide: Router, useValue: routerMock},
      ],
    });

    service = TestBed.inject(AuthService);
    return {oidcSecurityServiceMock, routerMock};
  };

  it('should be created', () => {
    setup();
    expect(service).toBeTruthy();
  });

  it('exposes auth and user identity signals', () => {
    setup({
      isAuthenticated: true,
      userData: {
        name: 'Jane Doe',
        preferred_username: 'jane.doe@sbb.ch',
        oid: 'oid-123',
      },
    });

    expect(service.isAuthenticated()).toBe(true);
    expect(service.name()).toBe('Jane Doe');
    expect(service.email()).toBe('jane.doe@sbb.ch');
    expect(service.oid()).toBe('oid-123');
  });

  it('isAdmin is true only for admin role in admin tenant', () => {
    setup({
      userData: {
        roles: ['admin'],
        tid: environment.adminTenantId,
      },
    });

    expect(service.isAdmin()).toBe(true);
  });

  it('isAdmin is false for admin role outside admin tenant', () => {
    setup({
      userData: {
        roles: ['admin'],
        tid: 'other-tenant',
      },
    });

    expect(service.isAdmin()).toBe(false);
  });

  it('isRuAdmin is true for ru_admin role', () => {
    setup({
      userData: {
        roles: ['ru_admin'],
      },
    });

    expect(service.isRuAdmin()).toBe(true);
  });

  it('isRuAdmin ignores non-enum admin-like roles', () => {
    setup({
      userData: {
        roles: ['super_admin', 'tenant_admin'],
      },
    });

    expect(service.isRuAdmin()).toBe(false);
    expect(service.isAdmin()).toBe(false);
  });

  it('logout logs off locally and navigates to unauthorized', async () => {
    const {oidcSecurityServiceMock, routerMock} = setup();

    await service.logout();

    expect(oidcSecurityServiceMock.logoffLocalMultiple).toHaveBeenCalledWith();
    expect(routerMock.navigate).toHaveBeenCalledWith(['/unauthorized']);
  });
});
