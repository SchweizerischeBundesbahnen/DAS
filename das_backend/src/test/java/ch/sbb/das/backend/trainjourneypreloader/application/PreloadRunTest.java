package ch.sbb.das.backend.trainjourneypreloader.application;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

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
import java.time.ZoneId;
import java.util.ArrayList;
import java.util.Collection;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;
import org.junit.jupiter.api.Test;

class PreloadRunTest {

    private static final Duration MAX_DURATION = Duration.ofMinutes(4);
    private static final int HOURS_BEFORE_DEPARTURE = 4;

    private final MutableClock clock = new MutableClock(Instant.parse("2026-10-21T08:00:00Z"), DateTimeUtil.SWISS_ZONE);
    private final FakeCandidates candidates = new FakeCandidates();
    private final FakeJourneyFetch journeyFetch = new FakeJourneyFetch(clock);
    private final FakeStore store = new FakeStore();

    private final PreloadRun underTest = new PreloadRun(candidates, journeyFetch, store, clock, HOURS_BEFORE_DEPARTURE, MAX_DURATION);

    @Test
    void run_whenCandidateSucceeds_savesAndMarksIt() {
        TrainIdentification train = train(1);
        JourneyProfile jp = new JourneyProfile();
        SegmentProfile sp = segmentProfile("SP_1");
        TrainCharacteristics tc = trainCharacteristics("TC_1");
        candidates.add(train);
        journeyFetch.reply(train, new PreloadResult.Success(jp, List.of(sp), List.of(tc)));

        PreloadRunReport report = underTest.run();

        assertThat(store.journeyProfiles).containsExactly(jp);
        assertThat(store.segmentProfiles).containsExactly(sp);
        assertThat(store.trainCharacteristics).containsExactly(tc);
        assertThat(candidates.marked).containsExactly(1);
        assertThat(report.requested()).isEqualTo(1);
        assertThat(report.succeeded()).isEqualTo(1);
        assertThat(report.stopReason()).isEqualTo(PreloadRunReport.StopReason.COMPLETED);
    }

    @Test
    void run_fetchesCandidatesOfTheDepartureWindowInSourceOrderWithinOneSession() {
        candidates.add(train(3));
        candidates.add(train(1));
        candidates.add(train(2));

        underTest.run();

        assertThat(candidates.requestedFrom).isEqualTo(OffsetDateTime.parse("2026-10-21T06:00:00+02:00"));
        assertThat(candidates.requestedTo).isEqualTo(OffsetDateTime.parse("2026-10-21T14:00:00+02:00"));
        assertThat(journeyFetch.fetched).extracting(TrainIdentification::id).containsExactly(3, 1, 2);
        assertThat(journeyFetch.connectedPerFetch).containsOnly(true);
        assertThat(journeyFetch.connected).isFalse();
    }

    @Test
    void run_whenTimeBudgetExceeded_stopsBetweenTrainsAndReportsSkipped() {
        TrainIdentification first = train(1);
        TrainIdentification second = train(2);
        candidates.add(first);
        candidates.add(second);
        candidates.add(train(3));
        candidates.add(train(4));
        journeyFetch.reply(first, new PreloadResult.Success(new JourneyProfile(), List.of(), List.of()), Duration.ofMinutes(3));
        journeyFetch.reply(second, new PreloadResult.Unavailable(), Duration.ofMinutes(2));

        PreloadRunReport report = underTest.run();

        assertThat(journeyFetch.fetched).extracting(TrainIdentification::id).containsExactly(1, 2);
        assertThat(report.processed()).isEqualTo(2);
        assertThat(report.skipped()).isEqualTo(2);
        assertThat(report.stopReason()).isEqualTo(PreloadRunReport.StopReason.TIME_BUDGET_EXCEEDED);
        assertThat(report.duration()).isEqualTo(Duration.ofMinutes(5));
        assertThat(store.saveCount).isEqualTo(1);
        assertThat(candidates.marked).containsExactly(1);
    }

    @Test
    void run_whenTimeBudgetExactlyReached_processesNextTrain() {
        TrainIdentification first = train(1);
        candidates.add(first);
        candidates.add(train(2));
        journeyFetch.reply(first, new PreloadResult.Unavailable(), MAX_DURATION);

        PreloadRunReport report = underTest.run();

        assertThat(journeyFetch.fetched).extracting(TrainIdentification::id).containsExactly(1, 2);
        assertThat(report.stopReason()).isEqualTo(PreloadRunReport.StopReason.COMPLETED);
    }

