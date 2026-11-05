package ch.sbb.das.backend.trainjourneypreloader.infrastructure;

import static org.assertj.core.api.Assertions.assertThat;

import ch.sbb.das.backend.IntegrationTest;
import ch.sbb.das.backend.trainjourneyplan.TrainIdentification;
import ch.sbb.das.backend.trainjourneypreloader.application.PreloadCandidates;
import ch.sbb.das.backend.trainjourneypreloader.domain.PreloadAttempt;
import ch.sbb.das.backend.trainjourneypreloader.domain.PreloadOutcome;
import java.time.OffsetDateTime;
import java.time.temporal.ChronoUnit;
import java.util.List;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.JdbcTemplate;

@IntegrationTest
class TrainPreloadLedgerIntegrationTest {

    @Autowired
    private PreloadCandidates underTest;

    @Autowired
    private JdbcTemplate jdbcTemplate;

    private OffsetDateTime now;

    @BeforeEach
    void setUp() {
        jdbcTemplate.update("DELETE FROM train_identification");
        now = OffsetDateTime.now().truncatedTo(ChronoUnit.SECONDS);
    }

    @DisplayName("between_returnsUpcomingTrainsSoonestFirstThenDepartedTrainsMostRecentFirst|8hTe7uvIu435y2MmjImN|tests:2660")
    @Test
    void between_returnsUpcomingTrainsSoonestFirstThenDepartedTrainsMostRecentFirst() {
        givenTrain(1, now.minusHours(3));
        givenTrain(2, now.plusHours(2));
        givenTrain(3, now.minusHours(1));
        givenTrain(4, now.plusHours(1));

        PreloadCandidates.Selection selection = between();

        assertThat(selection.trains()).extracting(TrainIdentification::id).containsExactly(4, 2, 3, 1);
        assertThat(selection.deferred()).isZero();
    }

    @DisplayName("between_leavesOutTrainsOutsideTheWindowAndWithoutSupportedCompany|yIVyvMvTuLbJur51zA2L|tests:2660")
    @Test
    void between_leavesOutTrainsOutsideTheWindowAndWithoutSupportedCompany() {
        givenTrain(1, now.plusHours(1));
        givenTrain(2, now.plusHours(5));
        givenTrain(3, now.plusHours(1), "NOT_IN_DB");

        assertThat(between().trains()).extracting(TrainIdentification::id).containsExactly(1);
    }

    @DisplayName("between_leavesOutPreloadedTrainsEvenAfterTheirBackoffWouldHaveExpired|sAniLzH7QrgqGXxoU9rp|tests:2660")
    @Test
    void between_leavesOutPreloadedTrainsEvenAfterTheirBackoffWouldHaveExpired() {
        givenTrain(1, now.plusHours(1));
        givenTrain(2, now.plusHours(2));

        underTest.recordAttempts(now.minusHours(2), List.of(attempt(1, PreloadOutcome.SUCCESS, null)));

        PreloadCandidates.Selection selection = between();
        assertThat(selection.trains()).extracting(TrainIdentification::id).containsExactly(2);
        assertThat(selection.deferred()).isZero();
    }

    @DisplayName("between_defersFailedTrainsUntilTheirBackoffExpired|ZG0IkbhRJd2Ptl3pqmmN|tests:2660")
    @Test
    void between_defersFailedTrainsUntilTheirBackoffExpired() {
        givenTrain(1, now.plusHours(1));
        givenTrain(2, now.plusHours(2));
        givenTrain(3, now.plusHours(3));

        underTest.recordAttempts(now.minusMinutes(1), List.of(attempt(1, PreloadOutcome.ERROR, "51")));
        underTest.recordAttempts(now.minusMinutes(5), List.of(attempt(2, PreloadOutcome.TIMEOUT, null)));

        PreloadCandidates.Selection selection = between();
        assertThat(selection.trains()).extracting(TrainIdentification::id).containsExactly(2, 3);
        assertThat(selection.deferred()).isEqualTo(1);
    }

    @DisplayName("recordAttempts_countsRepeatedFailuresSoTheBackoffGrows|eRYQTf45h24xQnPBExdZ|tests:2660")
    @Test
    void recordAttempts_countsRepeatedFailuresSoTheBackoffGrows() {
        givenTrain(1, now.plusHours(1));
        givenTrain(2, now.plusHours(2));

        underTest.recordAttempts(now.minusHours(1), List.of(attempt(1, PreloadOutcome.ERROR, "51")));
        underTest.recordAttempts(now.minusMinutes(6), List.of(attempt(1, PreloadOutcome.ERROR, "51"), attempt(2, PreloadOutcome.ERROR, "51")));

        PreloadCandidates.Selection selection = between();
        assertThat(selection.trains()).extracting(TrainIdentification::id).containsExactly(2);
        assertThat(selection.deferred()).isEqualTo(1);
    }

    @DisplayName("recordAttempts_whenFailedTrainSucceedsLater_isNoLongerACandidate|4lbllsVAp6mNd8P8QzPE|tests:2660")
    @Test
    void recordAttempts_whenFailedTrainSucceedsLater_isNoLongerACandidate() {
        givenTrain(1, now.plusHours(1));

        underTest.recordAttempts(now.minusHours(1), List.of(attempt(1, PreloadOutcome.ERROR, "51")));
        underTest.recordAttempts(now.minusMinutes(30), List.of(attempt(1, PreloadOutcome.SUCCESS, null)));

        PreloadCandidates.Selection selection = between();
        assertThat(selection.trains()).isEmpty();
        assertThat(selection.deferred()).isZero();
    }

    @DisplayName("ledger_whenTrainIdentificationIsDeleted_forgetsItsHistory|wK6HVp9OZQpwJHEXNO1U|tests:2660")
    @Test
    void ledger_whenTrainIdentificationIsDeleted_forgetsItsHistory() {
        givenTrain(1, now.plusHours(1));
        underTest.recordAttempts(now.minusMinutes(1), List.of(attempt(1, PreloadOutcome.SUCCESS, null)));

        jdbcTemplate.update("DELETE FROM train_identification WHERE id = 1");
        givenTrain(1, now.plusHours(1));

        assertThat(between().trains()).extracting(TrainIdentification::id).containsExactly(1);
    }

    private PreloadCandidates.Selection between() {
        return underTest.between(now.minusHours(4), now.plusHours(4));
    }

    private void givenTrain(int id, OffsetDateTime startDateTime) {
        givenTrain(id, startDateTime, "MOCK_A");
    }

    private void givenTrain(int id, OffsetDateTime startDateTime, String companies) {
        jdbcTemplate.update("""
                INSERT INTO train_identification (id, train_path_id, period, operational_train_number, start_date_time, companies, operational_day)
                VALUES (?, ?, 2026, ?, ?, ?, ?)
                """,
            id, "path-" + id, "100" + id, startDateTime, companies, startDateTime.toLocalDate());
    }

    private static PreloadAttempt attempt(int trainIdentificationId, PreloadOutcome outcome, String g2bCode) {
        return new PreloadAttempt(trainIdentificationId, outcome, g2bCode);
    }
}
