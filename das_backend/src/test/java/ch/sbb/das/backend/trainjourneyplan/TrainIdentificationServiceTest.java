package ch.sbb.das.backend.trainjourneyplan;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import ch.sbb.das.backend.common.DateTimeUtil;
import ch.sbb.das.backend.companies.Company;
import ch.sbb.das.backend.companies.CompanyCode;
import ch.sbb.das.backend.companies.CompanyService;
import ch.sbb.das.backend.companies.CompanyShortName;
import ch.sbb.das.backend.trainjourneyplan.infrastructure.CompanyMatch;
import ch.sbb.das.backend.trainjourneyplan.infrastructure.TrainIdentificationRepository;
import ch.sbb.das.backend.trainjourneyplan.infrastructure.model.entities.TrainIdentificationEntity;
import java.time.LocalDate;
import java.time.OffsetDateTime;
import java.time.ZoneOffset;
import java.util.List;
import java.util.Optional;
import java.util.Set;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.ArgumentCaptor;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.http.HttpStatus;
import org.springframework.test.util.ReflectionTestUtils;
import org.springframework.web.server.ResponseStatusException;

@ExtendWith(MockitoExtension.class)
class TrainIdentificationServiceTest {

    private static final LocalDate TODAY = DateTimeUtil.today();
    private static final LocalDate TOMORROW = TODAY.plusDays(1);
    private static final int HOURS_BEFORE_DEPARTURE = 4;

    @Mock
    private TrainIdentificationRepository trainIdentificationRepository;

    @Mock
    private CompanyService companyService;

    @InjectMocks
    private TrainIdentificationService underTest;

    @BeforeEach
    void setUp() {
        ReflectionTestUtils.setField(underTest, "hoursBeforeDeparture", HOURS_BEFORE_DEPARTURE);
    }

    @Test
    void findCompaniesByStartDatesAndTrainNumber_returnsCompaniesWithDates() {
        // Given
        OffsetDateTime departure = DateTimeUtil.now().plusMinutes(30);
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
        OffsetDateTime departure1 = DateTimeUtil.now().plusHours(1);
        OffsetDateTime departure2 = DateTimeUtil.now().plusHours(3);
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
        OffsetDateTime departure = DateTimeUtil.now().plusMinutes(30);
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
        OffsetDateTime departure = DateTimeUtil.now().plusMinutes(30);
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

        // When
        List<CompanyMatch> result = underTest
            .findCompaniesByStartDatesAndTrainNumber(startDates, trainNumber);

        // Then
        assertThat(result).isEmpty();
    }

    @Test
    void getNewTrainIdentificationsBetween_returnsFilteredAndSortedResults() {
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

        when(trainIdentificationRepository.findAllByStartDateTimeAfterAndStartDateTimeBeforeAndPreloadedAtNull(after, before))
            .thenReturn(List.of(entity1, entity2));

        when(companyService.findCompanyCodeByShortName(new CompanyShortName("MOCK_A")))
            .thenReturn(Optional.of(new CompanyCode("1111")));
        when(companyService.findCompanyCodeByShortName(new CompanyShortName("MOCK_B")))
            .thenReturn(Optional.of(new CompanyCode("2222")));

        // When
        List<TrainIdentification> result = underTest.getNewTrainIdentificationsBetween(after, before);

        // Then
        assertThat(result).hasSize(2);
        assertThat(result.get(0).operationalTrainNumber()).isEqualTo("100");
        assertThat(result.get(1).operationalTrainNumber()).isEqualTo("728");
    }

    @Test
    void getNewTrainIdentificationsBetween_filtersOutEntriesWithNoResolvedCompanies() {
        // Given
        OffsetDateTime after = OffsetDateTime.of(2025, 6, 15, 0, 0, 0, 0, ZoneOffset.UTC);
        OffsetDateTime before = OffsetDateTime.of(2025, 6, 16, 0, 0, 0, 0, ZoneOffset.UTC);

        TrainIdentificationEntity entity = TrainIdentificationEntity.builder()
            .id(1)
            .operationalTrainNumber("728")
            .startDateTime(OffsetDateTime.of(2025, 6, 15, 8, 0, 0, 0, ZoneOffset.UTC))
            .companies("UNKNOWN")
            .build();

        when(trainIdentificationRepository.findAllByStartDateTimeAfterAndStartDateTimeBeforeAndPreloadedAtNull(after, before))
            .thenReturn(List.of(entity));

        when(companyService.findCompanyCodeByShortName(new CompanyShortName("UNKNOWN")))
            .thenReturn(Optional.empty());

        // When
        List<TrainIdentification> result = underTest.getNewTrainIdentificationsBetween(after, before);

        // Then
        assertThat(result).isEmpty();
    }

