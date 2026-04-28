package ch.sbb.das.backend.preload.application;

import java.time.LocalDate;
import net.javacrumbs.shedlock.spring.annotation.SchedulerLock;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

@Component
public class TrainCleanUpJobScheduler {

    private final TimetableService timetableService;

    @Value("${preload.trainCleanUp.days}")
    private int days;

    public TrainCleanUpJobScheduler(TimetableService timetableService) {
        this.timetableService = timetableService;
    }

    @Scheduled(cron = "${preload.trainCleanUp.cronExpression}")
    @SchedulerLock(name = "trainCleanUp", lockAtLeastFor = "10m")
    void cleanUpPreload() {
        timetableService.deleteAllBefore(LocalDate.now().minusDays(days));
    }
}
