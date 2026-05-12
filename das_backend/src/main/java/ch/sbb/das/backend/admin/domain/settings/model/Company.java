package ch.sbb.das.backend.admin.domain.settings.model;

import ch.sbb.das.backend.common.CompanyCode;
import ch.sbb.das.backend.common.CompanyShortName;

public record Company(
    CompanyCode code,
    CompanyShortName shortName
) {

    public Company(String code, String shortName) {
        this(CompanyCode.of(code), CompanyShortName.of(shortName));
    }
}
