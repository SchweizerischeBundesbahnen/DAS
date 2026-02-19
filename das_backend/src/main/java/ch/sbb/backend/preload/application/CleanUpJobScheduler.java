package ch.sbb.backend.preload.application;

import java.time.LocalDate;
import java.time.OffsetDateTime;
import net.javacrumbs.shedlock.spring.annotation.SchedulerLock;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

@Component
public class CleanUpJobScheduler {

    private final TimetableService timetableService;
    private final StorageService storageService;

    @Value("${preload.trainCleanUp.days}")
    private int cleanUpDays;

    @Value("${preload.fileCleanUp.hours}")
    private int olderThanHours;

    public CleanUpJobScheduler(TimetableService timetableService, StorageService storageService) {
        this.timetableService = timetableService;
        this.storageService = storageService;
    }

    @Scheduled(cron = "${preload.trainCleanUp.cronExpression}")
    @SchedulerLock(name = "cleanUpTrainIdentifications", lockAtLeastFor = "10m")
    void cleanUpTrainRuns() {
        timetableService.deleteObsoleteData(LocalDate.now().minusDays(cleanUpDays));
        storageService.cleanUp(OffsetDateTime.now().minusHours(olderThanHours));
    }
}
