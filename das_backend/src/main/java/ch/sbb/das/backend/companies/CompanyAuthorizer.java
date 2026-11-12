package ch.sbb.das.backend.companies;

import java.net.URL;
import java.util.Collections;
import java.util.Set;
import java.util.function.Predicate;
import org.springframework.security.access.AccessDeniedException;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.oauth2.server.resource.authentication.JwtAuthenticationToken;
import org.springframework.stereotype.Component;
import org.springframework.util.CollectionUtils;

/**
 * Resolves the authenticated tenant and evaluates company-level access.
 *
 * <p>The tenant is derived from the JWT issuer in the current security context.
 * Company authorization checks are based on whether the tenant's authorized company set contains all requested company codes.
 */
@Component("companyAuthorizer")
public class CompanyAuthorizer {

    private final CompanyService companyService;

    public CompanyAuthorizer(CompanyService companyService) {
        this.companyService = companyService;
    }

    /**
     * Requires access to all provided company codes.
     *
     * @param companies requested company codes
     * @throws AccessDeniedException when access is not granted
     */
    public void requireCanAccessCompanies(Set<CompanyCode> companies) {
        if (!this.canAccessCompanies(companies)) {
            throw new AccessDeniedException("Not allowed");
        }
    }

    /**
     * Checks whether the authenticated tenant can access all provided company codes.
     *
     * @param companies requested company codes
     * @return {@code true} if all requested codes are authorized; otherwise {@code false}
     */
    public boolean canAccessCompanies(Set<CompanyCode> companies) {
        return companyAccessCheck().test(companies);
    }

    /**
     * Same decision as {@link #canAccessCompanies(Set)} for many company sets at once: the authenticated tenant is resolved at most once, on the first
     * test, instead of once per entity. Meant for one request, e.g. filtering a batch; not thread-safe.
     *
     * @return a check that answers {@code true} if all company codes of the tested set are authorized; otherwise {@code false}
     */
    public Predicate<Set<CompanyCode>> companyAccessCheck() {
        return new Predicate<>() {
            private Set<CompanyCode> authorizedCompanies;

            @Override
            public boolean test(Set<CompanyCode> companies) {
                if (CollectionUtils.isEmpty(companies)) {
                    return false;
                }
                if (authorizedCompanies == null) {
                    authorizedCompanies = authorizedCompanies();
                }
                return !authorizedCompanies.isEmpty() && authorizedCompanies.containsAll(companies);
            }
        };
    }

    /**
     * Checks whether the authenticated tenant is configured as an admin tenant and allows the admin role.
     *
     * @return {@code true} for admin tenants, otherwise {@code false}
     */
    public boolean isAdminRoleAllowed() {
        Tenant tenant = getTenant();
        if (tenant == null) {
            return false;
        }
        return tenant.isAdminRoleAllowed();
    }

    /**
     * Returns the name of the authenticated tenant.
     *
     * @return current tenant name, or {@code null} when no tenant can be resolved
     */
    public String currentTenantName() {
        Tenant tenant = getTenant();
        return tenant == null ? null : tenant.name();
    }

    /**
     * Returns the name of the authenticated tenant and fails when none can be resolved.
     *
     * @return current tenant name
     * @throws AccessDeniedException when no tenant can be resolved from the current security context
     */
    public String requireCurrentTenant() {
        String tenantName = currentTenantName();
        if (tenantName == null) {
            throw new AccessDeniedException("Not allowed");
        }
        return tenantName;
    }

    /**
     * Requires the authenticated tenant to match the provided tenant name.
     *
     * @param tenantName tenant name to check against the authenticated tenant
     * @throws AccessDeniedException when access is not granted
     */
    public void requireCanAccessTenant(String tenantName) {
        if (!canAccessTenant(tenantName)) {
            throw new AccessDeniedException("Not allowed");
        }
    }

    /**
     * Checks whether the authenticated tenant is the provided tenant.
     *
     * @param tenantName tenant name to check against the authenticated tenant
     * @return {@code true} if a tenant can be resolved and it matches; otherwise {@code false}
     */
    public boolean canAccessTenant(String tenantName) {
        return tenantAccessCheck().test(tenantName);
    }

    /**
     * Same decision as {@link #canAccessTenant(String)} for many tenant names at once: the authenticated tenant is resolved at most once, on the first
     * test. Meant for one request, e.g. filtering a batch; not thread-safe.
     *
     * @return a check that answers {@code true} if a tenant can be resolved and it matches the tested name; otherwise {@code false}
     */
    public Predicate<String> tenantAccessCheck() {
        return new Predicate<>() {
            private boolean resolved;
            private String currentTenantName;

            @Override
            public boolean test(String tenantName) {
                if (!resolved) {
                    currentTenantName = currentTenantName();
                    resolved = true;
                }
                return currentTenantName != null && currentTenantName.equals(tenantName);
            }
        };
    }

    /**
     * Returns the company codes the authenticated tenant is authorized for.
     *
     * @return authorized company codes, or an empty set if no tenant can be resolved
     */
    public Set<CompanyCode> authorizedCompanies() {
        Tenant tenant = getTenant();
        if (tenant == null || tenant.companies() == null) {
            return Collections.emptySet();
        }

        return tenant.companies();
    }

    private Tenant getTenant() {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        if (!(authentication instanceof JwtAuthenticationToken jwtAuth)) {
            return null;
        }

        URL issuer = jwtAuth.getToken().getIssuer();
        if (issuer == null) {
            return null;
        }

        return companyService.getTenantByIssuerUri(issuer.toString());
    }
}
