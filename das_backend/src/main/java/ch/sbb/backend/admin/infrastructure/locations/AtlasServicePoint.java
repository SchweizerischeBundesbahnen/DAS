package ch.sbb.backend.admin.infrastructure.locations;

import java.time.LocalDate;

public record AtlasServicePoint(
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
