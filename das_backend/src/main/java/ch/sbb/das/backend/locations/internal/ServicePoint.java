package ch.sbb.das.backend.locations.internal;

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
