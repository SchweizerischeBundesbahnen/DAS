package ch.sbb.das.backend.trainjourneypreloader.application;

import ch.sbb.das.backend.common.DateTimeUtil;
import ch.sbb.das.backend.common.LogKeys;
import lombok.extern.slf4j.Slf4j;
import net.javacrumbs.shedlock.spring.annotation.SchedulerLock;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

@Component
@Slf4j
public class PreloadScheduler {

    private final PreloadRun preloadRun;
    private final CleanupStorageService cleanupStorageService;
    private final SegmentProfileStore segmentProfileStore;
    @Value("${trainjourneypreloader.storage-clean-up.hours}")
    private int cleanUpHours;

    public PreloadScheduler(PreloadRun preloadRun, CleanupStorageService cleanupStorageService, SegmentProfileStore segmentProfileStore) {
        this.preloadRun = preloadRun;
        this.cleanupStorageService = cleanupStorageService;
        this.segmentProfileStore = segmentProfileStore;
    }

    /**
     * The ShedLock lockAtLeastFor duration is the preload run's time budget, which must be shorter than the fetch-cron interval to prevent overlapping runs.
     */
    @Scheduled(cron = "${trainjourneypreloader.fetch-cron}")
    @SchedulerLock(name = "preload", lockAtLeastFor = "${trainjourneypreloader.max-preload-duration}")
    public void scheduledPreload() {
        log.atInfo().log("Preload run started");
        PreloadRunReport report = preloadRun.run();
        log.atInfo()
            .addKeyValue("requested", report.requested())
            .addKeyValue("processed", report.processed())
            .addKeyValue("succeeded", report.succeeded())
            .addKeyValue("unavailable", report.unavailable())
            .addKeyValue("errors", report.errors())
            .addKeyValue("timeouts", report.timeouts())
            .addKeyValue("skipped", report.skipped())
            .addKeyValue("deferred", report.deferred())
            .addKeyValue("errorsByG2bCode", report.errorsByG2bCode())
            .addKeyValue("stopReason", report.stopReason())
            .addKeyValue(LogKeys.DURATION_MS, report.duration().toMillis())
            .log("Preload run finished");

        cleanupStorageService.deleteAllBefore(DateTimeUtil.now().minusHours(cleanUpHours));
        segmentProfileStore.compact();
    }

}
