package ch.sbb.das.backend.trainjourneyplan;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

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
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.ArgumentCaptor;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

@ExtendWith(MockitoExtension.class)
class TrainIdentificationServiceTest {

    @Mock
    private TrainIdentificationRepository trainIdentificationRepository;

    @Mock
    private CompanyService companyService;

    @InjectMocks
    private TrainIdentificationService underTest;

    @Test
    void findCompaniesByStartDatesAndTrainNumber_returnsCompaniesWithDates() {
        // Given
        List<LocalDate> startDates = List.of(LocalDate.of(2025, 6, 15));
        String trainNumber = "728";

        TrainIdentificationEntity entity = TrainIdentificationEntity.builder()
            .id(1)
            .operationalTrainNumber(trainNumber)
            .startDateTime(OffsetDateTime.of(2025, 6, 15, 8, 30, 0, 0, ZoneOffset.ofHours(2)))
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
        assertThat(result).allMatch(item -> item.startDate().equals(LocalDate.of(2025, 6, 15)));
    }

    @Test
    void findCompaniesByStartDatesAndTrainNumber_multipleDates_returnsCorrectDates() {
        // Given
        List<LocalDate> startDates = List.of(LocalDate.of(2025, 6, 15), LocalDate.of(2025, 6, 16));
        String trainNumber = "728";

        TrainIdentificationEntity entity1 = TrainIdentificationEntity.builder()
            .id(1)
            .operationalTrainNumber(trainNumber)
            .startDateTime(OffsetDateTime.of(2025, 6, 15, 8, 30, 0, 0, ZoneOffset.ofHours(2)))
            .companies("MOCK_A")
            .build();

        TrainIdentificationEntity entity2 = TrainIdentificationEntity.builder()
            .id(2)
            .operationalTrainNumber(trainNumber)
            .startDateTime(OffsetDateTime.of(2025, 6, 16, 10, 0, 0, 0, ZoneOffset.ofHours(2)))
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
        assertThat(result).hasSize(2);
        assertThat(result.get(0).startDate()).isEqualTo(LocalDate.of(2025, 6, 15));
        assertThat(result.get(0).company().code()).isEqualTo(new CompanyCode("1111"));
        assertThat(result.get(1).startDate()).isEqualTo(LocalDate.of(2025, 6, 16));
        assertThat(result.get(1).company().code()).isEqualTo(new CompanyCode("2222"));
    }

    @Test
    void findCompaniesByStartDatesAndTrainNumber_unknownCompany_isFiltered() {
        // Given
        List<LocalDate> startDates = List.of(LocalDate.of(2025, 6, 15));
        String trainNumber = "728";

        TrainIdentificationEntity entity = TrainIdentificationEntity.builder()
            .id(1)
            .operationalTrainNumber(trainNumber)
            .startDateTime(OffsetDateTime.of(2025, 6, 15, 8, 30, 0, 0, ZoneOffset.ofHours(2)))
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
        assertThat(result.get(0).startDate()).isEqualTo(LocalDate.of(2025, 6, 15));
    }

    @Test
    void findCompaniesByStartDatesAndTrainNumber_allCompaniesUnsupported_returnsEmpty() {
        // Given
        List<LocalDate> startDates = List.of(LocalDate.of(2025, 6, 15));
        String trainNumber = "728";

        TrainIdentificationEntity entity = TrainIdentificationEntity.builder()
            .id(1)
            .operationalTrainNumber(trainNumber)
            .startDateTime(OffsetDateTime.of(2025, 6, 15, 8, 30, 0, 0, ZoneOffset.ofHours(2)))
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
        List<LocalDate> startDates = List.of(LocalDate.of(2025, 6, 15));
        String trainNumber = "728";

        TrainIdentificationEntity entity = TrainIdentificationEntity.builder()
            .id(1)
            .operationalTrainNumber(trainNumber)
            .startDateTime(OffsetDateTime.of(2025, 6, 15, 8, 30, 0, 0, ZoneOffset.ofHours(2)))
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
}
