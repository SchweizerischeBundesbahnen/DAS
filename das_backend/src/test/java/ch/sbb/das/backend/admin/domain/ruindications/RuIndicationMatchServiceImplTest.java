package ch.sbb.das.backend.admin.domain.ruindications;

import static org.assertj.core.api.Assertions.assertThat;

import ch.sbb.das.backend.admin.application.ruindications.model.RuIndication;
import ch.sbb.das.backend.admin.application.ruindications.model.RuIndicationContent;
import ch.sbb.das.backend.admin.application.ruindications.model.RuIndicationEntry;
import ch.sbb.das.backend.admin.application.ruindications.model.RuIndicationMatch;
import ch.sbb.das.backend.admin.application.ruindications.model.RuIndicationMatchesRequest;
import ch.sbb.das.backend.admin.application.ruindications.model.RuIndicationPeriod;
import ch.sbb.das.backend.admin.application.ruindications.model.RuIndicationScope;
import ch.sbb.das.backend.admin.application.ruindications.model.ScheduleType;
import ch.sbb.das.backend.admin.application.ruindications.model.SpecialHoliday;
import ch.sbb.das.backend.admin.application.ruindications.model.TrainNumberFilterRequest;
import ch.sbb.das.backend.admin.application.ruindications.model.TrainNumberParity;
import ch.sbb.das.backend.companies.CompanyCode;
import ch.sbb.das.backend.formation.domain.model.TafTapLocationReference;
import java.time.DayOfWeek;
import java.time.LocalDate;
import java.util.List;
import java.util.Set;
import org.junit.jupiter.api.Test;

class RuIndicationMatchServiceImplTest {

    private static final RuIndicationEntry DEFAULT_DE_CONTENT = new RuIndicationEntry("Hinweis", "Text");

    private RuIndicationMatchServiceImpl underTest;

    @Test
    void findMatches_matchesAllCriteria_andGroupsRuIndicationContentsByLocation() {
        RuIndicationRepository ruIndicationRepository = new InMemoryRuIndicationRepository();
        ruIndicationRepository.save(new RuIndication(null,
            new RuIndicationContent(null, new RuIndicationEntry("Hinweis 1", "Text 1"), null, null),
            new RuIndicationScope(
                Set.of(new CompanyCode("1111")),
                List.of(new TrainNumberFilterRequest("100-200", TrainNumberParity.ANY)),
                Set.of(TafTapLocationReference.of("CH00002"), TafTapLocationReference.of("CH00004"))
            ),
            List.of(new RuIndicationPeriod(LocalDate.of(2026, 5, 1), LocalDate.of(2026, 5, 31), Set.of(DayOfWeek.MONDAY)))
        ));

        ruIndicationRepository.save(new RuIndication(null,
            new RuIndicationContent(null, new RuIndicationEntry("Irrelevant", "Irrelevant"), null, null),
            new RuIndicationScope(
                Set.of(new CompanyCode("2222")),
                List.of(new TrainNumberFilterRequest("100-200", TrainNumberParity.ANY)),
                Set.of(TafTapLocationReference.of("CH00002"))
            ),
            List.of(new RuIndicationPeriod(LocalDate.of(2026, 5, 1), LocalDate.of(2026, 5, 31), Set.of(DayOfWeek.MONDAY)))
        ));

        ruIndicationRepository.save(new RuIndication(null,
            new RuIndicationContent(null, new RuIndicationEntry("Hinweis 2", "Text 2"), null, null),
            new RuIndicationScope(
                Set.of(new CompanyCode("1111")),
                List.of(),
                Set.of(TafTapLocationReference.of("CH00002"), TafTapLocationReference.of("CH00003"))
            ),
            List.of(new RuIndicationPeriod(LocalDate.of(2026, 5, 1), LocalDate.of(2026, 5, 31), Set.of(DayOfWeek.MONDAY)))
        ));

        underTest = new RuIndicationMatchServiceImpl(ruIndicationRepository, new InMemorySpecialHolidayRepository());

        RuIndicationMatchesRequest request = new RuIndicationMatchesRequest(
            new CompanyCode("1111"),
            150,
            LocalDate.of(2026, 5, 11),
            Set.of(TafTapLocationReference.of("CH00002"), TafTapLocationReference.of("CH00003"))
        );

        List<RuIndicationMatch> result = underTest.findMatches(request, null);

        assertThat(result)
            .hasSize(2)
            .anySatisfy(relevantRuIndication -> {
                assertThat(relevantRuIndication.tafTapLocationReference()).isEqualTo(TafTapLocationReference.of("CH00002"));
                assertThat(relevantRuIndication.ruIndicationContents()).containsExactly(
                    new RuIndicationEntry("Hinweis 1", "Text 1"),
                    new RuIndicationEntry("Hinweis 2", "Text 2")
                );
            })
            .anySatisfy(relevantRuIndication -> {
                assertThat(relevantRuIndication.tafTapLocationReference()).isEqualTo(TafTapLocationReference.of("CH00003"));
                assertThat(relevantRuIndication.ruIndicationContents()).containsExactly(new RuIndicationEntry("Hinweis 2", "Text 2"));
            });
    }

