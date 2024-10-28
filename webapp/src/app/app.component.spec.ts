import { ComponentFixture, TestBed } from '@angular/core/testing';
import { AppComponent } from './app.component';
import { AuthService } from "./auth.service";
import { MqService } from "./mq.service";
import { OidcSecurityService, UserDataResult } from "angular-auth-oidc-client";
import { signal } from "@angular/core";
import { SbbIconTestingModule } from "@sbb-esta/angular/icon/testing";
import { NoopAnimationsModule } from "@angular/platform-browser/animations";
import { By } from "@angular/platform-browser";
import { SbbMenuItem } from "@sbb-esta/angular/menu";
import { RouterTestingModule } from "@angular/router/testing";

const mockAuth: Partial<AuthService> = {};
const mockOidc: Partial<OidcSecurityService> = {
  userData: signal({userData: {name: 'User'}} as UserDataResult),
  logoffLocalMultiple: () => Promise.resolve(true),
};
const mockMq: Partial<MqService> = {};

describe('AppComponent', () => {
  let component: AppComponent;
  let fixture: ComponentFixture<AppComponent>

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [NoopAnimationsModule, RouterTestingModule, SbbIconTestingModule, AppComponent,],
      providers: [
        {provide: AuthService, useValue: mockAuth},
        {provide: OidcSecurityService, useValue: mockOidc},
        {provide: MqService, useValue: mockMq},
      ]
    }).compileComponents();
  });

  beforeEach(() => {
    fixture = TestBed.createComponent(AppComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  })

  it('should create the app', () => {
    expect(component).toBeTruthy();
  });

  it('should render title', () => {
    expect(
      fixture.nativeElement.querySelector('.sbb-header-lean-titlebox > span').textContent,
    ).toContain('DAS playground');
  });

  it('should render name', () => {
    expect(
      fixture.nativeElement.querySelector('.sbb-usermenu-user-info-display-name').textContent,
    ).toContain('User');
  });

  it('should logout', () => {
    const logoutSpy = spyOn(mockOidc as OidcSecurityService, 'logoffLocalMultiple');

    // Open user menu
    const usermenuOpenButton = fixture.debugElement.query(By.css('.sbb-menu-trigger-usermenu'));
    usermenuOpenButton.nativeElement.click();
    fixture.detectChanges();

    // Logout
    const logoutButton = fixture.debugElement.query(By.directive(SbbMenuItem));
    logoutButton.nativeElement.click();

    expect(logoutSpy).toHaveBeenCalled();
  });
});
