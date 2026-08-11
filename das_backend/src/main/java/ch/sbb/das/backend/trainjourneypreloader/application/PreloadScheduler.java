package ch.sbb.das.backend.trainjourneypreloader.application;

import ch.sbb.das.backend.common.DateTimeUtil;
import ch.sbb.das.backend.trainjourneyplan.TrainIdentification;
import ch.sbb.das.backend.trainjourneyplan.TrainIdentificationService;
import ch.sbb.das.backend.trainjourneypreloader.domain.PreloadResult;
import ch.sbb.das.backend.trainjourneypreloader.domain.SegmentProfileIdentification;
import ch.sbb.das.backend.trainjourneypreloader.domain.TrainCharacteristicsIdentification;
import ch.sbb.das.backend.trainjourneypreloader.sfera.model.v0400.JourneyProfile;
import ch.sbb.das.backend.trainjourneypreloader.sfera.model.v0400.SegmentProfile;
import ch.sbb.das.backend.trainjourneypreloader.sfera.model.v0400.TrainCharacteristics;
import java.time.Duration;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;
import lombok.extern.slf4j.Slf4j;
import net.javacrumbs.shedlock.spring.annotation.SchedulerLock;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

@Component
@Slf4j
public class PreloadScheduler {

    /**
     * Due to infrastructure realtime handling of operating trains, real train runs get clear just a few hours earlier.
     */
    private static final int PRELOAD_HOURS_BEFORE_DEPARTURE = 4;

    /**
     * Maximum time budget for a single preload run. Also used as the ShedLock lockAtLeastFor duration. Must be shorter than the fetch-cron interval to prevent overlapping runs.
     */
    @Value("${trainjourneypreloader.max-preload-duration}")
    private Duration maxPreloadDuration;

    private final SferaService sferaService;
    private final TrainIdentificationService trainIdentificationsService;
    private final StorageService storageService;
    private final CleanupStorageService cleanupStorageService;
    @Value("${trainjourneypreloader.storage-clean-up.hours}")
    private int cleanUpHours;

    public PreloadScheduler(
        SferaService sferaService,
        TrainIdentificationService trainIdentificationsService,
        StorageService storageService,
        CleanupStorageService cleanupStorageService
    ) {
        this.sferaService = sferaService;
        this.trainIdentificationsService = trainIdentificationsService;
        this.storageService = storageService;
        this.cleanupStorageService = cleanupStorageService;
    }

    @Scheduled(cron = "${trainjourneypreloader.fetch-cron}")
    @SchedulerLock(name = "preload", lockAtLeastFor = "${trainjourneypreloader.max-preload-duration}")
    public void scheduledPreload() {
        log.info("Preload started");
        long startTime = System.currentTimeMillis();
        Map<TrainIdentification, JourneyProfile> mapJourneyProfiles = new HashMap<>();
        Map<SegmentProfileIdentification, SegmentProfile> mapSegmentProfiles = new HashMap<>();
        Map<TrainCharacteristicsIdentification, TrainCharacteristics> mapTrainCharacteristics = new HashMap<>();
        List<TrainIdentification> trainIdentifications = trainIdentificationsService.getNewTrainIdentificationsBetween(DateTimeUtil.now().minusHours(PRELOAD_HOURS_BEFORE_DEPARTURE),
            DateTimeUtil.now().plusHours(PRELOAD_HOURS_BEFORE_DEPARTURE));
        sferaService.connect();
        int processedCount = 0;
        int timeoutCount = 0;
        for (TrainIdentification trainId : trainIdentifications) {
            if (Thread.currentThread().isInterrupted()) {
                log.warn("Preload interrupted, stopping early");
                break;
            }
            if (System.currentTimeMillis() - startTime > maxPreloadDuration.toMillis()) {
                int skippedCount = trainIdentifications.size() - processedCount;
                log.warn("Preload time budget of {} exceeded after processing {} trains. {} trains skipped, will continue on next schedule.",
                    maxPreloadDuration, processedCount, skippedCount);
                break;
            }
            processedCount++;
            PreloadResult preloadResult = sferaService.preload(trainId, mapSegmentProfiles);
            switch (preloadResult) {
                case PreloadResult.Success(var successJp, var successSps, var successTcs) -> {
                    mapJourneyProfiles.put(trainId, successJp);
                    mapSegmentProfiles.putAll(successSps.stream().collect(Collectors.toMap(SegmentProfileIdentification::from, sp -> sp)));
                    mapTrainCharacteristics.putAll(successTcs.stream().collect(Collectors.toMap(TrainCharacteristicsIdentification::from, tc -> tc)));
                    log.info("Preload for train {} succeeded with {} sps and {} tcs", trainId, successSps.size(), successTcs.size());
                }
                case PreloadResult.Unavailable() -> {
                    log.info("Preload for train {} unavailable for now", trainId);
                }
                case PreloadResult.Timeout(var message, Throwable ex) -> {
                    timeoutCount++;
                    log.error("Preload for train {} timed out: {}", trainId, message, ex);
                }
                case PreloadResult.Error(var message, Throwable ex) -> {
                    log.error("Preload for train {} failed with message: {}", trainId, message, ex);
                }
            }
        }
        sferaService.disconnect();
        storageService.save(mapJourneyProfiles.values(), mapSegmentProfiles.values(), mapTrainCharacteristics.values());

        trainIdentificationsService.savePreloadedTrainIds(mapJourneyProfiles.keySet().stream().map(TrainIdentification::id).collect(Collectors.toSet()));
        log.info("Preload with {} JPs of requested {} JPs ended in {} ms (timeouts: {})", mapJourneyProfiles.size(), trainIdentifications.size(), System.currentTimeMillis() - startTime,
            timeoutCount);

        cleanupStorageService.deleteAllBefore(DateTimeUtil.now().minusHours(cleanUpHours));
        cleanupStorageService.cleanupSegments();
    }

}
