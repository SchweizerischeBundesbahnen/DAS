package ch.sbb.das.backend.companies;

import java.util.Set;

/**
 * Microsoft Entra ID tenant of an organisation registered for user authentication (see {@link org.springframework.boot.security.oauth2.server.resource.autoconfigure.OAuth2ResourceServerProperties})
 *
 * @param name Display name
 * @param tenantId The Entra tenant ID
 * @param isAdmin Whether this is the admin tenant
 * @param companies Concrete railway undertakings (RU) managed by this organisation given as RICS codes.
 */
public record Tenant(
    String name,
    String tenantId,
    boolean isAdmin,
    Set<CompanyCode> companies
) {

    public static final String ENTRA_BASE_URL = "https://login.microsoftonline.com/";

    public String getId() {
        return tenantId;
    }

    public String jwkSetUri() {
        return ENTRA_BASE_URL + tenantId + "/discovery/v2.0/keys";
    }
}
