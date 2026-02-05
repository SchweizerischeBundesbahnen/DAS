package ch.sbb.backend.preload.application;

import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

@Component
public class CleanUpJobScheduler {

    private final TrainRunCleaner trainRunCleaner;

    public CleanUpJobScheduler(TrainRunCleaner trainRunCleaner) {
        this.trainRunCleaner = trainRunCleaner;
    }

    @Scheduled(cron = "${preload.trainCleanUp.cronExpression}")
    void cleanUpTrainRuns() {
        trainRunCleaner.cleanUpTrainRuns();
    }
}
