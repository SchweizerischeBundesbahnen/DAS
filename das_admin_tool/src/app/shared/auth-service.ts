import { computed, inject, Injectable } from '@angular/core';
import { Router } from '@angular/router';
import { OidcSecurityService } from 'angular-auth-oidc-client';
import { environment } from '../../environments/environment';

export enum UserRole {
  ADMIN = 'admin',
  RU_ADMIN = 'ru_admin',
}

interface UserData {
  tid: string;
  name: string;
  preferred_username: string;
  oid: string;
  roles: string[];
}

@Injectable({ providedIn: 'root' })
export class AuthService {
  private readonly oidcSecurityService = inject(OidcSecurityService);
  public readonly isAuthenticated = computed(
    () => this.oidcSecurityService.authenticated().isAuthenticated,
  );
  private readonly router = inject(Router);
  private readonly userData = computed(
    () => this.oidcSecurityService.userData().userData as UserData,
  );
  public readonly name = computed(() => this.userData().name);
  public readonly email = computed(() => this.userData().preferred_username);
  public readonly oid = computed(() => this.userData().oid);
  public readonly isAllowedTenant = computed(() => {
    const tid = this.userData().tid;
    return !!tid && environment.allowedTenantIds.includes(tid);
  });
  public readonly isAdmin = computed(
    () =>
      this.isAllowedTenant()
      && this.hasAnyRole(UserRole.ADMIN)
      && this.userData().tid === environment.adminTenantId,
  );
  public readonly isRuAdmin = computed(
    () => this.isAllowedTenant() && (this.isAdmin() || this.hasAnyRole(UserRole.RU_ADMIN)),
  );
  private readonly roles = computed(() =>
    (this.userData().roles ?? []).filter((role: string): role is UserRole =>
      Object.values(UserRole).includes(role as UserRole),
    ),
  );

  public login() {
    this.oidcSecurityService.authorize();
  }

  public async logout() {
    this.oidcSecurityService.logoffLocalMultiple();
    return this.navigateToUnauthorized();
  }

  public switchLogin() {
    this.oidcSecurityService.authorize(undefined, { customParams: { prompt: 'select_account' } });
  }

  public navigateToUnauthorized() {
    return this.router.navigate(['/unauthorized']);
  }

  private hasAnyRole(...roles: UserRole[]) {
    const userRoles = this.roles();
    return roles.some((role) => userRoles.includes(role));
  }
}
