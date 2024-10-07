package ch.sbb.sferamock.exchange;

import ch.sbb.sferamock.exchange.TenantConfig.Tenant;
import com.nimbusds.jose.JWSHeader;
import com.nimbusds.jose.KeySourceException;
import com.nimbusds.jose.proc.JWSAlgorithmFamilyJWSKeySelector;
import com.nimbusds.jose.proc.JWSKeySelector;
import com.nimbusds.jose.proc.SecurityContext;
import com.nimbusds.jwt.JWTClaimsSet;
import com.nimbusds.jwt.proc.JWTClaimsSetAwareJWSKeySelector;
import java.net.URL;
import java.security.Key;
import java.util.List;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;
import org.springframework.security.oauth2.jwt.JwtClaimNames;
import org.springframework.stereotype.Component;

/**
 * This class (which is used by the bean jwtProcessor, see SecurityConfig.java) provides the functionality to choose which key selector to use based on the iss claim in the JWT. It uses a cache for
 * JWKKeySelectors, keyed by tenant identifier. Looking up the tenant is more secure than simply calculating the JWK Set endpoint on the fly - the lookup acts as a list of allowed tenants.
 * <p>
 * For a more detailed description see <a href="https://docs.spring.io/spring-security/reference/servlet/oauth2/resource-server/multitenancy.html#_parsing_the_claim_only_once">Spring Security
 * Documentation</a>.
 */
@Component
public class TenantJwsKeySelector implements JWTClaimsSetAwareJWSKeySelector<SecurityContext> {

    private final TenantService tenantService;
    private final Map<String, JWSKeySelector<SecurityContext>> selectors = new ConcurrentHashMap<>();

    public TenantJwsKeySelector(TenantService tenantService) {
        this.tenantService = tenantService;
    }

    @Override
    public List<? extends Key> selectKeys(JWSHeader jwsHeader, JWTClaimsSet jwtClaimsSet, SecurityContext securityContext)
        throws KeySourceException {
        return this.selectors.computeIfAbsent(toTenant(jwtClaimsSet), this::fromTenant)
            .selectJWSKeys(jwsHeader, securityContext);
    }

    private String toTenant(JWTClaimsSet claimSet) {
        return (String) claimSet.getClaim(JwtClaimNames.ISS);
    }

    private JWSKeySelector<SecurityContext> fromTenant(String issuerUri) {
        final Tenant tenant = tenantService.getByIssuerUri(issuerUri);
        return fromUri(tenant.getJwkSetUri());
    }

    private JWSKeySelector<SecurityContext> fromUri(String uri) {
        try {
            return JWSAlgorithmFamilyJWSKeySelector.fromJWKSetURL(new URL(uri));
        } catch (Exception ex) {
            throw new IllegalArgumentException(ex);
        }
    }
}
