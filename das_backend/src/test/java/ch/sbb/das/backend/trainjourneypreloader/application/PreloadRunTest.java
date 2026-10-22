package ch.sbb.das.backend.trainjourneypreloader.application;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyMap;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.doThrow;
import static org.mockito.Mockito.inOrder;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import ch.sbb.das.backend.common.DateTimeUtil;
import ch.sbb.das.backend.companies.CompanyCode;
import ch.sbb.das.backend.trainjourneyplan.TrainIdentification;
import ch.sbb.das.backend.trainjourneypreloader.domain.PreloadResult;
import ch.sbb.das.backend.trainjourneypreloader.domain.SegmentProfileIdentification;
import ch.sbb.das.backend.trainjourneypreloader.sfera.model.v0400.JourneyProfile;
import ch.sbb.das.backend.trainjourneypreloader.sfera.model.v0400.SPZone;
import ch.sbb.das.backend.trainjourneypreloader.sfera.model.v0400.SegmentProfile;
import ch.sbb.das.backend.trainjourneypreloader.sfera.model.v0400.TrainCharacteristics;
import java.time.Clock;
import java.time.Duration;
import java.time.Instant;
import java.time.OffsetDateTime;
import java.util.ArrayList;
import java.util.Collection;
import java.util.List;
import java.util.Map;
import java.util.Set;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.ArgumentCaptor;
import org.mockito.Captor;
import org.mockito.InOrder;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

@ExtendWith(MockitoExtension.class)
class PreloadRunTest {

    private static final Duration MAX_DURATION = Duration.ofMinutes(4);
    private static final int HOURS_BEFORE_DEPARTURE = 4;

    @Mock
    private PreloadCandidates candidates;

    @Mock
    private JourneyFetch journeyFetch;

    @Mock
    private PreloadStore store;

    @Mock
    private Clock clock;

    @Captor
    private ArgumentCaptor<Collection<JourneyProfile>> journeyProfiles;

    @Captor
    private ArgumentCaptor<Collection<SegmentProfile>> segmentProfiles;

    @Captor
    private ArgumentCaptor<Collection<TrainCharacteristics>> trainCharacteristics;

    private Instant now = Instant.parse("2026-10-21T08:00:00Z");

    private PreloadRun underTest;

    @BeforeEach
    void setUp() {
        when(clock.instant()).thenAnswer(invocation -> now);
        when(clock.getZone()).thenReturn(DateTimeUtil.SWISS_ZONE);
        underTest = new PreloadRun(candidates, journeyFetch, store, clock, HOURS_BEFORE_DEPARTURE, MAX_DURATION);
    }

    @Test
    void run_whenCandidateSucceeds_savesAndMarksIt() {
        TrainIdentification train = train(1);
        JourneyProfile jp = new JourneyProfile();
        SegmentProfile sp = segmentProfile("SP_1");
        TrainCharacteristics tc = trainCharacteristics("TC_1");
        givenCandidates(train);
        when(journeyFetch.preload(eq(train), anyMap())).thenReturn(new PreloadResult.Success(jp, List.of(sp), List.of(tc)));

        PreloadRunReport report = underTest.run();

        verifySaved();
        assertThat(journeyProfiles.getValue()).containsExactly(jp);
        assertThat(segmentProfiles.getValue()).containsExactly(sp);
        assertThat(trainCharacteristics.getValue()).containsExactly(tc);
        verify(candidates).markPreloaded(Set.of(1));
        assertThat(report.requested()).isEqualTo(1);
        assertThat(report.succeeded()).isEqualTo(1);
        assertThat(report.stopReason()).isEqualTo(PreloadRunReport.StopReason.COMPLETED);
    }

    @Test
    void run_fetchesCandidatesOfTheDepartureWindowInSourceOrderWithinOneSession() {
        TrainIdentification third = train(3);
        TrainIdentification first = train(1);
        TrainIdentification second = train(2);
        when(candidates.between(OffsetDateTime.parse("2026-10-21T06:00:00+02:00"), OffsetDateTime.parse("2026-10-21T14:00:00+02:00")))
            .thenReturn(List.of(third, first, second));
        when(journeyFetch.preload(any(), anyMap())).thenReturn(new PreloadResult.Unavailable());

        underTest.run();

        InOrder inOrder = inOrder(journeyFetch, store, candidates);
        inOrder.verify(journeyFetch).connect();
        inOrder.verify(journeyFetch).preload(eq(third), anyMap());
        inOrder.verify(journeyFetch).preload(eq(first), anyMap());
        inOrder.verify(journeyFetch).preload(eq(second), anyMap());
        inOrder.verify(journeyFetch).disconnect();
        inOrder.verify(store).save(any(), any(), any());
        inOrder.verify(candidates).markPreloaded(Set.of());
    }

