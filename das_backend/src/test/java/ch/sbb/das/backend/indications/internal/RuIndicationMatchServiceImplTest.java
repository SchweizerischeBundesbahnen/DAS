package ch.sbb.das.backend.indications.internal;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.when;

import ch.sbb.das.backend.companies.CompanyCode;
import ch.sbb.das.backend.indications.internal.model.OperationalTrainNumberFilter;
import ch.sbb.das.backend.indications.internal.model.RuIndicationEntry;
import ch.sbb.das.backend.indications.internal.model.RuIndicationMatch;
import ch.sbb.das.backend.indications.internal.model.RuIndicationMatchesRequest;
import ch.sbb.das.backend.indications.internal.model.RuIndicationPeriod;
import ch.sbb.das.backend.indications.internal.model.ScheduleType;
import ch.sbb.das.backend.indications.internal.model.TrainNumberParity;
import ch.sbb.das.backend.locations.TafTapLocationReference;
import java.time.DayOfWeek;
import java.time.LocalDate;
import java.util.List;
import java.util.Set;
import org.junit.jupiter.api.Test;

class RuIndicationMatchServiceImplTest {

    private RuIndicationMatchServiceImpl underTest;

    @Test
    void findMatches_matchesAllCriteria_andGroupsRuIndicationContentsByLocation() {
        RuIndicationRepository ruIndicationRepository = mock(RuIndicationRepository.class);
        when(ruIndicationRepository.findAll()).thenReturn(List.of(
            new RuIndicationEntity(
                1, null,
                "Hinweis 1", "Text 1", null, null, null, null,
                Set.of(new CompanyCode("1111")),
                List.of(new OperationalTrainNumberFilter("100-200", TrainNumberParity.ANY)),
                List.of(TafTapLocationReference.of("CH00002"), TafTapLocationReference.of("CH00004")),
                List.of(new RuIndicationPeriod(LocalDate.of(2026, 5, 1), LocalDate.of(2026, 5, 31), Set.of(DayOfWeek.MONDAY)))
            ),
            new RuIndicationEntity(
                2, null,
                "Irrelevant", "Irrelevant", null, null, null, null,
                Set.of(new CompanyCode("2222")),
                List.of(new OperationalTrainNumberFilter("100-200", TrainNumberParity.ANY)),
                List.of(TafTapLocationReference.of("CH00002")),
                List.of(new RuIndicationPeriod(LocalDate.of(2026, 5, 1), LocalDate.of(2026, 5, 31), Set.of(DayOfWeek.MONDAY)))
            ),
            new RuIndicationEntity(
                3, null,
                "Hinweis 2", "Text 2", null, null, null, null,
                Set.of(new CompanyCode("1111")),
                List.of(),
                List.of(TafTapLocationReference.of("CH00002"), TafTapLocationReference.of("CH00003")),
                List.of(new RuIndicationPeriod(LocalDate.of(2026, 5, 1), LocalDate.of(2026, 5, 31), Set.of(DayOfWeek.MONDAY)))
            )
        ));

        SpecialHolidayRepository specialHolidayRepository = mock(SpecialHolidayRepository.class);
        when(specialHolidayRepository.findAllByDate(LocalDate.of(2026, 5, 11))).thenReturn(List.of());

        underTest = new RuIndicationMatchServiceImpl(ruIndicationRepository, specialHolidayRepository);

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
        RuIndicationRepository ruIndicationRepository = mock(RuIndicationRepository.class);
        when(ruIndicationRepository.findAll()).thenReturn(List.of(
            new RuIndicationEntity(
                1, null,
                "Hinweis", "Text", null, null, null, null,
                Set.of(new CompanyCode("1111")),
                List.of(new OperationalTrainNumberFilter("300-310", TrainNumberParity.EVEN)),
                List.of(TafTapLocationReference.of("CH00010")),
                List.of(new RuIndicationPeriod(LocalDate.of(2026, 1, 1), LocalDate.of(2026, 12, 31), Set.of(DayOfWeek.TUESDAY)))
            )
        ));

        SpecialHolidayRepository specialHolidayRepository = mock(SpecialHolidayRepository.class);
        when(specialHolidayRepository.findAllByDate(LocalDate.of(2026, 1, 6))).thenReturn(List.of());

        underTest = new RuIndicationMatchServiceImpl(ruIndicationRepository, specialHolidayRepository);

        RuIndicationMatchesRequest oddTrainRequest = new RuIndicationMatchesRequest(
            new CompanyCode("1111"), 301, LocalDate.of(2026, 1, 6),
            Set.of(TafTapLocationReference.of("CH00010"))
        );
        RuIndicationMatchesRequest evenTrainRequest = new RuIndicationMatchesRequest(
            new CompanyCode("1111"), 302, LocalDate.of(2026, 1, 6),
            Set.of(TafTapLocationReference.of("CH00010"))
        );

        assertThat(underTest.findMatches(oddTrainRequest, null)).isEmpty();
        assertThat(underTest.findMatches(evenTrainRequest, null)).hasSize(1);
    }