    @Test
    void findCompaniesByStartDatesAndTrainNumber_queriesFromRequestedStartUpToLatestDeparture() {
        // Given
        LocalDate requestedDay = DateTimeUtil.today();
        Set<LocalDate> startDates = Set.of(requestedDay);
        String trainNumber = "728";
        OffsetDateTime expectedFrom = requestedDay.atStartOfDay(DateTimeUtil.SWISS_ZONE).toOffsetDateTime();

        when(trainIdentificationRepository.findAllByStartDateTimeRangeAndOperationalTrainNumber(any(), any(), eq(trainNumber))).thenReturn(List.of());

        // When
        OffsetDateTime beforeCall = DateTimeUtil.now();
        underTest.findCompaniesByStartDatesAndTrainNumber(startDates, trainNumber);
        OffsetDateTime afterCall = DateTimeUtil.now();

        // Then
        ArgumentCaptor<OffsetDateTime> from = ArgumentCaptor.forClass(OffsetDateTime.class);
        ArgumentCaptor<OffsetDateTime> to = ArgumentCaptor.forClass(OffsetDateTime.class);
        verify(trainIdentificationRepository).findAllByStartDateTimeRangeAndOperationalTrainNumber(from.capture(), to.capture(), eq(trainNumber));

        assertThat(from.getValue()).isEqualTo(expectedFrom);
        assertThat(to.getValue()).isBetween(beforeCall.plusHours(HOURS_BEFORE_DEPARTURE), afterCall.plusHours(HOURS_BEFORE_DEPARTURE));
    }

    @Test
    void findCompaniesByStartDatesAndTrainNumber_narrowsToRequestedStartDates() {
        // Given
        LocalDate requestedDay = DateTimeUtil.today();
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
    void savePreloadedTrainIds_updatesRepository() {
        // Given
        Set<Integer> ids = Set.of(1, 2, 3);
        when(trainIdentificationRepository.updatePreloadedAtByIds(any(OffsetDateTime.class), eq(ids)))
            .thenReturn(3);

        // When
        OffsetDateTime beforeCall = OffsetDateTime.now();
        int result = underTest.savePreloadedTrainIds(ids);
        OffsetDateTime afterCall = OffsetDateTime.now();

        // Then
        assertThat(result).isEqualTo(3);
        var captor = ArgumentCaptor.forClass(OffsetDateTime.class);
        verify(trainIdentificationRepository).updatePreloadedAtByIds(captor.capture(), eq(ids));
        assertThat(captor.getValue()).isBetween(beforeCall, afterCall);
    }

    @Test
    void savePreloadedTrainIds_emptySet_returnsZeroWithoutCallingRepository() {
        // When
        int result = underTest.savePreloadedTrainIds(Set.of());

        // Then
        assertThat(result).isZero();
        verify(trainIdentificationRepository, never()).updatePreloadedAtByIds(any(), any());
    }

    @Test
    void findCompaniesByStartDatesAndTrainNumber_companyResolvedButNotInGetAllCompanies_isFiltered() {
        // Given
        OffsetDateTime departure = DateTimeUtil.now().plusMinutes(30);
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

        // When
        List<CompanyMatch> result = underTest
            .findCompaniesByStartDatesAndTrainNumber(startDates, trainNumber);

        // Then
        assertThat(result).isEmpty();
    }

    @Test
    void findCompaniesByStartDatesAndTrainNumber_startDateYesterday_isAccepted() {
        // Given
        LocalDate yesterday = TODAY.minusDays(1);
        Set<LocalDate> startDates = Set.of(yesterday);
        String trainNumber = "728";

        when(trainIdentificationRepository.findAllByStartDateTimeRangeAndOperationalTrainNumber(any(), any(), eq(trainNumber)))
            .thenReturn(List.of());

        // When
        List<CompanyMatch> result = underTest
            .findCompaniesByStartDatesAndTrainNumber(startDates, trainNumber);

        // Then
        assertThat(result).isEmpty();
    }

    @Test
    void findCompaniesByStartDatesAndTrainNumber_startDateTomorrow_isAccepted() {
        // Given
        Set<LocalDate> startDates = Set.of(TOMORROW);
        String trainNumber = "728";

        when(trainIdentificationRepository.findAllByStartDateTimeRangeAndOperationalTrainNumber(any(), any(), eq(trainNumber)))
            .thenReturn(List.of());

        // When
        List<CompanyMatch> result = underTest
            .findCompaniesByStartDatesAndTrainNumber(startDates, trainNumber);

        // Then
        assertThat(result).isEmpty();
    }

    @Test
    void findCompaniesByStartDatesAndTrainNumber_startDateTwoDaysAhead_throwsBadRequest() {
        // Given
        Set<LocalDate> startDates = Set.of(TODAY.plusDays(2));
        String trainNumber = "728";

        // When / Then
        assertThatThrownBy(() -> underTest.findCompaniesByStartDatesAndTrainNumber(startDates, trainNumber))
            .isInstanceOf(ResponseStatusException.class)
            .extracting(ex -> ((ResponseStatusException) ex).getStatusCode())
            .isEqualTo(HttpStatus.BAD_REQUEST);
    }

    @Test
    void findCompaniesByStartDatesAndTrainNumber_oneOfMultipleStartDatesOutOfRange_throwsBadRequest() {
        // Given
        Set<LocalDate> startDates = Set.of(TODAY, TODAY.plusDays(5));
        String trainNumber = "728";

        // When / Then
        assertThatThrownBy(() -> underTest.findCompaniesByStartDatesAndTrainNumber(startDates, trainNumber))
            .isInstanceOf(ResponseStatusException.class)
            .extracting(ex -> ((ResponseStatusException) ex).getStatusCode())
            .isEqualTo(HttpStatus.BAD_REQUEST);
    }
}
