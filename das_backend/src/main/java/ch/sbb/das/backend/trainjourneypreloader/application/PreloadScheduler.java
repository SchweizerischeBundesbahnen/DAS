package ch.sbb.das.backend.trainjourneypreloader.application;

import ch.sbb.das.backend.common.DateTimeUtil;
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
    @Value("${trainjourneypreloader.storage-clean-up.hours}")
    private int cleanUpHours;

    public PreloadScheduler(PreloadRun preloadRun, CleanupStorageService cleanupStorageService) {
        this.preloadRun = preloadRun;
        this.cleanupStorageService = cleanupStorageService;
    }

    /**
     * The ShedLock lockAtLeastFor duration is the preload run's time budget, which must be shorter than the fetch-cron interval to prevent overlapping runs.
     */
    @Scheduled(cron = "${trainjourneypreloader.fetch-cron}")
    @SchedulerLock(name = "preload", lockAtLeastFor = "${trainjourneypreloader.max-preload-duration}")
    public void scheduledPreload() {
        log.info("Preload started");
        PreloadRunReport report = preloadRun.run();
        log.info("Preload with {} JPs of requested {} JPs ended in {} ms (timeouts: {})", report.succeeded(), report.requested(), report.duration().toMillis(),
            report.timeouts());

        cleanupStorageService.deleteAllBefore(DateTimeUtil.now().minusHours(cleanUpHours));
        cleanupStorageService.cleanupSegments();
    }

}
