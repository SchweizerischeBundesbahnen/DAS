package ch.sbb.backend.preload.application;

import java.time.OffsetDateTime;
import net.javacrumbs.shedlock.spring.annotation.SchedulerLock;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

@Component
public class CleanUpJobScheduler {

    private final TimetableService timetableService;
    private final StorageService storageService;

    @Value("${preload.cleanUp.hours}")
    private int cleanUpHours;

    public CleanUpJobScheduler(TimetableService timetableService, StorageService storageService) {
        this.timetableService = timetableService;
        this.storageService = storageService;
    }

    @Scheduled(cron = "${preload.cleanUp.cronExpression}")
    @SchedulerLock(name = "cleanUpPreload", lockAtLeastFor = "10m")
    void cleanUpPreload() {
        OffsetDateTime cleanUpCutOff = OffsetDateTime.now().minusHours(cleanUpHours);
        storageService.deleteAllOlderThan(cleanUpCutOff);
        timetableService.deleteAllOlderThan(cleanUpCutOff.toLocalDate());
    }
}
