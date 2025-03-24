package ch.sbb.backend.logging.domain;

public record Tenant(
    String name,
    String id,
    String jwkSetUri,
    String issuerUri,
    LogDestination logDestination
) {

}