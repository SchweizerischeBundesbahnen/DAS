package ch.sbb.das.backend.trainjourneyplan;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import ch.sbb.das.backend.common.DateTimeUtil;
import ch.sbb.das.backend.common.error.BadRequestException;
import ch.sbb.das.backend.common.error.NotFoundException;
import ch.sbb.das.backend.companies.Company;
import ch.sbb.das.backend.companies.CompanyCode;
import ch.sbb.das.backend.companies.CompanyService;
import ch.sbb.das.backend.companies.CompanyShortName;
import ch.sbb.das.backend.trainjourneyplan.infrastructure.CompanyMatch;
import ch.sbb.das.backend.trainjourneyplan.infrastructure.TrainIdentificationRepository;
import ch.sbb.das.backend.trainjourneyplan.infrastructure.model.entities.TrainIdentificationEntity;
import java.time.Clock;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.OffsetDateTime;
import java.time.ZoneOffset;
import java.time.ZonedDateTime;
import java.util.List;
import java.util.Optional;
import java.util.Set;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.ArgumentCaptor;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.http.HttpStatus;
import org.springframework.test.util.ReflectionTestUtils;

@ExtendWith(MockitoExtension.class)
class TrainIdentificationServiceTest {

    private static final ZonedDateTime FIXED_NOW = ZonedDateTime.of(LocalDateTime.of(2026, 3, 10, 12, 0), DateTimeUtil.SWISS_ZONE);
    private static final LocalDate TODAY = FIXED_NOW.toLocalDate();
    private static final LocalDate TOMORROW = TODAY.plusDays(1);
    private static final int HOURS_BEFORE_DEPARTURE = 4;

    @Mock
    private TrainIdentificationRepository trainIdentificationRepository;

    @Mock
    private CompanyService companyService;

    private TrainIdentificationService underTest;

    @BeforeEach
    void setUp() {
        underTest = serviceAt(FIXED_NOW);
    }

    private TrainIdentificationService serviceAt(ZonedDateTime now) {
        TrainIdentificationService service = new TrainIdentificationService(trainIdentificationRepository, companyService, Clock.fixed(now.toInstant(), DateTimeUtil.SWISS_ZONE));
        ReflectionTestUtils.setField(service, "hoursBeforeDeparture", HOURS_BEFORE_DEPARTURE);
        return service;
    }

    @Test
    void findCompaniesByStartDatesAndTrainNumber_returnsCompaniesWithDates() {
        // Given
        OffsetDateTime departure = FIXED_NOW.toOffsetDateTime().plusMinutes(30);
        LocalDate startDate = departure.atZoneSameInstant(DateTimeUtil.SWISS_ZONE).toLocalDate();
        Set<LocalDate> startDates = Set.of(startDate);
        String trainNumber = "728";

        TrainIdentificationEntity entity = TrainIdentificationEntity.builder()
            .id(1)
            .operationalTrainNumber(trainNumber)
            .startDateTime(departure)
            .companies("MOCK_A,MOCK_B")
            .build();

        when(trainIdentificationRepository.findAllByStartDateTimeRangeAndOperationalTrainNumber(any(), any(), eq(trainNumber)))
            .thenReturn(List.of(entity));

        when(companyService.findCompanyCodeByShortName(new CompanyShortName("MOCK_A")))
            .thenReturn(Optional.of(new CompanyCode("1111")));
        when(companyService.findCompanyCodeByShortName(new CompanyShortName("MOCK_B")))
            .thenReturn(Optional.of(new CompanyCode("2222")));

        Company companyA = new Company(new CompanyCode("1111"), new CompanyShortName("MOCK_A"));
        Company companyB = new Company(new CompanyCode("2222"), new CompanyShortName("MOCK_B"));
        when(companyService.getAllCompanies()).thenReturn(List.of(companyA, companyB));

        // When
        List<CompanyMatch> result = underTest
            .findCompaniesByStartDatesAndTrainNumber(startDates, trainNumber);

        // Then
        assertThat(result).hasSize(2);
        assertThat(result).extracting(item -> item.company().code())
            .containsExactlyInAnyOrder(new CompanyCode("1111"), new CompanyCode("2222"));
        assertThat(result).allMatch(item -> item.startDate().equals(startDate));
    }

