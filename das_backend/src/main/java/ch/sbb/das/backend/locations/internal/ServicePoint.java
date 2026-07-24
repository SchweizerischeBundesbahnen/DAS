package ch.sbb.das.backend.locations.internal;

import java.time.LocalDate;

public record ServicePoint(
    String designationOfficial,
    String abbreviation,
    LocalDate validFrom,
    LocalDate validTo,
    ServicePointNumber number
) {

    public Content content() {
        return new Content(designationOfficial, abbreviation, number);
    }

    public boolean isDirectlyFollowedBy(ServicePoint other) {
        return validTo != null
            && other.validFrom != null
            && other.validFrom.equals(validTo.plusDays(1));
    }

    public ServicePoint withValidTo(LocalDate newValidTo) {
        return new ServicePoint(designationOfficial, abbreviation, validFrom, newValidTo, number);
    }

    public record ServicePointNumber(Integer numberShort, Integer uicCountryCode) {

    }

    public record Content(String designationOfficial, String abbreviation, ServicePointNumber number) {

    }

}
