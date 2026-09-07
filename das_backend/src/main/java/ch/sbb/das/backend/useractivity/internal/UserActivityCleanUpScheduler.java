package ch.sbb.das.backend.useractivity.internal;

import ch.sbb.das.backend.common.DateTimeUtil;
import java.time.OffsetDateTime;
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
class UserActivityCleanUpScheduler {

    /**
     * Extra days the activity record is kept beyond the data-retention threshold.
     */
    private static final long ACTIVITY_RECORD_RETENTION_BUFFER_DAYS = 7;

    private final UserActivityRepository userActivityRepository;

    @Value("${user-activity.clean-up.older-than-days}")
    private long cleanUpOlderThanDays;

    @Transactional
    @Scheduled(cron = "${user-activity.clean-up.cron}")
    @SchedulerLock(name = "cleanUpUserActivity", lockAtLeastFor = "10m")
    void cleanUpUserActivity() {
        LockAssert.assertLocked();
        long retentionDays = cleanUpOlderThanDays + ACTIVITY_RECORD_RETENTION_BUFFER_DAYS;
        OffsetDateTime threshold = DateTimeUtil.now().minusDays(retentionDays);
        List<UserActivityEntity> inactive = userActivityRepository.findAllByLastAccessedAtBefore(threshold);
        if (inactive.isEmpty()) {
            return;
        }
        List<String> inactiveOids = inactive.stream().map(UserActivityEntity::getOid).toList();
        userActivityRepository.deleteByOidIn(inactiveOids);
        log.info("Removed {} activity records for users inactive for more than {} days", inactiveOids.size(), retentionDays);
    }
}