    @Test
    void findCompaniesByStartDatesAndTrainNumber_multipleEntitiesWithinWindow_returnsAllSorted() {
        // Given
        OffsetDateTime departure1 = FIXED_NOW.toOffsetDateTime().plusHours(1);
        OffsetDateTime departure2 = FIXED_NOW.toOffsetDateTime().plusHours(3);
        LocalDate startDate = departure1.atZoneSameInstant(DateTimeUtil.SWISS_ZONE).toLocalDate();
        Set<LocalDate> startDates = Set.of(startDate);
        String trainNumber = "728";

        TrainIdentificationEntity entity1 = TrainIdentificationEntity.builder()
            .id(1)
            .operationalTrainNumber(trainNumber)
            .startDateTime(departure1)
            .companies("MOCK_A")
            .build();

        TrainIdentificationEntity entity2 = TrainIdentificationEntity.builder()
            .id(2)
            .operationalTrainNumber(trainNumber)
            .startDateTime(departure2)
            .companies("MOCK_B")
            .build();

        when(trainIdentificationRepository.findAllByStartDateTimeRangeAndOperationalTrainNumber(any(), any(), eq(trainNumber)))
            .thenReturn(List.of(entity1, entity2));

        when(companyService.findCompanyCodeByShortName(new CompanyShortName("MOCK_A")))
            .thenReturn(Optional.of(new CompanyCode("1111")));
        when(companyService.findCompanyCodeByShortName(new CompanyShortName("MOCK_B")))
            .thenReturn(Optional.of(new CompanyCode("2222")));

        Company companyA = new Company(new CompanyCode("1111"), new CompanyShortName("MOCK_A"));
        Company companyB = new Company(new CompanyCode("2222"), new CompanyShortName("MOCK_B"));
        when(companyService.getAllCompanies()).thenReturn(List.of(companyA, companyB));

        // When
        List<CompanyMatch> result = underTest
            .findCompaniesByStartDatesAndTrainNumber(startDates, trainNumber);

        // Then
        assertThat(result).extracting(item -> item.company().code())
            .containsExactlyInAnyOrder(new CompanyCode("1111"), new CompanyCode("2222"));
    }

    @Test
    void findCompaniesByStartDatesAndTrainNumber_unknownCompany_isFiltered() {
        // Given
        OffsetDateTime departure = FIXED_NOW.toOffsetDateTime().plusMinutes(30);
        LocalDate startDate = departure.atZoneSameInstant(DateTimeUtil.SWISS_ZONE).toLocalDate();
        Set<LocalDate> startDates = Set.of(startDate);
        String trainNumber = "728";

        TrainIdentificationEntity entity = TrainIdentificationEntity.builder()
            .id(1)
            .operationalTrainNumber(trainNumber)
            .startDateTime(departure)
            .companies("MOCK_A,UNKNOWN")
            .build();

        when(trainIdentificationRepository.findAllByStartDateTimeRangeAndOperationalTrainNumber(any(), any(), eq(trainNumber)))
            .thenReturn(List.of(entity));

        when(companyService.findCompanyCodeByShortName(new CompanyShortName("MOCK_A")))
            .thenReturn(Optional.of(new CompanyCode("1111")));
        when(companyService.findCompanyCodeByShortName(new CompanyShortName("UNKNOWN")))
            .thenReturn(Optional.empty());

        Company companyA = new Company(new CompanyCode("1111"), new CompanyShortName("MOCK_A"));
        when(companyService.getAllCompanies()).thenReturn(List.of(companyA));

        // When
        List<CompanyMatch> result = underTest
            .findCompaniesByStartDatesAndTrainNumber(startDates, trainNumber);

        // Then
        assertThat(result).hasSize(1);
        assertThat(result.get(0).company().code()).isEqualTo(new CompanyCode("1111"));
        assertThat(result.get(0).startDate()).isEqualTo(startDate);
    }

