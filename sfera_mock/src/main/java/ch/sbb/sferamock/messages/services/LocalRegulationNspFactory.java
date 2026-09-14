package ch.sbb.sferamock.messages.services;

import ch.sbb.sferamock.adapters.sfera.model.v0400.NetworkSpecificParameter;
import java.time.OffsetDateTime;
import java.time.format.DateTimeFormatter;

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
}
