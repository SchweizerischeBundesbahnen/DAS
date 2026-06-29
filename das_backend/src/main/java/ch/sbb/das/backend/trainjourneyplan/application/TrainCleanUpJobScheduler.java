package ch.sbb.das.backend.trainjourneyplan.application;

import ch.sbb.das.backend.common.DateTimeUtil;
import net.javacrumbs.shedlock.spring.annotation.SchedulerLock;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

@Component
public class TrainCleanUpJobScheduler {

    private final TimetableService timetableService;

    @Value("${trainjourneyplan.train-clean-up.days}")
    private int days;

    public TrainCleanUpJobScheduler(TimetableService timetableService) {
        this.timetableService = timetableService;
    }

    @Scheduled(cron = "${trainjourneyplan.train-clean-up.cron-expression}")
    @SchedulerLock(name = "trainCleanUp", lockAtLeastFor = "10m")
    void cleanUpPreload() {
        timetableService.deleteAllBefore(DateTimeUtil.today().minusDays(days));
    }
}