    @Test
    void findCompaniesByStartDatesAndTrainNumber_allCompaniesUnsupported_returnsEmpty() {
        // Given
        OffsetDateTime departure = FIXED_NOW.toOffsetDateTime().plusMinutes(30);
        LocalDate startDate = departure.atZoneSameInstant(DateTimeUtil.SWISS_ZONE).toLocalDate();
        Set<LocalDate> startDates = Set.of(startDate);
        String trainNumber = "728";

        TrainIdentificationEntity entity = TrainIdentificationEntity.builder()
            .id(1)
            .operationalTrainNumber(trainNumber)
            .startDateTime(departure)
            .companies("FOREIGN_RU,OTHER_UNKNOWN")
            .build();

        when(trainIdentificationRepository.findAllByStartDateTimeRangeAndOperationalTrainNumber(any(), any(), eq(trainNumber)))
            .thenReturn(List.of(entity));

        when(companyService.findCompanyCodeByShortName(new CompanyShortName("FOREIGN_RU")))
            .thenReturn(Optional.empty());
        when(companyService.findCompanyCodeByShortName(new CompanyShortName("OTHER_UNKNOWN")))
            .thenReturn(Optional.empty());

        when(companyService.getAllCompanies()).thenReturn(List.of());

        // When / Then
        assertThatThrownBy(() -> underTest.findCompaniesByStartDatesAndTrainNumber(startDates, trainNumber))
            .isInstanceOf(NotFoundException.class);
    }

    @Test
    void getTrainIdentificationsBetween_returnsFilteredAndSortedResults() {
        // Given
        OffsetDateTime after = OffsetDateTime.of(2025, 6, 15, 0, 0, 0, 0, ZoneOffset.UTC);
        OffsetDateTime before = OffsetDateTime.of(2025, 6, 16, 0, 0, 0, 0, ZoneOffset.UTC);

        TrainIdentificationEntity entity1 = TrainIdentificationEntity.builder()
            .id(1)
            .operationalTrainNumber("728")
            .startDateTime(OffsetDateTime.of(2025, 6, 15, 14, 0, 0, 0, ZoneOffset.UTC))
            .companies("MOCK_A")
            .build();

        TrainIdentificationEntity entity2 = TrainIdentificationEntity.builder()
            .id(2)
            .operationalTrainNumber("100")
            .startDateTime(OffsetDateTime.of(2025, 6, 15, 8, 0, 0, 0, ZoneOffset.UTC))
            .companies("MOCK_B")
            .build();

        when(trainIdentificationRepository.findAllByStartDateTimeAfterAndStartDateTimeBefore(after, before))
            .thenReturn(List.of(entity1, entity2));

        when(companyService.getAllCompanies()).thenReturn(List.of(
            new Company(new CompanyCode("1111"), new CompanyShortName("MOCK_A")),
            new Company(new CompanyCode("2222"), new CompanyShortName("MOCK_B"))));

        // When
        List<TrainIdentification> result = underTest.getTrainIdentificationsBetween(after, before);

        // Then
        assertThat(result).hasSize(2);
        assertThat(result.get(0).operationalTrainNumber()).isEqualTo("100");
        assertThat(result.get(0).companies()).containsExactly(new CompanyCode("2222"));
        assertThat(result.get(1).operationalTrainNumber()).isEqualTo("728");
        assertThat(result.get(1).companies()).containsExactly(new CompanyCode("1111"));
        // companies are resolved once per call, not once per train
        verify(companyService, never()).findCompanyCodeByShortName(any());
    }

    @Test
    void getTrainIdentificationsBetween_filtersOutEntriesWithNoResolvedCompanies() {
        // Given
        OffsetDateTime after = OffsetDateTime.of(2025, 6, 15, 0, 0, 0, 0, ZoneOffset.UTC);
        OffsetDateTime before = OffsetDateTime.of(2025, 6, 16, 0, 0, 0, 0, ZoneOffset.UTC);

        TrainIdentificationEntity entity = TrainIdentificationEntity.builder()
            .id(1)
            .operationalTrainNumber("728")
            .startDateTime(OffsetDateTime.of(2025, 6, 15, 8, 0, 0, 0, ZoneOffset.UTC))
            .companies("UNKNOWN")
            .build();

        when(trainIdentificationRepository.findAllByStartDateTimeAfterAndStartDateTimeBefore(after, before))
            .thenReturn(List.of(entity));

        when(companyService.getAllCompanies()).thenReturn(List.of(new Company(new CompanyCode("1111"), new CompanyShortName("MOCK_A"))));

        // When
        List<TrainIdentification> result = underTest.getTrainIdentificationsBetween(after, before);

        // Then
        assertThat(result).isEmpty();
    }

