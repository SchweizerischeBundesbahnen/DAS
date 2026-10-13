package ch.sbb.das.backend.common;

import static org.assertj.core.api.Assertions.assertThat;

import org.junit.jupiter.api.Test;

class RequestIdFilterTest {

    private static final String REQUEST_ID = "shouldEcho[1] requestId=4711, rail";

    @Test
    void sanitize_absentOrBlank_null() {
        assertThat(RequestIdFilter.sanitize(null)).isNull();
        assertThat(RequestIdFilter.sanitize(" ")).isNull();
    }

    @Test
    void sanitize_printableAscii_keptTrimmed() {
        assertThat(RequestIdFilter.sanitize(" " + REQUEST_ID + " ")).isEqualTo(REQUEST_ID);
    }

    @Test
    void sanitize_tooLong_truncatedPrefix() {
        final String tooLong = "x".repeat(RequestIdFilter.MAX_LENGTH + 10);

        assertThat(RequestIdFilter.sanitize(tooLong)).isEqualTo(tooLong.substring(0, RequestIdFilter.MAX_LENGTH));
    }

    @Test
    void sanitize_nonPrintable_null() {
        assertThat(RequestIdFilter.sanitize("id\tinjected")).isNull();
        assertThat(RequestIdFilter.sanitize("id\ninjected")).isNull();
        assertThat(RequestIdFilter.sanitize("Zürich")).isNull();
    }
}
