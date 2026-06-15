package ch.sbb.das.backend.admin.domain.settings.model;

import ch.sbb.das.backend.companies.Company;

public record RuFeature(
    Company company,
    RuFeatureKey key,
    boolean enabled
) {

}
