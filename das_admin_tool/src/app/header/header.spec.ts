import {ComponentFixture, TestBed} from '@angular/core/testing';
import packageJson from '../../../package.json';

import {Header} from './header';
import {provideZonelessChangeDetection, signal} from '@angular/core';
import {AuthenticatedResult, OidcSecurityService, UserDataResult} from 'angular-auth-oidc-client';
import {By} from '@angular/platform-browser';

const mockOidc: Partial<OidcSecurityService> = {
  userData: signal({
    userData: {
      name: 'User',
      preferred_username: 'user@example.com',
      roles: ['admin_role_a']
    }
  } as UserDataResult),
  authenticated: signal({isAuthenticated: true} as AuthenticatedResult),
  logoffLocalMultiple: () => Promise.resolve(true),
};

describe('Header', () => {
  let component: Header;
  let fixture: ComponentFixture<Header>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [Header],
      providers: [provideZonelessChangeDetection(), {
        provide: OidcSecurityService,
        useValue: mockOidc
      }],
    })
      .compileComponents();

    fixture = TestBed.createComponent(Header);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });

  it('should render title and version', () => {
    const fixture = TestBed.createComponent(Header);
    fixture.detectChanges();
    const compiled = fixture.nativeElement as HTMLElement;
    const headerInfo = compiled.querySelector('.sbb-header-info');
    expect(headerInfo?.querySelector('strong')?.textContent).toContain('DAS Admin-Tool');
    expect(headerInfo?.querySelector("span")?.textContent).toContain(`V. ${packageJson.version}`);
  });

  it('should render name', () => {
    expect(
      fixture.nativeElement.querySelector('sbb-header-button').textContent
    ).toContain('User');
  })

  it('shoud render email and roles', () => {
    // Open user menu
    const usermenuOpenButton = fixture.debugElement.query(By.css('#user-menu-trigger'));

    usermenuOpenButton.nativeElement.click();

    expect(fixture.nativeElement.querySelector('.email').textContent).toContain('user@example.com');
    expect(fixture.nativeElement.querySelector('.role').textContent).toContain('admin_role_a');
  })

  it('should logout', () => {
    const logoutSpy = spyOn(mockOidc as OidcSecurityService, 'logoffLocalMultiple');

    // Open user menu
    const usermenuOpenButton = fixture.debugElement.query(By.css('#user-menu-trigger'));

    usermenuOpenButton.nativeElement.click();

    // Logout
    const logoutButton = fixture.debugElement.query(By.css('sbb-menu-button:last-of-type'));
    logoutButton.nativeElement.click();

    expect(logoutSpy).toHaveBeenCalled();
  });
});
