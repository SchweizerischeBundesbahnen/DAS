package ch.sbb.das.backend.trainjourneypreloader.application;

import ch.sbb.das.backend.trainjourneyplan.TrainIdentification;
import ch.sbb.das.backend.trainjourneypreloader.application.PreloadRunReport.StopReason;
import ch.sbb.das.backend.trainjourneypreloader.domain.PreloadResult;
import ch.sbb.das.backend.trainjourneypreloader.domain.SegmentProfileIdentification;
import ch.sbb.das.backend.trainjourneypreloader.domain.TrainCharacteristicsIdentification;
import ch.sbb.das.backend.trainjourneypreloader.sfera.model.v0400.JourneyProfile;
import ch.sbb.das.backend.trainjourneypreloader.sfera.model.v0400.SegmentProfile;
import ch.sbb.das.backend.trainjourneypreloader.sfera.model.v0400.TrainCharacteristics;
import java.time.Clock;
import java.time.Duration;
import java.time.Instant;
import java.time.OffsetDateTime;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
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
        Clock clock,
        @Value("${trainjourneypreloader.hours-before-departure}") int hoursBeforeDeparture,
        @Value("${trainjourneypreloader.max-preload-duration}") Duration maxPreloadDuration
    ) {
        this.candidates = candidates;
        this.journeyFetch = journeyFetch;
        this.store = store;
        this.clock = clock;
        this.hoursBeforeDeparture = hoursBeforeDeparture;
        this.maxPreloadDuration = maxPreloadDuration;
    }

    /**
     * Fetches the candidates one after another until all are processed, the time budget is exceeded or the thread is interrupted, then saves what succeeded. An exception aborts the run
     * without saving or marking anything.
     */
    public PreloadRunReport run() {
        Instant startTime = clock.instant();
        Map<TrainIdentification, JourneyProfile> mapJourneyProfiles = new HashMap<>();
        Map<SegmentProfileIdentification, SegmentProfile> mapSegmentProfiles = new HashMap<>();
        Map<TrainCharacteristicsIdentification, TrainCharacteristics> mapTrainCharacteristics = new HashMap<>();
        OffsetDateTime now = OffsetDateTime.now(clock);
        List<TrainIdentification> trainIdentifications = candidates.between(now.minusHours(hoursBeforeDeparture), now.plusHours(hoursBeforeDeparture));
        journeyFetch.connect();
        int processedCount = 0;
        int unavailableCount = 0;
        int errorCount = 0;
        int timeoutCount = 0;
        StopReason stopReason = StopReason.COMPLETED;
        for (TrainIdentification trainId : trainIdentifications) {
            if (Thread.currentThread().isInterrupted()) {
                log.warn("Preload interrupted, stopping early");
                stopReason = StopReason.INTERRUPTED;
                break;
            }
            if (Duration.between(startTime, clock.instant()).compareTo(maxPreloadDuration) > 0) {
                int skippedCount = trainIdentifications.size() - processedCount;
                log.warn("Preload time budget of {} exceeded after processing {} trains. {} trains skipped, will continue on next schedule.",
                    maxPreloadDuration, processedCount, skippedCount);
                stopReason = StopReason.TIME_BUDGET_EXCEEDED;
                break;
            }
            processedCount++;
            PreloadResult preloadResult = journeyFetch.preload(trainId, mapSegmentProfiles);
            switch (preloadResult) {
                case PreloadResult.Success(var successJp, var successSps, var successTcs) -> {
                    mapJourneyProfiles.put(trainId, successJp);
                    mapSegmentProfiles.putAll(successSps.stream().collect(Collectors.toMap(SegmentProfileIdentification::from, sp -> sp)));
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
                case PreloadResult.Error(var message, Throwable ex) -> {
                    errorCount++;
                    log.error("Preload for train {} failed with message: {}", trainId, message, ex);
                }
            }
        }
        journeyFetch.disconnect();
        store.save(mapJourneyProfiles.values(), mapSegmentProfiles.values(), mapTrainCharacteristics.values());

        candidates.markPreloaded(mapJourneyProfiles.keySet().stream().map(TrainIdentification::id).collect(Collectors.toSet()));

        return new PreloadRunReport(trainIdentifications.size(), processedCount, mapJourneyProfiles.size(), unavailableCount, errorCount, timeoutCount,
            trainIdentifications.size() - processedCount, stopReason, Duration.between(startTime, clock.instant()));
    }
}
