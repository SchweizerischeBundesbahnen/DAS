package ch.sbb.das.backend.userproperties.internal;

import ch.sbb.das.backend.useractivity.UserActivityService;
import java.util.List;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import net.javacrumbs.shedlock.core.LockAssert;
import net.javacrumbs.shedlock.spring.annotation.SchedulerLock;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Transactional;

@Slf4j
@Component
@RequiredArgsConstructor
class UserPropertyCleanUpScheduler {

    private final UserPropertyServiceImpl userPropertyService;
    private final UserActivityService userActivityService;

    @Value("${user-activity.clean-up.older-than-days}")
    private long cleanUpOlderThanDays;

    @Transactional
    @Scheduled(cron = "${user-activity.clean-up.cron}")
    @SchedulerLock(name = "cleanUpUserProperties", lockAtLeastFor = "10m")
    void cleanUpInactiveUsersProperties() {
        LockAssert.assertLocked();
        List<String> inactiveOids = userActivityService.findInactiveOids(cleanUpOlderThanDays);
        if (inactiveOids.isEmpty()) {
            return;
        }
        int deleted = userPropertyService.deleteAllByOids(inactiveOids);
        log.info("Deleted {} user properties for {} inactive users", deleted, inactiveOids.size());
    }
}
