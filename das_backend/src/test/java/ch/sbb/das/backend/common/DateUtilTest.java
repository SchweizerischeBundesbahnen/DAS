package ch.sbb.das.backend.common;

import static org.assertj.core.api.Assertions.assertThat;

import java.time.LocalDate;
import java.time.OffsetDateTime;
import java.time.ZoneOffset;
import org.junit.jupiter.api.Test;

class DateUtilTest {

    @Test
    void today_uses_swiss_zone() {
        LocalDate expected = LocalDate.now(DateUtil.SWISS_ZONE);
        assertThat(DateUtil.today()).isEqualTo(expected);
    }

    @Test
    void convertDateTime_returns_null_for_null_seconds() {
        OffsetDateTime result = DateUtil.convertDateTime(LocalDate.of(2026, 1, 1), null);
        assertThat(result).isNull();
    }

    @Test
    void convertDateTime_normal_day_add_one_hour() {
        LocalDate date = LocalDate.of(2026, 1, 1);
        OffsetDateTime result = DateUtil.convertDateTime(date, 3600);
        assertThat(result).isNotNull();
        assertThat(result.toLocalDate()).isEqualTo(date);
        assertThat(result.getHour()).isEqualTo(1);
        assertThat(result.getOffset()).isEqualTo(ZoneOffset.ofHours(1));
    }
}