    @Test
    void run_whenTimeBudgetExceeded_stopsBetweenTrainsAndReportsSkipped() {
        TrainIdentification first = train(1);
        TrainIdentification second = train(2);
        TrainIdentification third = train(3);
        givenCandidates(first, second, third, train(4));
        givenFetchTakes(first, Duration.ofMinutes(3), new PreloadResult.Success(new JourneyProfile(), List.of(), List.of()));
        givenFetchTakes(second, Duration.ofMinutes(2), new PreloadResult.Unavailable());

        PreloadRunReport report = underTest.run();

        verify(journeyFetch, never()).preload(eq(third), anyMap());
        assertThat(report.processed()).isEqualTo(2);
        assertThat(report.skipped()).isEqualTo(2);
        assertThat(report.stopReason()).isEqualTo(PreloadRunReport.StopReason.TIME_BUDGET_EXCEEDED);
        assertThat(report.duration()).isEqualTo(Duration.ofMinutes(5));
        verify(store).save(any(), any(), any());
        verify(candidates).markPreloaded(Set.of(1));
    }

    @Test
    void run_whenTimeBudgetExactlyReached_processesNextTrain() {
        TrainIdentification first = train(1);
        TrainIdentification second = train(2);
        givenCandidates(first, second);
        givenFetchTakes(first, MAX_DURATION, new PreloadResult.Unavailable());
        when(journeyFetch.preload(eq(second), anyMap())).thenReturn(new PreloadResult.Unavailable());

        PreloadRunReport report = underTest.run();

        verify(journeyFetch).preload(eq(second), anyMap());
        assertThat(report.stopReason()).isEqualTo(PreloadRunReport.StopReason.COMPLETED);
    }

    @Test
    void run_whenInterrupted_stopsBeforeNextTrain() {
        TrainIdentification first = train(1);
        TrainIdentification second = train(2);
        givenCandidates(first, second);
        when(journeyFetch.preload(eq(first), anyMap())).thenAnswer(invocation -> {
            Thread.currentThread().interrupt();
            return new PreloadResult.Unavailable();
        });

        PreloadRunReport report;
        try {
            report = underTest.run();
        } finally {
            Thread.interrupted();
        }

        verify(journeyFetch, never()).preload(eq(second), anyMap());
        assertThat(report.stopReason()).isEqualTo(PreloadRunReport.StopReason.INTERRUPTED);
        assertThat(report.skipped()).isEqualTo(1);
        verify(store).save(any(), any(), any());
    }

    @Test
    void run_passesSegmentProfilesOfEarlierTrainsToLaterTrainsAndSavesSharedOnesOnce() {
        TrainIdentification first = train(1);
        TrainIdentification second = train(2);
        givenCandidates(first, second);
        SegmentProfile sharedSp = segmentProfile("SP_1");
        List<Set<SegmentProfileIdentification>> knownSegmentProfilesPerFetch = new ArrayList<>();
        when(journeyFetch.preload(any(), anyMap())).thenAnswer(invocation -> {
            Map<SegmentProfileIdentification, SegmentProfile> known = invocation.getArgument(1);
            knownSegmentProfilesPerFetch.add(Set.copyOf(known.keySet()));
            return invocation.getArgument(0).equals(first)
                ? new PreloadResult.Success(new JourneyProfile(), List.of(sharedSp), List.of(trainCharacteristics("TC_1")))
                : new PreloadResult.Success(new JourneyProfile(), List.of(segmentProfile("SP_2")), List.of(trainCharacteristics("TC_1")));
        });

        underTest.run();

        assertThat(knownSegmentProfilesPerFetch.get(0)).isEmpty();
        assertThat(knownSegmentProfilesPerFetch.get(1)).containsExactly(SegmentProfileIdentification.from(sharedSp));
        verifySaved();
        assertThat(segmentProfiles.getValue()).extracting(SegmentProfile::getSPID).containsExactlyInAnyOrder("SP_1", "SP_2");
        assertThat(trainCharacteristics.getValue()).extracting(TrainCharacteristics::getTCID).containsExactly("TC_1");
        assertThat(journeyProfiles.getValue()).hasSize(2);
    }

    @Test
    void run_marksOnlySuccessfulTrainsAndCountsEachOutcome() {
        TrainIdentification success = train(1);
        TrainIdentification unavailable = train(2);
        TrainIdentification error = train(3);
        TrainIdentification timeout = train(4);
        TrainIdentification secondError = train(5);
        givenCandidates(success, unavailable, error, timeout, secondError);
        givenFetchTakes(success, Duration.ofSeconds(1), new PreloadResult.Success(new JourneyProfile(), List.of(), List.of()));
        givenFetchTakes(unavailable, Duration.ofSeconds(1), new PreloadResult.Unavailable());
        givenFetchTakes(error, Duration.ofSeconds(1), new PreloadResult.Error("JP request G2B error: 51"));
        givenFetchTakes(timeout, Duration.ofSeconds(1), new PreloadResult.Timeout("Preload timed out", new RuntimeException()));
        givenFetchTakes(secondError, Duration.ofSeconds(1), new PreloadResult.Error("Handshake not acknowledged!"));

        PreloadRunReport report = underTest.run();

        verify(candidates).markPreloaded(Set.of(1));
        assertThat(report).isEqualTo(new PreloadRunReport(5, 5, 1, 1, 2, 1, 0, PreloadRunReport.StopReason.COMPLETED, Duration.ofSeconds(5)));
    }

