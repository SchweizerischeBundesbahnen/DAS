import { signal } from '@angular/core';
import { ComponentFixture, TestBed } from '@angular/core/testing';
import { provideRouter } from '@angular/router';
import { AuthService } from '~shared/auth-service';
import { IconSidebar } from './icon-sidebar';

const mockAuthService: Partial<AuthService> = {
  isAuthenticated: signal(true),
  isAdmin: signal(true),
  isRuAdmin: signal(true),
};

describe('IconSidebar', () => {
  let component: IconSidebar;
  let fixture: ComponentFixture<IconSidebar>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [IconSidebar],
      providers: [provideRouter([]), { provide: AuthService, useValue: mockAuthService }],
    }).compileComponents();

    fixture = TestBed.createComponent(IconSidebar);
    component = fixture.componentInstance;
    await fixture.whenStable();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
