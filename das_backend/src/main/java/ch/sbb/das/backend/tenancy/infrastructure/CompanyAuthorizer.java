package ch.sbb.das.backend.tenancy.infrastructure;

import ch.sbb.das.backend.common.CompanyCode;
import ch.sbb.das.backend.tenancy.domain.model.Tenant;
import ch.sbb.das.backend.tenancy.domain.repository.TenantRepository;
import java.net.URL;
import java.util.Set;
import org.springframework.security.core.Authentication;
import org.springframework.security.oauth2.server.resource.authentication.JwtAuthenticationToken;
import org.springframework.stereotype.Component;

@Component("companyAuthorizer")
public class CompanyAuthorizer {

    private final TenantRepository tenantRepository;

    public CompanyAuthorizer(TenantRepository tenantRepository) {
        this.tenantRepository = tenantRepository;
    }

    public Set<CompanyCode> getCompanyCodes(Authentication authentication) {
        Tenant tenant = getTenant(authentication);
        if (tenant == null || tenant.companies() == null) {
            return Set.of();
        }
        return tenant.companies();
    }

    public boolean canEditCompany(Authentication authentication, Set<CompanyCode> companies) {
        if (companies == null || companies.isEmpty()) {
            return false;
        }
        Set<CompanyCode> tenantCompanies = getCompanyCodes(authentication);
        if (tenantCompanies == null || tenantCompanies.isEmpty()) {
            return false;
        }
        return tenantCompanies.containsAll(companies);
    }

    public boolean isAdminTenant(Authentication authentication) {
        Tenant tenant = getTenant(authentication);
        if (tenant == null) {
            return false;
        }
        return tenantRepository.isAdminTenant(tenant);
    }

    private Tenant getTenant(Authentication authentication) {
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

