package ch.sbb.backend.preload.application.converter;

import java.time.LocalDate;
import java.time.OffsetDateTime;
import java.time.ZoneId;
import java.time.ZonedDateTime;
import lombok.experimental.UtilityClass;

/**
 * See <a href="https://confluence.sbb.ch/spaces/TAS/pages/3276983309/Umrechnen+vom+Planzeiten">Umrechnen von Planzeiten</a>
 */
@UtilityClass
public class TimeConverter {

    public static final ZoneId CET = ZoneId.of("CET");

    public OffsetDateTime convertTime(LocalDate localDate, Integer secondsToAdd) {
        if (secondsToAdd == null) {
            return null;
        }
        ZonedDateTime dateTime = ZonedDateTime.of(localDate.getYear(), localDate.getMonth().getValue(), localDate.getDayOfMonth(), 0, 0, 0, 0, CET);
        long offsetT0 = dateTime.getOffset().getTotalSeconds();
        dateTime = dateTime.plusSeconds(secondsToAdd);
        long offsetT1 = dateTime.getOffset().getTotalSeconds();
        dateTime = dateTime.plusSeconds(offsetT0 - offsetT1);
        return dateTime.toOffsetDateTime();
    }

}
