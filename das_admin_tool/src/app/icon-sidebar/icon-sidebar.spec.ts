import {ComponentFixture, TestBed} from '@angular/core/testing';

import {IconSidebar} from './icon-sidebar';
import {AuthenticatedResult, OidcSecurityService} from 'angular-auth-oidc-client';
import {signal} from '@angular/core';

const mockOidc: Partial<OidcSecurityService> = {
  authenticated: signal({isAuthenticated: true} as AuthenticatedResult),
};

describe('IconSidebar', () => {
  let component: IconSidebar;
  let fixture: ComponentFixture<IconSidebar>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [IconSidebar],
      providers: [{
        provide: OidcSecurityService, useValue: mockOidc
      }]
    })
      .compileComponents();

    fixture = TestBed.createComponent(IconSidebar);
    component = fixture.componentInstance;
    await fixture.whenStable();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
