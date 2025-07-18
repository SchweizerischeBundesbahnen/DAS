package ch.sbb.backend.formation.domain;

import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.times;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import ch.sbb.backend.admin.domain.settings.CompanyService;
import ch.sbb.backend.formation.application.FormationService;
import ch.sbb.backend.formation.infrastructure.TrainFormationRunRepository;
import ch.sbb.backend.formation.infrastructure.model.TrainFormationRunEntity;
import java.util.List;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

class FormationServiceTest {

    private TrainFormationRunRepository trainFormationRunRepository;
    private CompanyService companyService;
    private FormationService underTest;

    @BeforeEach
    void setUp() {
        trainFormationRunRepository = mock(TrainFormationRunRepository.class);
        companyService = mock(CompanyService.class);
        underTest = new FormationService(trainFormationRunRepository, companyService);
    }

    @Test
    void save_whenCompanyExists() {
        // Arrange
        List<TrainFormationRunEntity> trainFormationRunEntities = List.of(new TrainFormationRunEntity());
        when(companyService.existsByCodeRics(any())).thenReturn(true);

        // Act
        underTest.save(trainFormationRunEntities);

        // Assert
        verify(trainFormationRunRepository, times(1)).save(trainFormationRunEntities.getFirst());
    }

    @Test
    void save_whenCompanyNotExists() {
        // Arrange
        List<TrainFormationRunEntity> trainFormationRunEntities = List.of(new TrainFormationRunEntity());
        when(companyService.existsByCodeRics(any())).thenReturn(false);

        // Act
        underTest.save(trainFormationRunEntities);

        // Assert
        verify(trainFormationRunRepository, times(0)).save(any());

    }

    @Test
    void save_withMultipleEntities() {
        // Arrange
        TrainFormationRunEntity trainFormationRunEntity = TrainFormationRunEntity.builder()
            .company("1283")
            .build();
        List<TrainFormationRunEntity> trainFormationRunEntities = List.of(new TrainFormationRunEntity(), trainFormationRunEntity);

        when(companyService.existsByCodeRics(any())).thenReturn(false);
        when(companyService.existsByCodeRics("1283")).thenReturn(true);

        // Act
        underTest.save(trainFormationRunEntities);

        // Assert
        verify(trainFormationRunRepository, times(1)).save(trainFormationRunEntity);
    }
}