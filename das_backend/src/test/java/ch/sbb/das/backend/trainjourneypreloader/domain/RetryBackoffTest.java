package ch.sbb.das.backend.trainjourneypreloader.domain;

import static org.assertj.core.api.Assertions.assertThat;

import java.time.Duration;
import java.time.OffsetDateTime;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.params.ParameterizedTest;
import org.junit.jupiter.params.provider.CsvSource;

class RetryBackoffTest {

    private static final OffsetDateTime LAST_ATTEMPT = OffsetDateTime.parse("2026-11-05T08:00:00+01:00");

    private final RetryBackoff underTest = new RetryBackoff(Duration.ofMinutes(5), Duration.ofHours(1));

    @ParameterizedTest
    @CsvSource({
        "1, 5",
        "2, 10",
        "3, 20",
        "4, 40",
        "5, 60",
        "6, 60",
        "96, 60"
    })
    void isDue_afterFailedAttempts_waitsDoublingUpToTheMax(int attempts, int waitMinutes) {
        PreloadLedgerEntry entry = failed(attempts);

        assertThat(underTest.isDue(entry, LAST_ATTEMPT.plusMinutes(waitMinutes))).isTrue();
        assertThat(underTest.isDue(entry, LAST_ATTEMPT.plusMinutes(waitMinutes).minusMinutes(1))).isFalse();
    }

    @Test
    void isDue_whenNextRunStartsSlightlyEarlierThanOneBaseInterval_isDue() {
        PreloadLedgerEntry entry = failed(1);

        assertThat(underTest.isDue(entry, LAST_ATTEMPT.plusMinutes(5).minusNanos(20_000_000))).isTrue();
    }

    @Test
    void isDue_whenNeverAttempted_isDue() {
        assertThat(underTest.isDue(PreloadLedgerEntry.NEVER_ATTEMPTED, LAST_ATTEMPT)).isTrue();
    }

    private static PreloadLedgerEntry failed(int attempts) {
        return new PreloadLedgerEntry(attempts, LAST_ATTEMPT, null);
    }
}
