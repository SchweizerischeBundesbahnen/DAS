package ch.sbb.backend.preload.application;

import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

@Component
public class CleanUpJobScheduler {

    private final TrainIdentificationCleaner trainIdentificationCleaner;

    public CleanUpJobScheduler(TrainIdentificationCleaner trainIdentificationCleaner) {
        this.trainIdentificationCleaner = trainIdentificationCleaner;
    }

    @Scheduled(cron = "${preload.trainCleanUp.cronExpression}")
    void cleanUpTrainRuns() {
        trainIdentificationCleaner.cleanUpTrainRuns();
    }
}
