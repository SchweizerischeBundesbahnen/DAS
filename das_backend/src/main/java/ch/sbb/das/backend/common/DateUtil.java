package ch.sbb.das.backend.common;

import java.time.LocalDate;
import java.time.OffsetDateTime;
import java.time.ZoneId;
import java.time.ZonedDateTime;
import lombok.experimental.UtilityClass;

@UtilityClass
public class DateUtil {

    public static final ZoneId SWISS_ZONE = ZoneId.of("Europe/Zurich");

    public static LocalDate today() {
        return LocalDate.now(SWISS_ZONE);
    }

    /**
     * See <a href="https://confluence.sbb.ch/x/DcxSww">Umrechnen von Planzeiten</a>
     */
    public OffsetDateTime convertDateTime(LocalDate localDate, Integer secondsToAdd) {
        if (secondsToAdd == null) {
            return null;
        }
        ZonedDateTime dateTime = ZonedDateTime.of(localDate.getYear(), localDate.getMonth().getValue(), localDate.getDayOfMonth(), 0, 0, 0, 0, SWISS_ZONE);
        long offsetT0 = dateTime.getOffset().getTotalSeconds();
        dateTime = dateTime.plusSeconds(secondsToAdd);
        long offsetT1 = dateTime.getOffset().getTotalSeconds();
        dateTime = dateTime.plusSeconds(offsetT0 - offsetT1);
        return dateTime.toOffsetDateTime();
    }

}
