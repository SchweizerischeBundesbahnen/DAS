package ch.sbb.das.backend.trainjourneyplan;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import ch.sbb.das.backend.common.DateTimeUtil;
import ch.sbb.das.backend.companies.CompanyCode;
import ch.sbb.das.backend.companies.CompanyService;
import ch.sbb.das.backend.companies.CompanyShortName;
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
import org.springframework.test.util.ReflectionTestUtils;

@ExtendWith(MockitoExtension.class)
class TrainIdentificationServiceTest {

    @Mock
    private TrainIdentificationRepository trainIdentificationRepository;

    @Mock
    private CompanyService companyService;

    @InjectMocks
    private TrainIdentificationService trainIdentificationService;

    @Test
    void findCompanyCodesByStartDateAndTrainNumber_returnsCompanyCodes() {
        // Given
        LocalDate startDate = LocalDate.of(2025, 6, 15);
        String trainNumber = "728";
        OffsetDateTime expectedFrom = startDate.atStartOfDay(DateTimeUtil.SWISS_ZONE).toOffsetDateTime();
        OffsetDateTime expectedTo = startDate.plusDays(1).atStartOfDay(DateTimeUtil.SWISS_ZONE).toOffsetDateTime();

        TrainIdentificationEntity entity = new TrainIdentificationEntity();
        ReflectionTestUtils.setField(entity, "id", 1);
        ReflectionTestUtils.setField(entity, "operationalTrainNumber", trainNumber);
        ReflectionTestUtils.setField(entity, "startDateTime", OffsetDateTime.of(2025, 6, 15, 8, 30, 0, 0, ZoneOffset.UTC));
        ReflectionTestUtils.setField(entity, "companies", "MOCK_A,MOCK_B");

        when(trainIdentificationRepository.findAllByStartDateTimeBetweenAndOperationalTrainNumber(
            expectedFrom, expectedTo, trainNumber))
            .thenReturn(List.of(entity));

        when(companyService.findCompanyCodeByShortName(new CompanyShortName("MOCK_A")))
            .thenReturn(Optional.of(new CompanyCode("1111")));
        when(companyService.findCompanyCodeByShortName(new CompanyShortName("MOCK_B")))
            .thenReturn(Optional.of(new CompanyCode("2222")));

        // When
        Set<CompanyCode> result = trainIdentificationService.findCompanyCodesByStartDateAndTrainNumber(startDate, trainNumber);

        // Then
        assertThat(result).containsExactlyInAnyOrder(new CompanyCode("1111"), new CompanyCode("2222"));
    }

    @Test
    void findCompanyCodesByStartDateAndTrainNumber_noResults_returnsEmptySet() {
        // Given
        LocalDate startDate = LocalDate.of(2025, 6, 15);
        String trainNumber = "999";
        OffsetDateTime expectedFrom = startDate.atStartOfDay(DateTimeUtil.SWISS_ZONE).toOffsetDateTime();
        OffsetDateTime expectedTo = startDate.plusDays(1).atStartOfDay(DateTimeUtil.SWISS_ZONE).toOffsetDateTime();

        when(trainIdentificationRepository.findAllByStartDateTimeBetweenAndOperationalTrainNumber(
            expectedFrom, expectedTo, trainNumber))
            .thenReturn(List.of());

        // When
        Set<CompanyCode> result = trainIdentificationService.findCompanyCodesByStartDateAndTrainNumber(startDate, trainNumber);

        // Then
        assertThat(result).isEmpty();
    }

