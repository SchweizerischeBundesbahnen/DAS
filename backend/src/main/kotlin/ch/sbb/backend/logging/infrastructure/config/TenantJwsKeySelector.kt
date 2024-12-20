package ch.sbb.backend.logging.infrastructure.config

import ch.sbb.backend.logging.domain.Tenant
import ch.sbb.backend.logging.domain.repository.TenantRepository
import com.nimbusds.jose.JWSHeader
import com.nimbusds.jose.proc.JWSAlgorithmFamilyJWSKeySelector
import com.nimbusds.jose.proc.JWSKeySelector
import com.nimbusds.jose.proc.SecurityContext
import com.nimbusds.jwt.JWTClaimsSet
import com.nimbusds.jwt.proc.JWTClaimsSetAwareJWSKeySelector
import org.springframework.stereotype.Component
import java.net.URI
import java.security.Key
import java.util.concurrent.ConcurrentHashMap

/**
 * This class (which is used by the bean jwtProcessor, see SecurityConfig.java) provides the functionality to choose which key selector to use based on the iss claim in the JWT. It uses a cache for
 * JWKKeySelectors, keyed by tenant identifier. Looking up the tenant is more secure than simply calculating the JWK Set endpoint on the fly - the lookup acts as a list of allowed tenants.
 *
 * For a more detailed description see [Spring Security Documentation](https://docs.spring.io/spring-security/reference/servlet/oauth2/resource-server/multitenancy.html#_parsing_the_claim_only_once).
 */
@Component
class TenantJWSKeySelector(private val tenantRepository: TenantRepository) :
    JWTClaimsSetAwareJWSKeySelector<SecurityContext> {

    private val selectors: MutableMap<String, JWSKeySelector<SecurityContext>> = ConcurrentHashMap()

    override fun selectKeys(jwsHeader: JWSHeader?, jwtClaimsSet: JWTClaimsSet, securityContext: SecurityContext?): List<Key?> {
        return selectors.computeIfAbsent(toTenant(jwtClaimsSet)) { tenant: String -> fromTenant(tenant) }
            .selectJWSKeys(jwsHeader, securityContext)
    }

    private fun toTenant(claimSet: JWTClaimsSet): String {
        return claimSet.getClaim("iss") as String
    }

    private fun fromTenant(issuerUri: String): JWSKeySelector<SecurityContext> {
        val tenant: Tenant = tenantRepository.getByIssuerUri(issuerUri)
        return fromUri(tenant.jwkSetUri)
    }

    private fun fromUri(uri: String): JWSKeySelector<SecurityContext> {
        return try {
            JWSAlgorithmFamilyJWSKeySelector.fromJWKSetURL(URI(uri).toURL())
        } catch (ex: Exception) {
            throw IllegalArgumentException(ex)
        }
    }
}
