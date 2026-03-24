package ch.sbb.backend.tenancy.infrastructure;

import ch.sbb.backend.tenancy.domain.model.Tenant;
import ch.sbb.backend.tenancy.domain.repository.TenantRepository;
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

    public boolean canEditCompany(Authentication authentication, Set<String> companies) {
        if (companies == null || companies.isEmpty()) {
            return false;
        }
        Tenant tenant = getTenant(authentication);
        if (tenant == null) {
            return false;
        }
        if (tenant.companies() == null || tenant.companies().isEmpty()) {
            return false;
        }

        return tenant.companies().containsAll(companies);
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

        return tenantRepository.getByIssuerUri(issuer.toString());
    }
}