    @Test
    void findMatches_requiresLocationIntersection() {
        RuIndicationRepository ruIndicationRepository = mock(RuIndicationRepository.class);
        when(ruIndicationRepository.findAll()).thenReturn(List.of(
            new RuIndicationEntity(
                1, null,
                "Hinweis", "Text", null, null, null, null,
                Set.of(new CompanyCode("1111")),
                List.of(),
                List.of(TafTapLocationReference.of("CH00050")),
                List.of(new RuIndicationPeriod(LocalDate.of(2026, 1, 1), LocalDate.of(2026, 1, 1), Set.of()))
            )
        ));

        SpecialHolidayRepository specialHolidayRepository = mock(SpecialHolidayRepository.class);
        when(specialHolidayRepository.findAllByDate(LocalDate.of(2026, 1, 1))).thenReturn(List.of());

        underTest = new RuIndicationMatchServiceImpl(ruIndicationRepository, specialHolidayRepository);

        assertThat(underTest.findMatches(new RuIndicationMatchesRequest(
            new CompanyCode("1111"), 999, LocalDate.of(2026, 1, 1),
            Set.of(TafTapLocationReference.of("CH00051"))
        ), null)).isEmpty();
    }

    @Test
    void findMatches_matchesMondayWeekdayForMondayScheduleSpecialHoliday() {
        RuIndicationRepository ruIndicationRepository = mock(RuIndicationRepository.class);
        when(ruIndicationRepository.findAll()).thenReturn(List.of(
            new RuIndicationEntity(
                1, null,
                "Hinweis", "Text", null, null, null, null,
                Set.of(new CompanyCode("1111")),
                List.of(),
                List.of(TafTapLocationReference.of("CH00070")),
                List.of(new RuIndicationPeriod(LocalDate.of(2026, 5, 1), LocalDate.of(2026, 5, 31), Set.of(DayOfWeek.MONDAY)))
            )
        ));

        SpecialHolidayRepository specialHolidayRepository = mock(SpecialHolidayRepository.class);
        when(specialHolidayRepository.findAllByDate(LocalDate.of(2026, 5, 14))).thenReturn(List.of(
            new SpecialHolidayEntity(null, "Special Monday", LocalDate.of(2026, 5, 14), ScheduleType.MONDAY_SCHEDULE, Set.of(new CompanyCode("1111")))
        ));

        underTest = new RuIndicationMatchServiceImpl(ruIndicationRepository, specialHolidayRepository);

        assertThat(underTest.findMatches(new RuIndicationMatchesRequest(
            new CompanyCode("1111"), 300, LocalDate.of(2026, 5, 14),
            Set.of(TafTapLocationReference.of("CH00070"))
        ), null)).hasSize(1);
    }

    @Test
    void findMatches_matchesOriginalTrainForShadowRequestOnly() {
        RuIndicationRepository ruIndicationRepository = mock(RuIndicationRepository.class);
        when(ruIndicationRepository.findAll()).thenReturn(List.of(
            new RuIndicationEntity(
                1, null,
                "Hinweis", "Text", null, null, null, null,
                Set.of(new CompanyCode("1111")),
                List.of(new OperationalTrainNumberFilter("150", TrainNumberParity.ANY)),
                List.of(TafTapLocationReference.of("CH00080")),
                List.of(new RuIndicationPeriod(LocalDate.of(2026, 1, 1), LocalDate.of(2026, 12, 31), Set.of()))
            ),
            new RuIndicationEntity(
                2, null,
                "Hinweis Shadow", "Text Shadow", null, null, null, null,
                Set.of(new CompanyCode("1111")),
                List.of(new OperationalTrainNumberFilter("70160", TrainNumberParity.ANY)),
                List.of(TafTapLocationReference.of("CH00081")),
                List.of(new RuIndicationPeriod(LocalDate.of(2026, 1, 1), LocalDate.of(2026, 12, 31), Set.of()))
            )
        ));

        SpecialHolidayRepository specialHolidayRepository = mock(SpecialHolidayRepository.class);
        when(specialHolidayRepository.findAllByDate(LocalDate.of(2026, 3, 1))).thenReturn(List.of());

        underTest = new RuIndicationMatchServiceImpl(ruIndicationRepository, specialHolidayRepository);

        assertThat(underTest.findMatches(new RuIndicationMatchesRequest(
            new CompanyCode("1111"), 70_150, LocalDate.of(2026, 3, 1),
            Set.of(TafTapLocationReference.of("CH00080"))
        ), null)).hasSize(1);

        assertThat(underTest.findMatches(new RuIndicationMatchesRequest(
            new CompanyCode("1111"), 160, LocalDate.of(2026, 3, 1),
            Set.of(TafTapLocationReference.of("CH00081"))
        ), null)).isEmpty();
    }