    @Test
    void findCompanyCodesByStartDateAndTrainNumber_unknownCompany_isFiltered() {
        // Given
        LocalDate startDate = LocalDate.of(2025, 6, 15);
        String trainNumber = "728";
        OffsetDateTime expectedFrom = startDate.atStartOfDay(DateTimeUtil.SWISS_ZONE).toOffsetDateTime();
        OffsetDateTime expectedTo = startDate.plusDays(1).atStartOfDay(DateTimeUtil.SWISS_ZONE).toOffsetDateTime();

        TrainIdentificationEntity entity = new TrainIdentificationEntity();
        ReflectionTestUtils.setField(entity, "id", 1);
        ReflectionTestUtils.setField(entity, "operationalTrainNumber", trainNumber);
        ReflectionTestUtils.setField(entity, "startDateTime", OffsetDateTime.of(2025, 6, 15, 8, 30, 0, 0, ZoneOffset.UTC));
        ReflectionTestUtils.setField(entity, "companies", "MOCK_A,UNKNOWN");

        when(trainIdentificationRepository.findAllByStartDateTimeBetweenAndOperationalTrainNumber(
            expectedFrom, expectedTo, trainNumber))
            .thenReturn(List.of(entity));

        when(companyService.findCompanyCodeByShortName(new CompanyShortName("MOCK_A")))
            .thenReturn(Optional.of(new CompanyCode("1111")));
        when(companyService.findCompanyCodeByShortName(new CompanyShortName("UNKNOWN")))
            .thenReturn(Optional.empty());

        // When
        Set<CompanyCode> result = trainIdentificationService.findCompanyCodesByStartDateAndTrainNumber(startDate, trainNumber);

        // Then
        assertThat(result).containsExactly(new CompanyCode("1111"));
    }

    @Test
    void findCompanyCodesByStartDateAndTrainNumber_multipleEntities_mergesCompanies() {
        // Given
        LocalDate startDate = LocalDate.of(2025, 6, 15);
        String trainNumber = "728";
        OffsetDateTime expectedFrom = startDate.atStartOfDay(DateTimeUtil.SWISS_ZONE).toOffsetDateTime();
        OffsetDateTime expectedTo = startDate.plusDays(1).atStartOfDay(DateTimeUtil.SWISS_ZONE).toOffsetDateTime();

        TrainIdentificationEntity entity1 = new TrainIdentificationEntity();
        ReflectionTestUtils.setField(entity1, "id", 1);
        ReflectionTestUtils.setField(entity1, "operationalTrainNumber", trainNumber);
        ReflectionTestUtils.setField(entity1, "startDateTime", OffsetDateTime.of(2025, 6, 15, 8, 30, 0, 0, ZoneOffset.UTC));
        ReflectionTestUtils.setField(entity1, "companies", "MOCK_A");

        TrainIdentificationEntity entity2 = new TrainIdentificationEntity();
        ReflectionTestUtils.setField(entity2, "id", 2);
        ReflectionTestUtils.setField(entity2, "operationalTrainNumber", trainNumber);
        ReflectionTestUtils.setField(entity2, "startDateTime", OffsetDateTime.of(2025, 6, 15, 14, 0, 0, 0, ZoneOffset.UTC));
        ReflectionTestUtils.setField(entity2, "companies", "MOCK_B");

        when(trainIdentificationRepository.findAllByStartDateTimeBetweenAndOperationalTrainNumber(
            expectedFrom, expectedTo, trainNumber))
            .thenReturn(List.of(entity1, entity2));

        when(companyService.findCompanyCodeByShortName(new CompanyShortName("MOCK_A")))
            .thenReturn(Optional.of(new CompanyCode("1111")));
        when(companyService.findCompanyCodeByShortName(new CompanyShortName("MOCK_B")))
            .thenReturn(Optional.of(new CompanyCode("2222")));

        // When
        Set<CompanyCode> result = trainIdentificationService.findCompanyCodesByStartDateAndTrainNumber(startDate, trainNumber);

        // Then
        assertThat(result).containsExactlyInAnyOrder(new CompanyCode("1111"), new CompanyCode("2222"));
    }

