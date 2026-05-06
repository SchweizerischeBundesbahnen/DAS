package ch.sbb.das.backend.tenancy.infrastructure;

import ch.sbb.das.backend.tenancy.domain.model.Tenant;
import ch.sbb.das.backend.tenancy.domain.repository.TenantRepository;
import java.net.URL;
import java.util.Collections;
import java.util.Set;
import org.springframework.security.access.AccessDeniedException;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.oauth2.server.resource.authentication.JwtAuthenticationToken;
import org.springframework.stereotype.Component;

@org.springframework.modulith.NamedInterface("tenancy")
@Component("companyAuthorizer")
public class CompanyAuthorizer {

    private final TenantRepository tenantRepository;

    public CompanyAuthorizer(TenantRepository tenantRepository) {
        this.tenantRepository = tenantRepository;
    }

    public void requireCanAccessCompanies(Set<String> companies) {
        if (!this.canAccessCompany(companies)) {
            throw new AccessDeniedException("Not allowed");
        }
    }

    public boolean canAccessCompany(Set<String> companies) {
        if (companies == null || companies.isEmpty()) {
            return false;
        }
        Set<String> authorizedCompanies = authorizedCompanies();
        if (authorizedCompanies.isEmpty()) {
            return false;
        }
        return authorizedCompanies.containsAll(companies);
    }

    public boolean isAdminTenant() {
        Tenant tenant = getTenant();
        if (tenant == null) {
            return false;
        }
        return tenantRepository.isAdminTenant(tenant);
    }

    public Set<String> authorizedCompanies() {
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

        return tenantRepository.getByIssuerUri(issuer.toString());
    }
}
