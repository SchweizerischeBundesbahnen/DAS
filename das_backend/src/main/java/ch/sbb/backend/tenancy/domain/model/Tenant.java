package ch.sbb.backend.tenancy.domain.model;

public record Tenant(
    String name,
    String id,
    String jwkSetUri,
    String issuerUri
) {

}