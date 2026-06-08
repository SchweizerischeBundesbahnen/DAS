package ch.sbb.das.backend.common;

import static org.assertj.core.api.Assertions.assertThat;

import java.time.LocalDate;
import org.junit.jupiter.api.Test;

class DateUtilTest {

    @Test
    void today_uses_swiss_zone() {
        LocalDate expected = LocalDate.now(DateUtil.SWISS_ZONE);
        assertThat(DateUtil.today()).isEqualTo(expected);
    }
}
