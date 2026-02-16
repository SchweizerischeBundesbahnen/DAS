package ch.sbb.backend.preload.application;

import net.javacrumbs.shedlock.spring.annotation.SchedulerLock;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

@Component
public class CleanUpJobScheduler {

    private final TimetableService timetableService;
    private final StorageService storageService;

    public CleanUpJobScheduler(TimetableService timetableService, StorageService storageService) {
        this.timetableService = timetableService;
        this.storageService = storageService;
    }

    @Scheduled(cron = "${preload.trainCleanUp.cronExpression}")
    @SchedulerLock(name = "cleanUpTrainIdentifications", lockAtLeastFor = "10m")
    void cleanUpTrainRuns() {
        timetableService.deleteObsoleteData();
        storageService.cleanUp();
    }
}
