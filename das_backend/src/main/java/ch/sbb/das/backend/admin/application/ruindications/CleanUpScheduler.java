package ch.sbb.das.backend.admin.application.ruindications;

import ch.sbb.das.backend.admin.domain.ruindications.RuIndicationService;
import ch.sbb.das.backend.admin.domain.ruindications.SpecialHolidayService;
import ch.sbb.das.backend.common.DateTimeUtil;
import net.javacrumbs.shedlock.spring.annotation.SchedulerLock;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

@Component
public class CleanUpScheduler {

    private final RuIndicationService ruIndicationService;
    private final SpecialHolidayService specialHolidayService;

    @Value("${admin.clean-up.older-than-days}")
    private int cleanUpOlderThanDays;

    public CleanUpScheduler(RuIndicationService ruIndicationService, SpecialHolidayService specialHolidayService) {
        this.ruIndicationService = ruIndicationService;
        this.specialHolidayService = specialHolidayService;
    }

    @Scheduled(cron = "${admin.clean-up.cron}")
    @SchedulerLock(name = "adminCleanUp", lockAtLeastFor = "10m")
    public void cleanUp() {
        ruIndicationService.deleteAllBefore(DateTimeUtil.today().minusDays(cleanUpOlderThanDays));
        specialHolidayService.deleteAllBefore(DateTimeUtil.today().minusDays(cleanUpOlderThanDays));
    }
}
