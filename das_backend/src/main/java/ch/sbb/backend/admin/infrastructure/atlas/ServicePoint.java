package ch.sbb.backend.admin.infrastructure.atlas;

import java.time.LocalDate;

public record ServicePoint(
    String designationOfficial,
    String abbreviation,
    LocalDate validFrom,
    LocalDate validTo,
    ServicePointNumber number
) {

    public record ServicePointNumber(
        Integer numberShort,
        Integer uicCountryCode
    ) {

    }
}
