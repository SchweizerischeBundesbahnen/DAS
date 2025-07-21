package ch.sbb.backend.formation.domain;

import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.times;
import static org.mockito.Mockito.verify;

import ch.sbb.backend.formation.application.FormationService;
import ch.sbb.backend.formation.infrastructure.TrainFormationRunRepository;
import ch.sbb.backend.formation.infrastructure.model.TrainFormationRunEntity;
import java.util.List;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

class FormationServiceTest {

    private TrainFormationRunRepository trainFormationRunRepository;
    private FormationService underTest;

    @BeforeEach
    void setUp() {
        trainFormationRunRepository = mock(TrainFormationRunRepository.class);
        underTest = new FormationService(trainFormationRunRepository);
    }

    @Test
    void save() {
        // Arrange
        List<TrainFormationRunEntity> trainFormationRunEntities = List.of(new TrainFormationRunEntity());

        // Act
        underTest.save(trainFormationRunEntities);

        // Assert
        verify(trainFormationRunRepository, times(1)).saveAll(trainFormationRunEntities);
    }

    @Test
    void save_withMultipleEntities() {
        // Arrange
        TrainFormationRunEntity trainFormationRunEntity = TrainFormationRunEntity.builder()
            .axleLoadMaxInKg(238)
            .build();
        List<TrainFormationRunEntity> trainFormationRunEntities = List.of(new TrainFormationRunEntity(), trainFormationRunEntity);

        // Act
        underTest.save(trainFormationRunEntities);

        // Assert
        verify(trainFormationRunRepository, times(1)).saveAll(trainFormationRunEntities);
    }
}