    @Test
    void findCompaniesByStartDatesAndTrainNumber_queriesFromRequestedStartUpToLatestDeparture() {
        // Given
        LocalDate requestedDay = TODAY;
        Set<LocalDate> startDates = Set.of(requestedDay);
        String trainNumber = "728";
        OffsetDateTime expectedFrom = requestedDay.atStartOfDay(DateTimeUtil.SWISS_ZONE).toOffsetDateTime();

        when(trainIdentificationRepository.findAllByStartDateTimeRangeAndOperationalTrainNumber(any(), any(), eq(trainNumber))).thenReturn(List.of());

        // When
        assertThatThrownBy(() -> underTest.findCompaniesByStartDatesAndTrainNumber(startDates, trainNumber)).isInstanceOf(NotFoundException.class);

        // Then
        ArgumentCaptor<OffsetDateTime> from = ArgumentCaptor.forClass(OffsetDateTime.class);
        ArgumentCaptor<OffsetDateTime> to = ArgumentCaptor.forClass(OffsetDateTime.class);
        verify(trainIdentificationRepository).findAllByStartDateTimeRangeAndOperationalTrainNumber(from.capture(), to.capture(), eq(trainNumber));

        assertThat(from.getValue()).isEqualTo(expectedFrom);
        assertThat(to.getValue()).isEqualTo(OffsetDateTime.parse("2026-03-10T16:00+01:00"));
    }

    @Test
    void findCompaniesByStartDatesAndTrainNumber_narrowsToRequestedStartDates() {
        // Given
        LocalDate requestedDay = TODAY;
        LocalDate otherDay = requestedDay.plusDays(1);
        Set<LocalDate> startDates = Set.of(requestedDay);
        String trainNumber = "728";

        TrainIdentificationEntity requestedEntity = TrainIdentificationEntity.builder()
            .id(1)
            .operationalTrainNumber(trainNumber)
            .startDateTime(requestedDay.atTime(8, 0).atZone(DateTimeUtil.SWISS_ZONE).toOffsetDateTime())
            .companies("MOCK_A")
            .build();
        TrainIdentificationEntity otherDayEntity = TrainIdentificationEntity.builder()
            .id(2)
            .operationalTrainNumber(trainNumber)
            .startDateTime(otherDay.atTime(8, 0).atZone(DateTimeUtil.SWISS_ZONE).toOffsetDateTime())
            .companies("MOCK_B")
            .build();

        when(trainIdentificationRepository.findAllByStartDateTimeRangeAndOperationalTrainNumber(any(), any(), eq(trainNumber)))
            .thenReturn(List.of(requestedEntity, otherDayEntity));
        when(companyService.findCompanyCodeByShortName(new CompanyShortName("MOCK_A")))
            .thenReturn(Optional.of(new CompanyCode("1111")));
        Company companyA = new Company(new CompanyCode("1111"), new CompanyShortName("MOCK_A"));
        when(companyService.getAllCompanies()).thenReturn(List.of(companyA));

        // When
        List<CompanyMatch> result = underTest.findCompaniesByStartDatesAndTrainNumber(startDates, trainNumber);

        // Then
        assertThat(result).hasSize(1);
        assertThat(result.get(0).company().code()).isEqualTo(new CompanyCode("1111"));
        assertThat(result.get(0).startDate()).isEqualTo(requestedDay);
    }

    @Test
    void findCompaniesByStartDatesAndTrainNumber_companyResolvedButNotInGetAllCompanies_isFiltered() {
        // Given
        OffsetDateTime departure = FIXED_NOW.toOffsetDateTime().plusMinutes(30);
        LocalDate startDate = departure.atZoneSameInstant(DateTimeUtil.SWISS_ZONE).toLocalDate();
        Set<LocalDate> startDates = Set.of(startDate);
        String trainNumber = "728";

        TrainIdentificationEntity entity = TrainIdentificationEntity.builder()
            .id(1)
            .operationalTrainNumber(trainNumber)
            .startDateTime(departure)
            .companies("MOCK_A")
            .build();

        when(trainIdentificationRepository.findAllByStartDateTimeRangeAndOperationalTrainNumber(any(), any(), eq(trainNumber)))
            .thenReturn(List.of(entity));

        when(companyService.findCompanyCodeByShortName(new CompanyShortName("MOCK_A")))
            .thenReturn(Optional.of(new CompanyCode("1111")));

        when(companyService.getAllCompanies()).thenReturn(List.of());

        // When / Then
        assertThatThrownBy(() -> underTest.findCompaniesByStartDatesAndTrainNumber(startDates, trainNumber))
            .isInstanceOf(NotFoundException.class);
    }

