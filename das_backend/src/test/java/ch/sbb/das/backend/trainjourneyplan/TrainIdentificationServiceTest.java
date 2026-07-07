package ch.sbb.das.backend.trainjourneyplan;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.when;

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

        TrainIdentificationEntity entity = new TrainIdentificationEntity();
        ReflectionTestUtils.setField(entity, "id", 1);
        ReflectionTestUtils.setField(entity, "operationalTrainNumber", trainNumber);
        ReflectionTestUtils.setField(entity, "startDateTime", OffsetDateTime.of(2025, 6, 15, 8, 30, 0, 0, ZoneOffset.UTC));
        ReflectionTestUtils.setField(entity, "companies", "MOCK_A,MOCK_B");

        when(trainIdentificationRepository.findAllByStartDateTimeBetweenAndOperationalTrainNumber(
            any(OffsetDateTime.class), any(OffsetDateTime.class), eq(trainNumber)))
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

        when(trainIdentificationRepository.findAllByStartDateTimeBetweenAndOperationalTrainNumber(
            any(OffsetDateTime.class), any(OffsetDateTime.class), eq(trainNumber)))
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

        TrainIdentificationEntity entity = new TrainIdentificationEntity();
        ReflectionTestUtils.setField(entity, "id", 1);
        ReflectionTestUtils.setField(entity, "operationalTrainNumber", trainNumber);
        ReflectionTestUtils.setField(entity, "startDateTime", OffsetDateTime.of(2025, 6, 15, 8, 30, 0, 0, ZoneOffset.UTC));
        ReflectionTestUtils.setField(entity, "companies", "MOCK_A,UNKNOWN");

        when(trainIdentificationRepository.findAllByStartDateTimeBetweenAndOperationalTrainNumber(
            any(OffsetDateTime.class), any(OffsetDateTime.class), eq(trainNumber)))
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
            any(OffsetDateTime.class), any(OffsetDateTime.class), eq(trainNumber)))
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
}
