package ch.sbb.das.backend.locations.internal;

import java.time.LocalDate;
import java.util.List;
import java.util.Set;

public record ServicePoint(
    String designationOfficial,
    String abbreviation,
    LocalDate validFrom,
    LocalDate validTo,
    ServicePointNumber number,
    String operatingPointTechnicalTimetableType,
    List<String> meansOfTransport
) {

    private static final Set<String> RELEVANT_TECHNICAL_TIMETABLE_TYPES = Set.of(
        "COUNTRY_BORDER",
        "BRANCH",
        "SERVICE_STATION",
        "EX_STOP_POINT"
    );

    private static final String TRAIN = "TRAIN";

    public Content content() {
        return new Content(designationOfficial, abbreviation, number);
    }

    public boolean isDirectlyFollowedBy(ServicePoint other) {
        return validTo != null
            && other.validFrom != null
            && other.validFrom.equals(validTo.plusDays(1));
    }

    public ServicePoint withValidTo(LocalDate newValidTo) {
        return new ServicePoint(designationOfficial, abbreviation, validFrom, newValidTo, number, operatingPointTechnicalTimetableType, meansOfTransport);
    }

    public boolean isRelevant() {
        return hasAbbreviation()
            && hasRelevantTechnicalTimetableType()
            && hasOnlyTrainMeansOfTransport();
    }

    private boolean hasAbbreviation() {
        return abbreviation != null && !abbreviation.isBlank();
    }

    private boolean hasRelevantTechnicalTimetableType() {
        return operatingPointTechnicalTimetableType == null
            || RELEVANT_TECHNICAL_TIMETABLE_TYPES.contains(operatingPointTechnicalTimetableType);
    }

    private boolean hasOnlyTrainMeansOfTransport() {
        return meansOfTransport == null
            || meansOfTransport.stream().allMatch(TRAIN::equals);
    }

    public record ServicePointNumber(Integer uicCountryCode, Integer numberShort, Integer checkDigit) {

    }

    public record Content(String designationOfficial, String abbreviation, ServicePointNumber number) {

    }

}
