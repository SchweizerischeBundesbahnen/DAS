package ch.sbb.sferamock.messages.services;

import ch.sbb.sferamock.adapters.sfera.model.v0400.NetworkSpecificParameter;
import ch.sbb.sferamock.messages.model.localregulations.Version;
import java.time.OffsetDateTime;
import java.time.format.DateTimeFormatter;
import java.util.Comparator;
import java.util.List;
import java.util.Optional;

final class LocalRegulationNspFactory {

    static final String LR_PREFIX = "LR_";
    static final String NSP_GROUP_NAME = "localRegulations";
    private static final DateTimeFormatter ISO_DATE = DateTimeFormatter.ofPattern("yyyy-MM-dd");

    private LocalRegulationNspFactory() {
    }

    static NetworkSpecificParameter createNsp(String name, String value) {
        NetworkSpecificParameter nsp = new NetworkSpecificParameter();
        nsp.setName(name);
        nsp.setValue(value);
        return nsp;
    }

    static String getLocalizedValue(String de, String fr, String it, String lang) {
        return switch (lang) {
            case "DE" -> de;
            case "FR" -> fr;
            case "IT" -> it;
            default -> de;
        };
    }

    static String formatDate(String isoDateTimeString) {
        try {
            OffsetDateTime odt = OffsetDateTime.parse(isoDateTimeString);
            return odt.format(ISO_DATE);
        } catch (Exception _) {
            // Try as plain date
            try {
                return isoDateTimeString.substring(0, 10);
            } catch (Exception _) {
                return null;
            }
        }
    }

    static Optional<Version> selectInForceVersion(List<Version> versions) {
        if (versions.isEmpty()) {
            return Optional.empty();
        }

        OffsetDateTime now = OffsetDateTime.now();

        return versions.stream()
            .filter(v -> isInForce(v, now))
            .max(Comparator.comparing(v -> parseDate(v.inForceFrom()).orElse(OffsetDateTime.MIN)))
            .or(() -> versions.stream()
                .max(Comparator.comparing(v -> parseDate(v.inForceFrom()).orElse(OffsetDateTime.MIN))))
            .or(() -> Optional.of(versions.getFirst()));
    }

    private static boolean isInForce(Version version, OffsetDateTime now) {
        boolean startedInPast = parseDate(version.inForceFrom())
            .map(from -> !from.isAfter(now))
            .orElse(false);
        boolean notYetEnded = parseDate(version.inForceTo())
            .map(to -> to.isAfter(now))
            .orElse(true);
        return startedInPast && notYetEnded;
    }

    private static Optional<OffsetDateTime> parseDate(String isoDateTimeString) {
        if (isoDateTimeString == null || isoDateTimeString.isBlank()) {
            return Optional.empty();
        }
        try {
            return Optional.of(OffsetDateTime.parse(isoDateTimeString));
        } catch (Exception _) {
            return Optional.empty();
        }
    }
}