    @Test
    void findCompaniesByStartDatesAndTrainNumber_startDateYesterday_isAccepted() {
        // Given
        LocalDate yesterday = TODAY.minusDays(1);
        Set<LocalDate> startDates = Set.of(yesterday);
        String trainNumber = "728";

        when(trainIdentificationRepository.findAllByStartDateTimeRangeAndOperationalTrainNumber(any(), any(), eq(trainNumber)))
            .thenReturn(List.of());

        // When / Then
        assertThatThrownBy(() -> underTest.findCompaniesByStartDatesAndTrainNumber(startDates, trainNumber))
            .isInstanceOf(NotFoundException.class);
    }

    @Test
    void findCompaniesByStartDatesAndTrainNumber_startDateTomorrow_isAccepted() {
        // Given
        Set<LocalDate> startDates = Set.of(TOMORROW);
        String trainNumber = "728";

        when(trainIdentificationRepository.findAllByStartDateTimeRangeAndOperationalTrainNumber(any(), any(), eq(trainNumber)))
            .thenReturn(List.of());

        // When / Then
        assertThatThrownBy(() -> underTest.findCompaniesByStartDatesAndTrainNumber(startDates, trainNumber))
            .isInstanceOf(NotFoundException.class);
    }

    @Test
    void findCompaniesByStartDatesAndTrainNumber_startDateTwoDaysAhead_throwsBadRequest() {
        // Given
        Set<LocalDate> startDates = Set.of(TODAY.plusDays(2));
        String trainNumber = "728";

        // When / Then
        assertThatThrownBy(() -> underTest.findCompaniesByStartDatesAndTrainNumber(startDates, trainNumber))
            .isInstanceOf(BadRequestException.class)
            .extracting(ex -> ((BadRequestException) ex).getStatusCode())
            .isEqualTo(HttpStatus.BAD_REQUEST);
    }

    @Test
    void findCompaniesByStartDatesAndTrainNumber_oneOfMultipleStartDatesOutOfRange_throwsBadRequest() {
        // Given
        Set<LocalDate> startDates = Set.of(TODAY, TODAY.plusDays(5));
        String trainNumber = "728";

        // When / Then
        assertThatThrownBy(() -> underTest.findCompaniesByStartDatesAndTrainNumber(startDates, trainNumber))
            .isInstanceOf(BadRequestException.class)
            .extracting(ex -> ((BadRequestException) ex).getStatusCode())
            .isEqualTo(HttpStatus.BAD_REQUEST);
    }

    @Test
    void findCompaniesByStartDatesAndTrainNumber_lateEvening_departureAfterMidnightBelongsToNextDay() {
        // Given
        TrainIdentificationService lateEvening = serviceAt(TODAY.atTime(22, 30).atZone(DateTimeUtil.SWISS_ZONE));
        String trainNumber = "728";

        TrainIdentificationEntity entity = TrainIdentificationEntity.builder()
            .id(1)
            .operationalTrainNumber(trainNumber)
            .startDateTime(OffsetDateTime.parse("2026-03-11T01:30+01:00"))
            .companies("MOCK_A")
            .build();

        when(trainIdentificationRepository.findAllByStartDateTimeRangeAndOperationalTrainNumber(
            OffsetDateTime.parse("2026-03-10T00:00+01:00"), OffsetDateTime.parse("2026-03-11T02:30+01:00"), trainNumber))
            .thenReturn(List.of(entity));
        when(companyService.findCompanyCodeByShortName(new CompanyShortName("MOCK_A")))
            .thenReturn(Optional.of(new CompanyCode("1111")));
        when(companyService.getAllCompanies()).thenReturn(List.of(new Company(new CompanyCode("1111"), new CompanyShortName("MOCK_A"))));

        // When
        List<CompanyMatch> todayAndTomorrow = lateEvening.findCompaniesByStartDatesAndTrainNumber(Set.of(TODAY, TOMORROW), trainNumber);

        // Then
        assertThatThrownBy(() -> lateEvening.findCompaniesByStartDatesAndTrainNumber(Set.of(TODAY), trainNumber))
            .isInstanceOf(NotFoundException.class);
        assertThat(todayAndTomorrow).extracting(CompanyMatch::startDate).containsExactly(TOMORROW);
    }

