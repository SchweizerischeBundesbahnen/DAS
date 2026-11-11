package ch.sbb.das.backend.trainjourneypreloader.application;

import ch.sbb.das.backend.trainjourneyplan.TrainIdentification;
import ch.sbb.das.backend.trainjourneypreloader.application.PreloadRunReport.StopReason;
import ch.sbb.das.backend.trainjourneypreloader.domain.PreloadAttempt;
import ch.sbb.das.backend.trainjourneypreloader.domain.PreloadResult;
import ch.sbb.das.backend.trainjourneypreloader.domain.TrainCharacteristicsIdentification;
import ch.sbb.das.backend.trainjourneypreloader.sfera.model.v0400.JourneyProfile;
import ch.sbb.das.backend.trainjourneypreloader.sfera.model.v0400.TrainCharacteristics;
import java.time.Clock;
import java.time.Duration;
import java.time.Instant;
import java.time.OffsetDateTime;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.SortedMap;
import java.util.TreeMap;
import java.util.stream.Collectors;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;

/**
 * One preload run: selects the preload candidates, fetches their journeys from TMS-VAD, saves them to the preload bucket and marks the successful ones as preloaded.
 */
@Component
@Slf4j
public class PreloadRun {

    private final PreloadCandidates candidates;
    private final JourneyFetch journeyFetch;
    private final PreloadStore store;
    private final SegmentProfileStore segmentProfileStore;
    private final Clock clock;

    /**
     * Due to infrastructure realtime handling of operating trains, real train runs get clear just a few hours earlier.
     */
    private final int hoursBeforeDeparture;

    /**
     * Maximum time budget for a single preload run. Must be shorter than the fetch-cron interval to prevent overlapping runs.
     */
    private final Duration maxPreloadDuration;

    public PreloadRun(
        PreloadCandidates candidates,
        JourneyFetch journeyFetch,
        PreloadStore store,
        SegmentProfileStore segmentProfileStore,
        Clock clock,
        @Value("${trainjourneypreloader.hours-before-departure}") int hoursBeforeDeparture,
        @Value("${trainjourneypreloader.max-preload-duration}") Duration maxPreloadDuration
    ) {
        this.candidates = candidates;
        this.journeyFetch = journeyFetch;
        this.store = store;
        this.segmentProfileStore = segmentProfileStore;
        this.clock = clock;
        this.hoursBeforeDeparture = hoursBeforeDeparture;
        this.maxPreloadDuration = maxPreloadDuration;
    }

    /**
     * Fetches the candidates one after another until all are processed, the time budget is exceeded or the thread is interrupted, then publishes the segment profiles, saves
     * the journeys and records every attempt. An exception while fetching, publishing or saving aborts the run without saving the journeys or recording anything; the
     * segment profiles fetched so far stay pending in the store and are published by the next run. If only recording fails, the saved trains stay candidates and are fetched
     * again by the next run.
     */
    public PreloadRunReport run() {
        final Instant startTime = clock.instant();
        final Map<TrainIdentification, JourneyProfile> mapJourneyProfiles = new HashMap<>();
        final Map<TrainCharacteristicsIdentification, TrainCharacteristics> mapTrainCharacteristics = new HashMap<>();
        final List<PreloadAttempt> attempts = new ArrayList<>();
        final SortedMap<String, Integer> errorsByG2bCode = new TreeMap<>();
        final OffsetDateTime now = OffsetDateTime.now(clock);
        final PreloadCandidates.Selection selection = candidates.between(now.minusHours(hoursBeforeDeparture), now.plusHours(hoursBeforeDeparture));
        final List<TrainIdentification> trainIdentifications = selection.trains();
        journeyFetch.connect();
        int processedCount = 0;
        int unavailableCount = 0;
        int errorCount = 0;
        int timeoutCount = 0;
        StopReason stopReason = StopReason.COMPLETED;
        for (final TrainIdentification trainId : trainIdentifications) {
            if (Thread.currentThread().isInterrupted()) {
                log.warn("Preload interrupted, stopping early");
                stopReason = StopReason.INTERRUPTED;
                break;
            }
            if (Duration.between(startTime, clock.instant()).compareTo(maxPreloadDuration) > 0) {
                final int skippedCount = trainIdentifications.size() - processedCount;
                log.warn("Preload time budget of {} exceeded after processing {} trains. {} trains skipped, will continue on next schedule.",
                    maxPreloadDuration, processedCount, skippedCount);
                stopReason = StopReason.TIME_BUDGET_EXCEEDED;
                break;
            }
            processedCount++;
            final PreloadResult preloadResult = journeyFetch.preload(trainId);
            attempts.add(PreloadAttempt.of(trainId.id(), preloadResult));
            switch (preloadResult) {
                case PreloadResult.Success(var successJp, var successSps, var successTcs) -> {
                    mapJourneyProfiles.put(trainId, successJp);
                    segmentProfileStore.add(successSps);
                    mapTrainCharacteristics.putAll(successTcs.stream().collect(Collectors.toMap(TrainCharacteristicsIdentification::from, tc -> tc)));
                    log.info("Preload for train {} succeeded with {} sps and {} tcs", trainId, successSps.size(), successTcs.size());
                }
                case PreloadResult.Unavailable() -> {
                    unavailableCount++;
                    log.info("Preload for train {} unavailable for now", trainId);
                }
                case PreloadResult.Timeout(var message, Throwable ex) -> {
                    timeoutCount++;
                    log.error("Preload for train {} timed out: {}", trainId, message, ex);
                }
                case PreloadResult.Error(var message, Throwable ex, var g2bCode) -> {
                    errorCount++;
                    if (g2bCode != null) {
                        Arrays.stream(g2bCode.split(", ")).distinct().forEach(code -> errorsByG2bCode.merge(code, 1, Integer::sum));
                    }
                    log.error("Preload for train {} failed with message: {}", trainId, message, ex);
                }
            }
        }
        journeyFetch.disconnect();
        final int publishedSegmentProfiles = segmentProfileStore.publish();
        log.info("Saving journeyProfiles={}, segmentProfiles={}, trainCharacteristics={}...", mapJourneyProfiles.size(), publishedSegmentProfiles, mapTrainCharacteristics.size());
        store.save(mapJourneyProfiles.values(), mapTrainCharacteristics.values());

        candidates.recordAttempts(now, attempts);

        return new PreloadRunReport(trainIdentifications.size(), processedCount, mapJourneyProfiles.size(), unavailableCount, errorCount, timeoutCount,
            trainIdentifications.size() - processedCount, selection.deferred(), Collections.unmodifiableSortedMap(errorsByG2bCode), stopReason,
            Duration.between(startTime, clock.instant()));
    }
}
