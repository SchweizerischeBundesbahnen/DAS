package ch.sbb.das.backend.common;

import static org.assertj.core.api.Assertions.assertThat;

import org.junit.jupiter.api.Test;

class RequestIdFilterTest {

    /**
     * Shape sent by das_e2e_testsuite for a parameterized test: brackets, spaces and commas must pass unchanged.
     */
    private static final String E2E_REQUEST_ID = "e2eTest_getById[1] 1, de";

    @Test
    void sanitize_nullOrBlank_returnsNull() {
        assertThat(RequestIdFilter.sanitize(null)).isNull();
        assertThat(RequestIdFilter.sanitize(" ")).isNull();
    }

    @Test
    void sanitize_paddedPrintableAscii_returnsStripped() {
        assertThat(RequestIdFilter.sanitize(" " + E2E_REQUEST_ID + " ")).isEqualTo(E2E_REQUEST_ID);
    }

    @Test
    void sanitize_exceedsMaxLength_returnsTruncatedPrefix() {
        // Given
        final String tooLong = "x".repeat(RequestIdFilter.MAX_LENGTH + 10);

        // When
        final String sanitized = RequestIdFilter.sanitize(tooLong);

        // Then
        assertThat(sanitized).isEqualTo(tooLong.substring(0, RequestIdFilter.MAX_LENGTH));
    }

    @Test
    void sanitize_controlOrNonAsciiChars_returnsNull() {
        assertThat(RequestIdFilter.sanitize("id\tinjected")).isNull();
        assertThat(RequestIdFilter.sanitize("id\ninjected")).isNull();
        assertThat(RequestIdFilter.sanitize("Zürich")).isNull();
    }
}
