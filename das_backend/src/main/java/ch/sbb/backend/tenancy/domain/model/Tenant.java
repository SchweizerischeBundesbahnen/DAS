package ch.sbb.backend.tenancy.domain.model;

import java.util.Set;

public record Tenant(
    // Name of related Railway Undertaking (RU) instance responsible for User-Mgmt Authentication.
    String name,
    String issuerUri,
    String jwkSetUri,
    Set<String> companies
) {

    public String getId() {
        final int index = issuerUri.indexOf("/", 8);
        return issuerUri.substring(index + 1, issuerUri.indexOf("/", index + 1));
    }
}