    @Test
    void findMatches_appliesTrainParityAndRange() {
        RuIndicationRepository ruIndicationRepository = new InMemoryRuIndicationRepository();
        ruIndicationRepository.save(new RuIndication(null,
            new RuIndicationContent(null, DEFAULT_DE_CONTENT, null, null),
            new RuIndicationScope(
                Set.of(new CompanyCode("1111")),
                List.of(new TrainNumberFilterRequest("300-310", TrainNumberParity.EVEN)),
                Set.of(TafTapLocationReference.of("CH00010"))
            ),
            List.of(new RuIndicationPeriod(LocalDate.of(2026, 1, 1), LocalDate.of(2026, 12, 31), Set.of(DayOfWeek.TUESDAY)))
        ));
        underTest = new RuIndicationMatchServiceImpl(ruIndicationRepository, new InMemorySpecialHolidayRepository());

        RuIndicationMatchesRequest oddTrainRequest = new RuIndicationMatchesRequest(
            new CompanyCode("1111"),
            301,
            LocalDate.of(2026, 1, 6),
            Set.of(TafTapLocationReference.of("CH00010"))
        );

        RuIndicationMatchesRequest evenTrainRequest = new RuIndicationMatchesRequest(
            new CompanyCode("1111"),
            302,
            LocalDate.of(2026, 1, 6),
            Set.of(TafTapLocationReference.of("CH00010"))
        );

        assertThat(underTest.findMatches(oddTrainRequest, null)).isEmpty();
        assertThat(underTest.findMatches(evenTrainRequest, null)).hasSize(1);
    }

    @Test
    void findMatches_requiresLocationIntersection() {
        RuIndicationRepository ruIndicationRepository = new InMemoryRuIndicationRepository();
        ruIndicationRepository.save(new RuIndication(null,
            new RuIndicationContent(null, DEFAULT_DE_CONTENT, null, null),
            new RuIndicationScope(
                Set.of(new CompanyCode("1111")),
                List.of(),
                Set.of(TafTapLocationReference.of("CH00050"))
            ),
            List.of(new RuIndicationPeriod(LocalDate.of(2026, 1, 1), LocalDate.of(2026, 1, 1), Set.of()))
        ));
        underTest = new RuIndicationMatchServiceImpl(ruIndicationRepository, new InMemorySpecialHolidayRepository());

        RuIndicationMatchesRequest requestWithoutOverlap = new RuIndicationMatchesRequest(
            new CompanyCode("1111"),
            999,
            LocalDate.of(2026, 1, 1),
            Set.of(TafTapLocationReference.of("CH00051"))
        );

        assertThat(underTest.findMatches(requestWithoutOverlap, null)).isEmpty();
    }

    @Test
    void findMatches_matchesMondayWeekdayForMondayScheduleSpecialHoliday() {
        RuIndicationRepository ruIndicationRepository = new InMemoryRuIndicationRepository();
        ruIndicationRepository.save(new RuIndication(null,
            new RuIndicationContent(null, DEFAULT_DE_CONTENT, null, null),
            new RuIndicationScope(
                Set.of(new CompanyCode("1111")),
                List.of(),
                Set.of(TafTapLocationReference.of("CH00070"))
            ),
            List.of(new RuIndicationPeriod(LocalDate.of(2026, 5, 1), LocalDate.of(2026, 5, 31), Set.of(DayOfWeek.MONDAY)))
        ));

        InMemorySpecialHolidayRepository specialHolidayRepository = new InMemorySpecialHolidayRepository();
        specialHolidayRepository.save(new SpecialHoliday(null, "Special Monday", LocalDate.of(2026, 5, 14), ScheduleType.MONDAY_SCHEDULE, Set.of(new CompanyCode("1111"))));

        underTest = new RuIndicationMatchServiceImpl(ruIndicationRepository, specialHolidayRepository);

        RuIndicationMatchesRequest request = new RuIndicationMatchesRequest(
            new CompanyCode("1111"),
            300,
            LocalDate.of(2026, 5, 14),
            Set.of(TafTapLocationReference.of("CH00070"))
        );

        assertThat(underTest.findMatches(request, null)).hasSize(1);
    }

