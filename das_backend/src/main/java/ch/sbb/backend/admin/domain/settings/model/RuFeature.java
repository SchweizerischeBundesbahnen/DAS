package ch.sbb.backend.admin.domain.settings.model;

public record RuFeature(
    Company company,
    RuFeatureKey key,
    boolean enabled
) {

}
