package ch.sbb.das.backend.common;

import java.time.LocalDate;
import java.time.ZoneId;
import lombok.experimental.UtilityClass;

@UtilityClass
public class DateUtil {

    public static final ZoneId SWISS_ZONE = ZoneId.of("Europe/Zurich");

    public static LocalDate today() {
        return LocalDate.now(SWISS_ZONE);
    }
}
