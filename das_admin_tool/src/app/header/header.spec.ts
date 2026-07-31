import { signal } from '@angular/core';
import { ComponentFixture, TestBed } from '@angular/core/testing';
import { Router } from '@angular/router';
import { AuthenticatedResult, OidcSecurityService, UserDataResult } from 'angular-auth-oidc-client';
import packageJson from '~package.json';
import { Header } from './header';

const mockOidc: Partial<OidcSecurityService> = {
  userData: signal({
    userData: {
      name: 'User',
      preferred_username: 'user@example.com',
      roles: ['ru_admin'],
      tid: '2cda5d11-f0ac-46b3-967d-af1b2e1bd01a',
    },
  } as UserDataResult),
  authenticated: signal({ isAuthenticated: true } as AuthenticatedResult),
  logoffLocalMultiple: () => {
    // empty
  },
};

const mockRouter = {
  navigate: vi.fn().mockResolvedValue(true),
};

describe('Header', () => {
  let component: Header;
  let fixture: ComponentFixture<Header>;
  let element: HTMLElement;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [Header],
      providers: [
        { provide: OidcSecurityService, useValue: mockOidc },
        { provide: Router, useValue: mockRouter },
      ],
    }).compileComponents();

    fixture = TestBed.createComponent(Header);
    component = fixture.componentInstance;
    element = fixture.nativeElement as HTMLElement;
    await fixture.whenStable();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });

  it('should render title and version', async () => {
    await fixture.whenStable();
    const headerInfo = element.querySelector('.sbb-header-info')!;
    expect(headerInfo.querySelector('strong')!.textContent).toContain('DAS Admin-Tool');
    expect(headerInfo.querySelector('span')!.textContent).toContain(`V. ${packageJson.version}`);
  });

  it('should render name', () => {
    expect(element.querySelector('sbb-header-button:nth-last-of-type(2)')!.textContent).toContain(
      'User',
    );
  });

  it('shoud render email and roles', () => {
    // Open user menu
    element.querySelector<HTMLElement>('#user-menu-trigger')!.click();

    expect(element.querySelector('.email')!.textContent).toContain('user@example.com');
    expect(element.querySelector('.role')!.textContent).toContain('EVU Admin');
  });

  it('should logout', () => {
    const logoutSpy = vi.spyOn(mockOidc as OidcSecurityService, 'logoffLocalMultiple');

    // Open user menu
    element.querySelector<HTMLElement>('#user-menu-trigger')!.click();

    // Logout
    element.querySelector<HTMLElement>('sbb-menu-button:last-of-type')!.click();

    expect(logoutSpy).toHaveBeenCalled();
  });
});
