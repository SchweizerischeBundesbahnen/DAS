import {ComponentFixture, TestBed} from '@angular/core/testing';
import packageJson from '../../../package.json';

import {Header} from './header';
import {signal} from '@angular/core';
import {AuthenticatedResult, OidcSecurityService, UserDataResult} from 'angular-auth-oidc-client';
import {By} from '@angular/platform-browser';
import {vi} from 'vitest';
import {Router} from '@angular/router';

const mockOidc: Partial<OidcSecurityService> = {
  userData: signal({
    userData: {
      name: 'User',
      preferred_username: 'user@example.com',
      roles: ['ru_admin']
    }
  } as UserDataResult),
  authenticated: signal({isAuthenticated: true} as AuthenticatedResult),
  logoffLocalMultiple: () => Promise.resolve(true),
};

const mockRouter = {
  navigate: vi.fn().mockResolvedValue(true),
};

describe('Header', () => {
  let component: Header;
  let fixture: ComponentFixture<Header>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [Header],
      providers: [
        {provide: OidcSecurityService, useValue: mockOidc},
        {provide: Router, useValue: mockRouter}
      ],
    })
      .compileComponents();

    fixture = TestBed.createComponent(Header);
    component = fixture.componentInstance;
    await fixture.whenStable();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });

  it('should render title and version', async () => {
    const fixture = TestBed.createComponent(Header);
    await fixture.whenStable();
    const compiled = fixture.nativeElement as HTMLElement;
    const headerInfo = compiled.querySelector('.sbb-header-info');
    expect(headerInfo?.querySelector('strong')?.textContent).toContain('DAS Admin-Tool');
    expect(headerInfo?.querySelector("span")?.textContent).toContain(`V. ${packageJson.version}`);
  });

  it('should render name', () => {
    expect(fixture.nativeElement.querySelector('sbb-header-button:nth-last-of-type(2)').textContent).toContain('User');
  });

  it('shoud render email and roles', () => {
    // Open user menu
    const usermenuOpenButton = fixture.debugElement.query(By.css('#user-menu-trigger'));

    usermenuOpenButton.nativeElement.click();

    expect(fixture.nativeElement.querySelector('.email').textContent).toContain('user@example.com');
    expect(fixture.nativeElement.querySelector('.role').textContent).toContain('EVU Admin');
  });

  it('should logout', () => {
    const logoutSpy = vi.spyOn(mockOidc as OidcSecurityService, 'logoffLocalMultiple');

    // Open user menu
    const usermenuOpenButton = fixture.debugElement.query(By.css('#user-menu-trigger'));

    usermenuOpenButton.nativeElement.click();

    // Logout
    const logoutButton = fixture.debugElement.query(By.css('sbb-menu-button:last-of-type'));
    logoutButton.nativeElement.click();

    expect(logoutSpy).toHaveBeenCalled();
  });
});
