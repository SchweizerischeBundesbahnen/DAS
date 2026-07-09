package ch.sbb.das.backend.companies;

import java.net.URL;
import java.util.Collections;
import java.util.Objects;
import java.util.Set;
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
        if (CollectionUtils.isEmpty(companies)) {
            return false;
        }
        Set<CompanyCode> authorizedCompanies = authorizedCompanies();
        if (authorizedCompanies.isEmpty()) {
            return false;
        }
        return authorizedCompanies.containsAll(companies);
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
        if (!Objects.equals(requireCurrentTenant(), tenantName)) {
            throw new AccessDeniedException("Not allowed");
        }
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