    @Test
    void run_whenInterrupted_stopsBeforeNextTrain() {
        TrainIdentification first = train(1);
        candidates.add(first);
        candidates.add(train(2));
        journeyFetch.onFetch(first, () -> Thread.currentThread().interrupt());

        PreloadRunReport report;
        try {
            report = underTest.run();
        } finally {
            Thread.interrupted();
        }

        assertThat(journeyFetch.fetched).extracting(TrainIdentification::id).containsExactly(1);
        assertThat(report.stopReason()).isEqualTo(PreloadRunReport.StopReason.INTERRUPTED);
        assertThat(report.skipped()).isEqualTo(1);
        assertThat(store.saveCount).isEqualTo(1);
    }

    @Test
    void run_passesSegmentProfilesOfEarlierTrainsToLaterTrainsAndSavesSharedOnesOnce() {
        TrainIdentification first = train(1);
        TrainIdentification second = train(2);
        candidates.add(first);
        candidates.add(second);
        SegmentProfile sharedSp = segmentProfile("SP_1");
        journeyFetch.reply(first, new PreloadResult.Success(new JourneyProfile(), List.of(sharedSp), List.of(trainCharacteristics("TC_1"))));
        journeyFetch.reply(second, new PreloadResult.Success(new JourneyProfile(), List.of(segmentProfile("SP_2")), List.of(trainCharacteristics("TC_1"))));

        underTest.run();

        assertThat(journeyFetch.knownSegmentProfilesPerFetch.get(0)).isEmpty();
        assertThat(journeyFetch.knownSegmentProfilesPerFetch.get(1)).containsExactly(SegmentProfileIdentification.from(sharedSp));
        assertThat(store.segmentProfiles).extracting(SegmentProfile::getSPID).containsExactlyInAnyOrder("SP_1", "SP_2");
        assertThat(store.trainCharacteristics).extracting(TrainCharacteristics::getTCID).containsExactly("TC_1");
        assertThat(store.journeyProfiles).hasSize(2);
    }

    @Test
    void run_marksOnlySuccessfulTrainsAndCountsEachOutcome() {
        TrainIdentification success = train(1);
        TrainIdentification unavailable = train(2);
        TrainIdentification error = train(3);
        TrainIdentification timeout = train(4);
        TrainIdentification secondError = train(5);
        List.of(success, unavailable, error, timeout, secondError).forEach(candidates::add);
        journeyFetch.reply(success, new PreloadResult.Success(new JourneyProfile(), List.of(), List.of()));
        journeyFetch.reply(unavailable, new PreloadResult.Unavailable());
        journeyFetch.reply(error, new PreloadResult.Error("JP request G2B error: 51"));
        journeyFetch.reply(timeout, new PreloadResult.Timeout("Preload timed out", new RuntimeException()));
        journeyFetch.reply(secondError, new PreloadResult.Error("Handshake not acknowledged!"));

        PreloadRunReport report = underTest.run();

        assertThat(candidates.marked).containsExactly(1);
        assertThat(report).isEqualTo(new PreloadRunReport(5, 5, 1, 1, 2, 1, 0, PreloadRunReport.StopReason.COMPLETED, Duration.ofSeconds(5)));
    }

    @Test
    void run_whenNoTrainSucceeds_stillSavesOnceWithNothing() {
        TrainIdentification train = train(1);
        candidates.add(train);
        journeyFetch.reply(train, new PreloadResult.Error("JP request G2B error: 51"));

        underTest.run();

        assertThat(store.saveCount).isEqualTo(1);
        assertThat(store.journeyProfiles).isEmpty();
        assertThat(store.segmentProfiles).isEmpty();
        assertThat(store.trainCharacteristics).isEmpty();
        assertThat(candidates.marked).isEmpty();
    }

    @Test
    void run_whenNoCandidates_stillConnectsAndSavesOnce() {
        PreloadRunReport report = underTest.run();

        assertThat(journeyFetch.connectCount).isEqualTo(1);
        assertThat(store.saveCount).isEqualTo(1);
        assertThat(report.requested()).isZero();
    }

    @Test
    void run_whenConnectFails_abortsWithoutFetchingOrSaving() {
        candidates.add(train(1));
        journeyFetch.connectFailure = new IllegalStateException("MQTT connect failed");

        assertThatThrownBy(underTest::run).isSameAs(journeyFetch.connectFailure);

        assertThat(journeyFetch.fetched).isEmpty();
        assertThat(store.saveCount).isZero();
        assertThat(candidates.marked).isEmpty();
    }

    @Test
    void run_whenFetchThrowsAfterEarlierSuccess_abortsWithoutSavingOrMarking() {
        TrainIdentification first = train(1);
        TrainIdentification second = train(2);
        candidates.add(first);
        candidates.add(second);
        candidates.add(train(3));
        journeyFetch.reply(first, new PreloadResult.Success(new JourneyProfile(), List.of(), List.of()));
        RuntimeException failure = new IllegalStateException("unexpected");
        journeyFetch.onFetch(second, () -> {
            throw failure;
        });

        assertThatThrownBy(underTest::run).isSameAs(failure);

        assertThat(journeyFetch.fetched).extracting(TrainIdentification::id).containsExactly(1, 2);
        assertThat(journeyFetch.connected).isTrue();
        assertThat(store.saveCount).isZero();
        assertThat(candidates.marked).isEmpty();
    }

