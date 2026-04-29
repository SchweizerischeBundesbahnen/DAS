package ch.sbb.das.backend.admin.domain.settings.model;

public record RuFeature(
    Company company,
    RuFeatureKey key,
    boolean enabled
) {

}
