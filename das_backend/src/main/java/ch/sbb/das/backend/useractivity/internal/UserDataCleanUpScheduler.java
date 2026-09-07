package ch.sbb.das.backend.useractivity.internal;

import ch.sbb.das.backend.common.DateTimeUtil;
import ch.sbb.das.backend.common.UserDataService;
import java.time.LocalDate;
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
class UserDataCleanUpScheduler {

    private final UserActivityRepository userActivityRepository;
    private final List<UserDataService> userDataServices;

    @Value("${user-activity.clean-up.older-than-days}")
    private long cleanUpOlderThanDays;

    @Transactional
    @Scheduled(cron = "${user-activity.clean-up.cron}")
    @SchedulerLock(name = "cleanUpInactiveUserData", lockAtLeastFor = "10m")
    void cleanUpInactiveUserData() {
        LockAssert.assertLocked();

        LocalDate threshold = DateTimeUtil.today().minusDays(cleanUpOlderThanDays);
        List<String> inactiveOids = userActivityRepository.findAllByLastAccessedOnBefore(threshold).stream()
            .map(UserActivityEntity::getOid)
            .toList();
        if (inactiveOids.isEmpty()) {
            return;
        }

        for (UserDataService userDataService : userDataServices) {
            int deleted = userDataService.deleteAllByOids(inactiveOids);
            log.info("{} deleted {} records for {} inactive users", userDataService.getClass().getSimpleName(), deleted, inactiveOids.size());
        }

        userActivityRepository.deleteByOidIn(inactiveOids);
        log.info("Removed {} activity records for inactive users", inactiveOids.size());
    }
}
