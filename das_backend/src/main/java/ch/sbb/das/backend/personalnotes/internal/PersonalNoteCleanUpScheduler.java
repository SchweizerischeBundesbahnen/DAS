package ch.sbb.das.backend.personalnotes.internal;

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
class PersonalNoteCleanUpScheduler {

    private final PersonalNoteServiceImpl personalNoteService;
    private final UserActivityService userActivityService;

    @Value("${user-activity.clean-up.older-than-days}")
    private long cleanUpOlderThanDays;

    @Transactional
    @Scheduled(cron = "${user-activity.clean-up.cron}")
    @SchedulerLock(name = "cleanUpPersonalNotes", lockAtLeastFor = "10m")
    void cleanUpInactiveUsersNotes() {
        LockAssert.assertLocked();
        List<String> inactiveOids = userActivityService.findInactiveOids(cleanUpOlderThanDays);
        if (inactiveOids.isEmpty()) {
            return;
        }
        int deleted = personalNoteService.deleteAllByOids(inactiveOids);
        log.info("Deleted {} personal notes for {} inactive users", deleted, inactiveOids.size());
    }
}
