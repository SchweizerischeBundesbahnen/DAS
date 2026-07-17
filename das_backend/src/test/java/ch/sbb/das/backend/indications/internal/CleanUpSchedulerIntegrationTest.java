package ch.sbb.das.backend.indications.internal;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.when;

import ch.sbb.das.backend.IntegrationTest;
import ch.sbb.das.backend.companies.CompanyCode;
import ch.sbb.das.backend.indications.internal.model.RuIndicationPeriod;
import ch.sbb.das.backend.indications.internal.model.ScheduleType;
import ch.sbb.das.backend.locations.TafTapLocationReference;
import jakarta.transaction.Transactional;
import java.time.LocalDate;
import java.util.List;
import java.util.Optional;
import java.util.Set;
import net.javacrumbs.shedlock.core.LockProvider;
import net.javacrumbs.shedlock.core.SimpleLock;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.mockito.Mockito;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.security.test.context.support.WithMockUser;
import org.springframework.test.context.bean.override.mockito.MockitoBean;

@IntegrationTest
class CleanUpSchedulerIntegrationTest {

    @MockitoBean
    private LockProvider lockProvider;

    @Autowired
    private CleanUpScheduler cleanUpScheduler;

    @Autowired
    private RuIndicationRepository ruIndicationRepository;

    @Autowired
    private SpecialHolidayRepository specialHolidayRepository;

    @Autowired
    private jakarta.persistence.EntityManager entityManager;

    @Value("${admin.clean-up.older-than-days}")
    private int cleanUpOlderThanDays;

    private LocalDate currentCutoff;

    private static RuIndicationEntity createRuIndicationEntity(List<RuIndicationPeriod> periods) {
        RuIndicationEntity entity = new RuIndicationEntity();
        entity.setCategory("TEST");
        entity.setTitleDe("Test Indication");
        entity.setTextDe("Test text");
        entity.setCompanies(Set.of(new CompanyCode("1111")));
        entity.setOperationalTrainNumberFilters(List.of());
        entity.setTafTapLocationReferences(List.of(TafTapLocationReference.of("CH00001")));
        entity.setPeriods(periods);
        return entity;
    }

    private static SpecialHolidayEntity createSpecialHolidayEntity(String name, LocalDate date) {
        SpecialHolidayEntity entity = new SpecialHolidayEntity();
        entity.setName(name);
        entity.setDate(date);
        entity.setCompanies(Set.of(new CompanyCode("1111")));
        entity.setScheduleType(ScheduleType.MONDAY_SCHEDULE);
        return entity;
    }

    @BeforeEach
    void setUp() {
        ruIndicationRepository.deleteAll();
        specialHolidayRepository.deleteAll();
        this.currentCutoff = LocalDate.now().minusDays(cleanUpOlderThanDays);
        SimpleLock dummyLock = Mockito.mock(SimpleLock.class);
        when(lockProvider.lock(any())).thenReturn(Optional.of(dummyLock));
    }

    @DisplayName("Clean up - deletes old RU indications and special holidays|tests:1657(9),1656")
    @Test
    @Transactional
    @WithMockUser(authorities = "ROLE_admin")
    void cleanUp_deletesOldRuIndicationsAndSpecialHolidays() {
        // Old RU indication: last period ends before cutoff
        RuIndicationEntity oldIndication = createRuIndicationEntity(
            List.of(
                // period that ends before cutoff
                new RuIndicationPeriod(currentCutoff.minusDays(30), currentCutoff.minusDays(16), Set.of())
            )
        );

        // Active RU indication: last period ends after cutoff
        RuIndicationEntity activeIndication = createRuIndicationEntity(
            List.of(
                // period that ends after cutoff
                new RuIndicationPeriod(currentCutoff.plusDays(12), currentCutoff.plusDays(40), Set.of())
            )
        );

        // Old special holiday (date before cutoff)
        SpecialHolidayEntity oldHoliday = createSpecialHolidayEntity(
            "Old Holiday",
            currentCutoff.minusDays(40)
        );

        // Active special holiday (date after cutoff)
        SpecialHolidayEntity activeHoliday = createSpecialHolidayEntity(
            "Active Holiday",
            currentCutoff.plusDays(12)
        );

        ruIndicationRepository.save(oldIndication);
        ruIndicationRepository.save(activeIndication);
        specialHolidayRepository.save(oldHoliday);
        specialHolidayRepository.save(activeHoliday);
        entityManager.flush();

        assertThat(ruIndicationRepository.findAll()).hasSize(2);
        assertThat(specialHolidayRepository.findAll()).hasSize(2);

        // Execute cleanup (cutoff is 30 days ago, which is around 2026-05-03)
        cleanUpScheduler.cleanUp();

        // Verify old records were deleted
        assertThat(ruIndicationRepository.findAll())
            .hasSize(1)
            .allMatch(entity -> entity.getId() != null);

        assertThat(specialHolidayRepository.findAll())
            .hasSize(1)
            .allMatch(entity -> entity.getId() != null);
    }

    @DisplayName("Clean up - preserves indications with multiple periods if latest period is active|tests:1657(9)")
    @Test
    @Transactional
    @WithMockUser(authorities = "ROLE_admin")
    void cleanUp_preservesIndicationsWithMultiplePeriodsIfLatestPeriodIsActive() {
        // Indication with multiple periods: oldest is very old, but latest is active
        RuIndicationEntity multiPeriodIndication = createRuIndicationEntity(
            List.of(
                // old period
                new RuIndicationPeriod(currentCutoff.minusDays(150), currentCutoff.minusDays(120), Set.of()),
                // latest active period
                new RuIndicationPeriod(currentCutoff.plusDays(12), currentCutoff.plusDays(75), Set.of())
            )
        );

        ruIndicationRepository.save(multiPeriodIndication);
        entityManager.flush();
        assertThat(ruIndicationRepository.findAll()).hasSize(1);

        // Execute cleanup
        cleanUpScheduler.cleanUp();

        // Verify indication was preserved (latest period is after cutoff)
        assertThat(ruIndicationRepository.findAll()).hasSize(1);
    }

    @DisplayName("Clean up - deletes indications with all periods older than cutoff|tests:1657(9)")
    @Test
    @Transactional
    @WithMockUser(authorities = "ROLE_admin")
    void cleanUp_deletesIndicationsWithAllPeriodsOlderThanCutoff() {
        // Indication with multiple periods: all are before cutoff
        RuIndicationEntity multiPeriodOldIndication = createRuIndicationEntity(
            List.of(
                new RuIndicationPeriod(currentCutoff.minusDays(150), currentCutoff.minusDays(120), Set.of()),
                new RuIndicationPeriod(currentCutoff.minusDays(90), currentCutoff.minusDays(60), Set.of()),
                // latest period still before cutoff
                new RuIndicationPeriod(currentCutoff.minusDays(50), currentCutoff.minusDays(1), Set.of())
            )
        );

        ruIndicationRepository.save(multiPeriodOldIndication);
        entityManager.flush();
        assertThat(ruIndicationRepository.findAll()).hasSize(1);

        // Execute cleanup
        cleanUpScheduler.cleanUp();

        assertThat(ruIndicationRepository.findAll()).isEmpty();
    }
}
