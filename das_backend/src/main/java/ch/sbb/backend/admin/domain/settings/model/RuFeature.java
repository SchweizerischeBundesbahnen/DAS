package ch.sbb.backend.admin.domain.settings.model;

public record RuFeature(
    Company company,
    RuFeatureName name,
    boolean enabled
) {

}