    @Test
    void run_whenNoTrainSucceeds_stillSavesOnceWithNothing() {
        TrainIdentification train = train(1);
        givenCandidates(train);
        when(journeyFetch.preload(eq(train), anyMap())).thenReturn(new PreloadResult.Error("JP request G2B error: 51"));

        underTest.run();

        verifySaved();
        assertThat(journeyProfiles.getValue()).isEmpty();
        assertThat(segmentProfiles.getValue()).isEmpty();
        assertThat(trainCharacteristics.getValue()).isEmpty();
        verify(candidates).markPreloaded(Set.of());
    }

    @Test
    void run_whenNoCandidates_stillConnectsAndSavesOnce() {
        givenCandidates();

        PreloadRunReport report = underTest.run();

        verify(journeyFetch).connect();
        verify(store).save(any(), any(), any());
        assertThat(report.requested()).isZero();
    }

    @Test
    void run_whenConnectFails_abortsWithoutFetchingOrSaving() {
        givenCandidates(train(1));
        IllegalStateException failure = new IllegalStateException("MQTT connect failed");
        doThrow(failure).when(journeyFetch).connect();

        assertThatThrownBy(underTest::run).isSameAs(failure);

        verify(journeyFetch, never()).preload(any(), anyMap());
        verify(store, never()).save(any(), any(), any());
        verify(candidates, never()).markPreloaded(any());
    }

    @Test
    void run_whenFetchThrowsAfterEarlierSuccess_abortsWithoutSavingOrMarking() {
        TrainIdentification first = train(1);
        TrainIdentification second = train(2);
        TrainIdentification third = train(3);
        givenCandidates(first, second, third);
        when(journeyFetch.preload(eq(first), anyMap())).thenReturn(new PreloadResult.Success(new JourneyProfile(), List.of(), List.of()));
        IllegalStateException failure = new IllegalStateException("unexpected");
        when(journeyFetch.preload(eq(second), anyMap())).thenThrow(failure);

        assertThatThrownBy(underTest::run).isSameAs(failure);

        verify(journeyFetch, never()).preload(eq(third), anyMap());
        verify(journeyFetch, never()).disconnect();
        verify(store, never()).save(any(), any(), any());
        verify(candidates, never()).markPreloaded(any());
    }

    @Test
    void run_whenSaveFails_abortsWithoutMarkingAnyTrain() {
        TrainIdentification train = train(1);
        givenCandidates(train);
        when(journeyFetch.preload(eq(train), anyMap())).thenReturn(new PreloadResult.Success(new JourneyProfile(), List.of(), List.of()));
        RuntimeException failure = new RuntimeException("Preload save failed");
        doThrow(failure).when(store).save(any(), any(), any());

        assertThatThrownBy(underTest::run).isSameAs(failure);

        verify(candidates, never()).markPreloaded(any());
    }

    private void givenCandidates(TrainIdentification... trains) {
        when(candidates.between(any(), any())).thenReturn(List.of(trains));
    }

    private void givenFetchTakes(TrainIdentification train, Duration takes, PreloadResult result) {
        when(journeyFetch.preload(eq(train), anyMap())).thenAnswer(invocation -> {
            now = now.plus(takes);
            return result;
        });
    }

    private void verifySaved() {
        verify(store).save(journeyProfiles.capture(), segmentProfiles.capture(), trainCharacteristics.capture());
    }

    private static TrainIdentification train(int id) {
        return new TrainIdentification(id, "1000" + id, OffsetDateTime.parse("2026-10-21T10:00:00+02:00"), Set.of(new CompanyCode("1085")));
    }

    private static SegmentProfile segmentProfile(String spId) {
        SegmentProfile sp = new SegmentProfile();
        sp.setSPID(spId);
        sp.setSPVersionMajor("1");
        sp.setSPVersionMinor("0");
        SPZone zone = new SPZone();
        zone.setIMID("0085");
        sp.setSPZone(zone);
        return sp;
    }

    private static TrainCharacteristics trainCharacteristics(String tcId) {
        TrainCharacteristics tc = new TrainCharacteristics();
        tc.setTCID(tcId);
        tc.setTCVersionMajor("1");
        tc.setTCVersionMinor("0");
        tc.setTCRUID("1085");
        return tc;
    }
}