    @Test
    void findCompaniesByStartDatesAndTrainNumber_shortlyBeforeMidnight_acceptsYesterdayToTomorrowOnly() {
        // Given
        TrainIdentificationService beforeMidnight = serviceAt(TODAY.atTime(23, 45).atZone(DateTimeUtil.SWISS_ZONE));
        String trainNumber = "728";

        when(trainIdentificationRepository.findAllByStartDateTimeRangeAndOperationalTrainNumber(any(), any(), eq(trainNumber)))
            .thenReturn(List.of());

        // When / Then
        assertThatThrownBy(() -> beforeMidnight.findCompaniesByStartDatesAndTrainNumber(Set.of(LocalDate.parse("2026-03-09")), trainNumber))
            .isInstanceOf(NotFoundException.class);
        assertThatThrownBy(() -> beforeMidnight.findCompaniesByStartDatesAndTrainNumber(Set.of(LocalDate.parse("2026-03-11")), trainNumber))
            .isInstanceOf(NotFoundException.class);
        assertThatThrownBy(() -> beforeMidnight.findCompaniesByStartDatesAndTrainNumber(Set.of(LocalDate.parse("2026-03-12")), trainNumber))
            .isInstanceOf(BadRequestException.class);
        assertThatThrownBy(() -> beforeMidnight.findCompaniesByStartDatesAndTrainNumber(Set.of(LocalDate.parse("2026-03-08")), trainNumber))
            .isInstanceOf(BadRequestException.class);
    }

    @Test
    void findCompaniesByStartDatesAndTrainNumber_shortlyAfterMidnight_findsDepartureOfYesterday() {
        // Given
        TrainIdentificationService afterMidnight = serviceAt(TOMORROW.atTime(0, 15).atZone(DateTimeUtil.SWISS_ZONE));
        String trainNumber = "728";

        TrainIdentificationEntity entity = TrainIdentificationEntity.builder()
            .id(1)
            .operationalTrainNumber(trainNumber)
            .startDateTime(OffsetDateTime.parse("2026-03-10T23:50+01:00"))
            .companies("MOCK_A")
            .build();

        when(trainIdentificationRepository.findAllByStartDateTimeRangeAndOperationalTrainNumber(
            OffsetDateTime.parse("2026-03-10T00:00+01:00"), OffsetDateTime.parse("2026-03-11T04:15+01:00"), trainNumber))
            .thenReturn(List.of(entity));
        when(companyService.findCompanyCodeByShortName(new CompanyShortName("MOCK_A")))
            .thenReturn(Optional.of(new CompanyCode("1111")));
        when(companyService.getAllCompanies()).thenReturn(List.of(new Company(new CompanyCode("1111"), new CompanyShortName("MOCK_A"))));

        // When
        List<CompanyMatch> result = afterMidnight.findCompaniesByStartDatesAndTrainNumber(Set.of(TODAY), trainNumber);

        // Then
        assertThat(result).extracting(CompanyMatch::startDate).containsExactly(LocalDate.parse("2026-03-10"));
    }

    @Test
    void findCompaniesByStartDatesAndTrainNumber_springForward_latestDepartureIsHoursBeforeDepartureInRealTime() {
        // Given
        TrainIdentificationService beforeSwitch = serviceAt(ZonedDateTime.of(LocalDateTime.of(2026, 3, 28, 23, 30), DateTimeUtil.SWISS_ZONE));
        String trainNumber = "728";

        when(trainIdentificationRepository.findAllByStartDateTimeRangeAndOperationalTrainNumber(any(), any(), eq(trainNumber)))
            .thenReturn(List.of());

        // When
        assertThatThrownBy(() -> beforeSwitch.findCompaniesByStartDatesAndTrainNumber(Set.of(LocalDate.parse("2026-03-28")), trainNumber))
            .isInstanceOf(NotFoundException.class);

        // Then
        ArgumentCaptor<OffsetDateTime> to = ArgumentCaptor.forClass(OffsetDateTime.class);
        verify(trainIdentificationRepository).findAllByStartDateTimeRangeAndOperationalTrainNumber(any(), to.capture(), eq(trainNumber));
        // 4 real hours after 23:30 CET is 04:30 CEST, while the wall clock moved 5 hours
        assertThat(to.getValue()).isEqualTo(OffsetDateTime.parse("2026-03-29T04:30+02:00"));
    }
}