    @Test
    void getNewTrainIdentificationsBetween_returnsFilteredAndSortedResults() {
        // Given
        OffsetDateTime after = OffsetDateTime.of(2025, 6, 15, 0, 0, 0, 0, ZoneOffset.UTC);
        OffsetDateTime before = OffsetDateTime.of(2025, 6, 16, 0, 0, 0, 0, ZoneOffset.UTC);

        TrainIdentificationEntity entity1 = new TrainIdentificationEntity();
        ReflectionTestUtils.setField(entity1, "id", 1);
        ReflectionTestUtils.setField(entity1, "operationalTrainNumber", "728");
        ReflectionTestUtils.setField(entity1, "startDateTime", OffsetDateTime.of(2025, 6, 15, 14, 0, 0, 0, ZoneOffset.UTC));
        ReflectionTestUtils.setField(entity1, "companies", "MOCK_A");

        TrainIdentificationEntity entity2 = new TrainIdentificationEntity();
        ReflectionTestUtils.setField(entity2, "id", 2);
        ReflectionTestUtils.setField(entity2, "operationalTrainNumber", "100");
        ReflectionTestUtils.setField(entity2, "startDateTime", OffsetDateTime.of(2025, 6, 15, 8, 0, 0, 0, ZoneOffset.UTC));
        ReflectionTestUtils.setField(entity2, "companies", "MOCK_B");

        when(trainIdentificationRepository.findAllByStartDateTimeAfterAndStartDateTimeBeforeAndPreloadedAtNull(after, before))
            .thenReturn(List.of(entity1, entity2));

        when(companyService.findCompanyCodeByShortName(new CompanyShortName("MOCK_A")))
            .thenReturn(Optional.of(new CompanyCode("1111")));
        when(companyService.findCompanyCodeByShortName(new CompanyShortName("MOCK_B")))
            .thenReturn(Optional.of(new CompanyCode("2222")));

        // When
        List<TrainIdentification> result = trainIdentificationService.getNewTrainIdentificationsBetween(after, before);

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

        TrainIdentificationEntity entity = new TrainIdentificationEntity();
        ReflectionTestUtils.setField(entity, "id", 1);
        ReflectionTestUtils.setField(entity, "operationalTrainNumber", "728");
        ReflectionTestUtils.setField(entity, "startDateTime", OffsetDateTime.of(2025, 6, 15, 8, 0, 0, 0, ZoneOffset.UTC));
        ReflectionTestUtils.setField(entity, "companies", "UNKNOWN");

        when(trainIdentificationRepository.findAllByStartDateTimeAfterAndStartDateTimeBeforeAndPreloadedAtNull(after, before))
            .thenReturn(List.of(entity));

        when(companyService.findCompanyCodeByShortName(new CompanyShortName("UNKNOWN")))
            .thenReturn(Optional.empty());

        // When
        List<TrainIdentification> result = trainIdentificationService.getNewTrainIdentificationsBetween(after, before);

        // Then
        assertThat(result).isEmpty();
    }

    @Test
    void getNewTrainIdentificationsBetween_noResults_returnsEmptyList() {
        // Given
        OffsetDateTime after = OffsetDateTime.of(2025, 6, 15, 0, 0, 0, 0, ZoneOffset.UTC);
        OffsetDateTime before = OffsetDateTime.of(2025, 6, 16, 0, 0, 0, 0, ZoneOffset.UTC);

        when(trainIdentificationRepository.findAllByStartDateTimeAfterAndStartDateTimeBeforeAndPreloadedAtNull(after, before))
            .thenReturn(List.of());

        // When
        List<TrainIdentification> result = trainIdentificationService.getNewTrainIdentificationsBetween(after, before);

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
        int result = trainIdentificationService.savePreloadedTrainIds(ids);
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
        int result = trainIdentificationService.savePreloadedTrainIds(Set.of());

        // Then
        assertThat(result).isZero();
        verify(trainIdentificationRepository, never()).updatePreloadedAtByIds(any(), any());
    }
}
