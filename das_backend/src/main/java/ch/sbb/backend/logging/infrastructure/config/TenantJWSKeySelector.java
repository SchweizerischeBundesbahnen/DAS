package ch.sbb.backend.logging.infrastructure.config;

import ch.sbb.backend.logging.domain.Tenant;
import ch.sbb.backend.logging.domain.repository.TenantRepository;
import com.nimbusds.jose.JWSHeader;
import com.nimbusds.jose.KeySourceException;
import com.nimbusds.jose.proc.JWSAlgorithmFamilyJWSKeySelector;
import com.nimbusds.jose.proc.JWSKeySelector;
import com.nimbusds.jose.proc.SecurityContext;
import com.nimbusds.jwt.JWTClaimsSet;
import com.nimbusds.jwt.proc.JWTClaimsSetAwareJWSKeySelector;
import java.net.URI;
import java.security.Key;
import java.util.List;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;
import org.springframework.stereotype.Component;

/**
 * This class (which is used by the bean jwtProcessor, see SecurityConfig.java) provides the functionality to choose which key selector to use based on the iss claim in the JWT. It uses a cache for
 * JWKKeySelectors, keyed by tenant identifier. Looking up the tenant is more secure than simply calculating the JWK Set endpoint on the fly - the lookup acts as a list of allowed tenants.
 * <p>
 * For a more detailed description see [Spring Security Documentation](https://docs.spring.io/spring-security/reference/servlet/oauth2/resource-server/multitenancy.html#_parsing_the_claim_only_once).
 */
@Component
public class TenantJWSKeySelector implements JWTClaimsSetAwareJWSKeySelector<SecurityContext> {

    private final TenantRepository tenantRepository;
    private final Map<String, JWSKeySelector<SecurityContext>> selectors = new ConcurrentHashMap<>();

    public TenantJWSKeySelector(TenantRepository tenantRepository) {
        this.tenantRepository = tenantRepository;
    }

    @Override
    public List<? extends Key> selectKeys(JWSHeader jwsHeader, JWTClaimsSet jwtClaimsSet, SecurityContext securityContext) throws KeySourceException {
        return selectors.computeIfAbsent(toTenant(jwtClaimsSet), this::fromTenant)
            .selectJWSKeys(jwsHeader, securityContext);
    }

    private String toTenant(JWTClaimsSet claimSet) {
        return (String) claimSet.getClaim("iss");
    }

    private JWSKeySelector<SecurityContext> fromTenant(String issuerUri) {
        Tenant tenant = tenantRepository.getByIssuerUri(issuerUri);
        return fromUri(tenant.jwkSetUri());
    }

    private JWSKeySelector<SecurityContext> fromUri(String uri) {
        try {
            return JWSAlgorithmFamilyJWSKeySelector.fromJWKSetURL(URI.create(uri).toURL());
        } catch (Exception ex) {
            throw new IllegalArgumentException(ex);
        }
    }
}

