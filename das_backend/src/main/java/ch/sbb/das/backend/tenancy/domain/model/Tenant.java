package ch.sbb.das.backend.tenancy.domain.model;

import ch.sbb.das.backend.common.CompanyCode;
import java.util.Set;

/**
 * Microsoft Entra ID tenant of an organisation registered for user authentication (see {@link org.springframework.boot.security.oauth2.server.resource.autoconfigure.OAuth2ResourceServerProperties})
 *
 * @param name Display name
 * @param companies Concrete railway undertakings (RU) managed by this organisation given as RICS codes.
 */
public record Tenant(
    String name,
    String issuerUri,
    String jwkSetUri,
    Set<CompanyCode> companies
) {

    public String getId() {
        final int index = issuerUri.indexOf("/", 8);
        return issuerUri.substring(index + 1, issuerUri.indexOf("/", index + 1));
    }
}
