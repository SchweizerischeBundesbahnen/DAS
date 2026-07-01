package ch.sbb.das.backend.indications.internal;

import ch.sbb.das.backend.common.DateTimeUtil;
import lombok.RequiredArgsConstructor;
import net.javacrumbs.shedlock.spring.annotation.SchedulerLock;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

@Component
@RequiredArgsConstructor
public class CleanUpScheduler {

    private final RuIndicationServiceImpl ruIndicationService;
    private final SpecialHolidayServiceImpl specialHolidayService;

    @Value("${admin.clean-up.older-than-days}")
    private int cleanUpOlderThanDays;

    @Scheduled(cron = "${admin.clean-up.cron}")
    @SchedulerLock(name = "adminCleanUp", lockAtLeastFor = "10m")
    public void cleanUp() {
        ruIndicationService.deleteAllBefore(DateTimeUtil.today().minusDays(cleanUpOlderThanDays));
        specialHolidayService.deleteAllBefore(DateTimeUtil.today().minusDays(cleanUpOlderThanDays));
    }
}