    @Test
    void findMatches_matchesOriginalTrainForShadowRequestOnly() {
        RuIndicationRepository ruIndicationRepository = new InMemoryRuIndicationRepository();
        ruIndicationRepository.save(new RuIndication(null,
            new RuIndicationContent(null, DEFAULT_DE_CONTENT, null, null),
            new RuIndicationScope(
                Set.of(new CompanyCode("1111")),
                List.of(new TrainNumberFilterRequest("150", TrainNumberParity.ANY)),
                Set.of(TafTapLocationReference.of("CH00080"))
            ),
            List.of(new RuIndicationPeriod(LocalDate.of(2026, 1, 1), LocalDate.of(2026, 12, 31), Set.of()))
        ));
        ruIndicationRepository.save(new RuIndication(null,
            new RuIndicationContent(null, new RuIndicationEntry("Hinweis Shadow", "Text Shadow"), null, null),
            new RuIndicationScope(
                Set.of(new CompanyCode("1111")),
                List.of(new TrainNumberFilterRequest("70160", TrainNumberParity.ANY)),
                Set.of(TafTapLocationReference.of("CH00081"))
            ),
            List.of(new RuIndicationPeriod(LocalDate.of(2026, 1, 1), LocalDate.of(2026, 12, 31), Set.of()))
        ));

        underTest = new RuIndicationMatchServiceImpl(ruIndicationRepository, new InMemorySpecialHolidayRepository());

        RuIndicationMatchesRequest shadowTrainRequest = new RuIndicationMatchesRequest(
            new CompanyCode("1111"),
            70_150,
            LocalDate.of(2026, 3, 1),
            Set.of(TafTapLocationReference.of("CH00080"))
        );
        RuIndicationMatchesRequest originalTrainRequest = new RuIndicationMatchesRequest(
            new CompanyCode("1111"),
            160,
            LocalDate.of(2026, 3, 1),
            Set.of(TafTapLocationReference.of("CH00081"))
        );

        assertThat(underTest.findMatches(shadowTrainRequest, null)).hasSize(1);
        assertThat(underTest.findMatches(originalTrainRequest, null)).isEmpty();
    }

    @Test
    void findMatches_matchesShadowTrainAfterNormalization_whenFilterUsesRange() {
        RuIndicationRepository ruIndicationRepository = new InMemoryRuIndicationRepository();
        ruIndicationRepository.save(new RuIndication(null,
            new RuIndicationContent(null, DEFAULT_DE_CONTENT, null, null),
            new RuIndicationScope(
                Set.of(new CompanyCode("1111")),
                List.of(new TrainNumberFilterRequest("140-160", TrainNumberParity.ANY)),
                Set.of(TafTapLocationReference.of("CH00082"))
            ),
            List.of(new RuIndicationPeriod(LocalDate.of(2026, 1, 1), LocalDate.of(2026, 12, 31), Set.of()))
        ));

        underTest = new RuIndicationMatchServiceImpl(ruIndicationRepository, new InMemorySpecialHolidayRepository());

        RuIndicationMatchesRequest shadowTrainInRangeRequest = new RuIndicationMatchesRequest(
            new CompanyCode("1111"),
            70_150,
            LocalDate.of(2026, 3, 1),
            Set.of(TafTapLocationReference.of("CH00082"))
        );

        RuIndicationMatchesRequest shadowTrainOutOfRangeRequest = new RuIndicationMatchesRequest(
            new CompanyCode("1111"),
            70_170,
            LocalDate.of(2026, 3, 1),
            Set.of(TafTapLocationReference.of("CH00082"))
        );

        assertThat(underTest.findMatches(shadowTrainInRangeRequest, null)).hasSize(1);
        assertThat(underTest.findMatches(shadowTrainOutOfRangeRequest, null)).isEmpty();
    }

    @Test
    void findMatches_normalizesTrainNumbersInExtendedShadowWindow() {
        RuIndicationRepository ruIndicationRepository = new InMemoryRuIndicationRepository();
        ruIndicationRepository.save(new RuIndication(null,
            new RuIndicationContent(null, DEFAULT_DE_CONTENT, null, null),
            new RuIndicationScope(
                Set.of(new CompanyCode("1111")),
                List.of(new TrainNumberFilterRequest("1001", TrainNumberParity.ANY)),
                Set.of(TafTapLocationReference.of("CH00083"))
            ),
            List.of(new RuIndicationPeriod(LocalDate.of(2026, 1, 1), LocalDate.of(2026, 12, 31), Set.of()))
        ));
        ruIndicationRepository.save(new RuIndication(null,
            new RuIndicationContent(null, new RuIndicationEntry("No normalize high", "No normalize high"), null, null),
            new RuIndicationScope(
                Set.of(new CompanyCode("1111")),
                List.of(new TrainNumberFilterRequest("25999", TrainNumberParity.ANY)),
                Set.of(TafTapLocationReference.of("CH00084"))
            ),
            List.of(new RuIndicationPeriod(LocalDate.of(2026, 1, 1), LocalDate.of(2026, 12, 31), Set.of()))
        ));

        underTest = new RuIndicationMatchServiceImpl(ruIndicationRepository, new InMemorySpecialHolidayRepository());

        RuIndicationMatchesRequest requestAbove71000 = new RuIndicationMatchesRequest(
            new CompanyCode("1111"),
            71_001,
            LocalDate.of(2026, 3, 1),
            Set.of(TafTapLocationReference.of("CH00083"))
        );
        RuIndicationMatchesRequest requestAt95999 = new RuIndicationMatchesRequest(
            new CompanyCode("1111"),
            95_999,
            LocalDate.of(2026, 3, 1),
            Set.of(TafTapLocationReference.of("CH00084"))
        );

        assertThat(underTest.findMatches(requestAbove71000, null)).hasSize(1);
        assertThat(underTest.findMatches(requestAt95999, null)).hasSize(1);
    }
}



