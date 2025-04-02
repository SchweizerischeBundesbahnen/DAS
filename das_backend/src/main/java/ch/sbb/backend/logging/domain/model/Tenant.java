package ch.sbb.backend.logging.domain.model;

public record Tenant(
    String name,
    String id,
    String jwkSetUri,
    String issuerUri,
    LogTarget logTarget
) {

}