    @Test
    void findMatches_matchesShadowTrainAfterNormalization_whenFilterUsesRange() {
        RuIndicationRepository ruIndicationRepository = mock(RuIndicationRepository.class);
        when(ruIndicationRepository.findAll()).thenReturn(List.of(
            new RuIndicationEntity(
                1, null,
                "Hinweis", "Text", null, null, null, null,
                Set.of(new CompanyCode("1111")),
                List.of(new OperationalTrainNumberFilter("140-160", TrainNumberParity.ANY)),
                List.of(TafTapLocationReference.of("CH00082")),
                List.of(new RuIndicationPeriod(LocalDate.of(2026, 1, 1), LocalDate.of(2026, 12, 31), Set.of()))
            )
        ));

        SpecialHolidayRepository specialHolidayRepository = mock(SpecialHolidayRepository.class);
        when(specialHolidayRepository.findAllByDate(LocalDate.of(2026, 3, 1))).thenReturn(List.of());

        underTest = new RuIndicationMatchServiceImpl(ruIndicationRepository, specialHolidayRepository);

        assertThat(underTest.findMatches(new RuIndicationMatchesRequest(
            new CompanyCode("1111"), 70_150, LocalDate.of(2026, 3, 1),
            Set.of(TafTapLocationReference.of("CH00082"))
        ), null)).hasSize(1);

        assertThat(underTest.findMatches(new RuIndicationMatchesRequest(
            new CompanyCode("1111"), 70_170, LocalDate.of(2026, 3, 1),
            Set.of(TafTapLocationReference.of("CH00082"))
        ), null)).isEmpty();
    }

    @Test
    void findMatches_normalizesTrainNumbersInExtendedShadowWindow() {
        RuIndicationRepository ruIndicationRepository = mock(RuIndicationRepository.class);
        when(ruIndicationRepository.findAll()).thenReturn(List.of(
            new RuIndicationEntity(
                1, null,
                "Hinweis", "Text", null, null, null, null,
                Set.of(new CompanyCode("1111")),
                List.of(new OperationalTrainNumberFilter("1001", TrainNumberParity.ANY)),
                List.of(TafTapLocationReference.of("CH00083")),
                List.of(new RuIndicationPeriod(LocalDate.of(2026, 1, 1), LocalDate.of(2026, 12, 31), Set.of()))
            ),
            new RuIndicationEntity(
                2, null,
                "No normalize high", "No normalize high", null, null, null, null,
                Set.of(new CompanyCode("1111")),
                List.of(new OperationalTrainNumberFilter("25999", TrainNumberParity.ANY)),
                List.of(TafTapLocationReference.of("CH00084")),
                List.of(new RuIndicationPeriod(LocalDate.of(2026, 1, 1), LocalDate.of(2026, 12, 31), Set.of()))
            )
        ));

        SpecialHolidayRepository specialHolidayRepository = mock(SpecialHolidayRepository.class);
        when(specialHolidayRepository.findAllByDate(LocalDate.of(2026, 3, 1))).thenReturn(List.of());

        underTest = new RuIndicationMatchServiceImpl(ruIndicationRepository, specialHolidayRepository);

        assertThat(underTest.findMatches(new RuIndicationMatchesRequest(
            new CompanyCode("1111"), 71_001, LocalDate.of(2026, 3, 1),
            Set.of(TafTapLocationReference.of("CH00083"))
        ), null)).hasSize(1);

        assertThat(underTest.findMatches(new RuIndicationMatchesRequest(
            new CompanyCode("1111"), 95_999, LocalDate.of(2026, 3, 1),
            Set.of(TafTapLocationReference.of("CH00084"))
        ), null)).hasSize(1);
    }
}
