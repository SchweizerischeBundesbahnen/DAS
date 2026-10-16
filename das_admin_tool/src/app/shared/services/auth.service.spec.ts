import { TestBed } from '@angular/core/testing';
import { Router } from '@angular/router';
import { OidcSecurityService } from 'angular-auth-oidc-client';
import { environment } from '~src/environments/environment';
import { AuthService } from './auth.service';

describe('AuthService', () => {
  let authService: AuthService;

  const setup = ({
    isAuthenticated = false,
    userData = {},
  }: { isAuthenticated?: boolean; userData?: unknown } = {}) => {
    const oidcSecurityServiceMock = {
      authenticated: vi.fn(() => ({ isAuthenticated })),
      userData: vi.fn(() => ({ userData })),
      authorize: vi.fn(),
      logoffLocalMultiple: vi.fn(),
    };

    const routerMock = { navigate: vi.fn().mockResolvedValue(true) };

    TestBed.configureTestingModule({
      providers: [
        { provide: OidcSecurityService, useValue: oidcSecurityServiceMock },
        { provide: Router, useValue: routerMock },
      ],
    });

    authService = TestBed.inject(AuthService);
    return { oidcSecurityServiceMock, routerMock };
  };

  it('should be created', () => {
    setup();
    expect(authService).toBeTruthy();
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

    expect(authService.isAuthenticated()).toBe(true);
    expect(authService.name()).toBe('Jane Doe');
    expect(authService.email()).toBe('jane.doe@sbb.ch');
    expect(authService.oid()).toBe('oid-123');
  });

  it('isAdmin is true only for admin role in admin tenant', () => {
    setup({
      userData: {
        roles: ['admin'],
        tid: environment.adminTenantId,
      },
    });

    expect(authService.isAdmin()).toBe(true);
  });

  it('isAdmin is false for admin role outside admin tenant', () => {
    setup({
      userData: {
        roles: ['admin'],
        tid: 'other-tenant',
      },
    });

    expect(authService.isAdmin()).toBe(false);
  });

  it('isRuAdmin is true for ru_admin role with allowed tenant', () => {
    setup({
      userData: {
        roles: ['ru_admin'],
        tid: environment.allowedTenantIds[0],
      },
    });

    expect(authService.isRuAdmin()).toBe(true);
  });

  it('isAllowedTenant is false for disallowed tenant', () => {
    setup({
      userData: {
        roles: ['ru_admin'],
        tid: 'unknown-tenant-id',
      },
    });

    expect(authService.isAllowedTenant()).toBe(false);
    expect(authService.isRuAdmin()).toBe(false);
  });

  it('isRuAdmin ignores non-enum admin-like roles', () => {
    setup({
      userData: {
        roles: ['super_admin', 'tenant_admin'],
      },
    });

    expect(authService.isRuAdmin()).toBe(false);
    expect(authService.isAdmin()).toBe(false);
  });

  it('logout logs off locally and navigates to unauthorized', async () => {
    const { oidcSecurityServiceMock, routerMock } = setup();

    await authService.logout();

    expect(oidcSecurityServiceMock.logoffLocalMultiple).toHaveBeenCalledWith();
    expect(routerMock.navigate).toHaveBeenCalledWith(['/unauthorized']);
  });
});
