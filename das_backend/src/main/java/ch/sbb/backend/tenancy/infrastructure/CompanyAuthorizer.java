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
        if (!(authentication instanceof JwtAuthenticationToken jwtAuth)) {
            return false;
        }

        URL issuer = jwtAuth.getToken().getIssuer();

        Tenant tenant = tenantRepository.getByIssuerUri(issuer.toString());
        if (tenant.companies() == null || tenant.companies().isEmpty()) {
            return false;
        }

        return tenant.companies().containsAll(companies);
    }
}