    @Test
    void run_whenSaveFails_abortsWithoutMarkingAnyTrain() {
        TrainIdentification train = train(1);
        candidates.add(train);
        journeyFetch.reply(train, new PreloadResult.Success(new JourneyProfile(), List.of(), List.of()));
        store.saveFailure = new RuntimeException("Preload save failed");

        assertThatThrownBy(underTest::run).isSameAs(store.saveFailure);

        assertThat(candidates.marked).isEmpty();
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

    static final class MutableClock extends Clock {

        private Instant instant;
        private final ZoneId zone;

        MutableClock(Instant instant, ZoneId zone) {
            this.instant = instant;
            this.zone = zone;
        }

        void advance(Duration duration) {
            instant = instant.plus(duration);
        }

        @Override
        public ZoneId getZone() {
            return zone;
        }

        @Override
        public Clock withZone(ZoneId zone) {
            return new MutableClock(instant, zone);
        }

        @Override
        public Instant instant() {
            return instant;
        }
    }

    static final class FakeCandidates implements PreloadCandidates {

        private final List<TrainIdentification> trains = new ArrayList<>();
        final List<Integer> marked = new ArrayList<>();
        OffsetDateTime requestedFrom;
        OffsetDateTime requestedTo;

        void add(TrainIdentification train) {
            trains.add(train);
        }

        @Override
        public List<TrainIdentification> between(OffsetDateTime from, OffsetDateTime to) {
            requestedFrom = from;
            requestedTo = to;
            return List.copyOf(trains);
        }

        @Override
        public void markPreloaded(Set<Integer> trainIdentificationIds) {
            marked.addAll(trainIdentificationIds);
        }
    }

    static final class FakeJourneyFetch implements JourneyFetch {

        private final MutableClock clock;
        private final Map<TrainIdentification, PreloadResult> replies = new HashMap<>();
        private final Map<TrainIdentification, Duration> durations = new HashMap<>();
        private final Map<TrainIdentification, Runnable> sideEffects = new HashMap<>();
        final List<TrainIdentification> fetched = new ArrayList<>();
        final List<Set<SegmentProfileIdentification>> knownSegmentProfilesPerFetch = new ArrayList<>();
        final List<Boolean> connectedPerFetch = new ArrayList<>();
        RuntimeException connectFailure;
        boolean connected;
        int connectCount;

        FakeJourneyFetch(MutableClock clock) {
            this.clock = clock;
        }

        void reply(TrainIdentification train, PreloadResult result) {
            replies.put(train, result);
        }

        void reply(TrainIdentification train, PreloadResult result, Duration takes) {
            replies.put(train, result);
            durations.put(train, takes);
        }

        void onFetch(TrainIdentification train, Runnable sideEffect) {
            sideEffects.put(train, sideEffect);
        }

        @Override
        public void connect() {
            if (connectFailure != null) {
                throw connectFailure;
            }
            connectCount++;
            connected = true;
        }

        @Override
        public PreloadResult preload(TrainIdentification trainId, Map<SegmentProfileIdentification, SegmentProfile> segmentProfilesMap) {
            fetched.add(trainId);
            connectedPerFetch.add(connected);
            sideEffects.getOrDefault(trainId, () -> {
            }).run();
            knownSegmentProfilesPerFetch.add(Set.copyOf(segmentProfilesMap.keySet()));
            clock.advance(durations.getOrDefault(trainId, Duration.ofSeconds(1)));
            return replies.getOrDefault(trainId, new PreloadResult.Unavailable());
        }

        @Override
        public void disconnect() {
            connected = false;
        }
    }

    static final class FakeStore implements PreloadStore {

        final List<JourneyProfile> journeyProfiles = new ArrayList<>();
        final List<SegmentProfile> segmentProfiles = new ArrayList<>();
        final List<TrainCharacteristics> trainCharacteristics = new ArrayList<>();
        int saveCount;
        RuntimeException saveFailure;

        @Override
        public void save(Collection<JourneyProfile> jps, Collection<SegmentProfile> sps, Collection<TrainCharacteristics> tcs) {
            if (saveFailure != null) {
                throw saveFailure;
            }
            saveCount++;
            journeyProfiles.addAll(jps);
            segmentProfiles.addAll(sps);
            trainCharacteristics.addAll(tcs);
        }
    }
}
