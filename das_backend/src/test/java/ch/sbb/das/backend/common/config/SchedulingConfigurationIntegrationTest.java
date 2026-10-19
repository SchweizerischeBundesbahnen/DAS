package ch.sbb.das.backend.common.config;

import static org.assertj.core.api.Assertions.assertThat;

import ch.sbb.das.backend.IntegrationTest;
import java.time.Instant;
import java.util.concurrent.CountDownLatch;
import java.util.concurrent.TimeUnit;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.scheduling.TaskScheduler;

@IntegrationTest
class SchedulingConfigurationIntegrationTest {

    @Autowired
    private TaskScheduler taskScheduler;

    @Test
    @DisplayName("taskScheduler_blockedTask_otherTaskStillRuns|SEVu3yZCaMEdmN3XoUsT|tests:2792")
    void taskScheduler_blockedTask_otherTaskStillRuns() throws InterruptedException {
        CountDownLatch release = new CountDownLatch(1);
        CountDownLatch blockedStarted = new CountDownLatch(1);
        CountDownLatch otherRan = new CountDownLatch(1);

        try {
            taskScheduler.schedule(() -> {
                blockedStarted.countDown();
                try {
                    release.await();
                } catch (InterruptedException e) {
                    Thread.currentThread().interrupt();
                }
            }, Instant.now());
            assertThat(blockedStarted.await(5, TimeUnit.SECONDS)).isTrue();

            taskScheduler.schedule(otherRan::countDown, Instant.now());

            assertThat(otherRan.await(5, TimeUnit.SECONDS)).isTrue();
        } finally {
            release.countDown();
        }
    }
}
