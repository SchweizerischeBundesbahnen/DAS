package ch.sbb.backend.formation.domain.model;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.mockStatic;

import java.time.LocalDate;
import java.util.Collections;
import java.util.List;
import org.junit.jupiter.api.Test;
import org.mockito.MockedStatic;

class FormationTest {

    @Test
    void constructor_getters() {
        String operationalTrainNumber = "12345";
        String trainPathId = "12345-001";
        LocalDate operationalDay = LocalDate.now();

        Formation formation = new Formation(operationalTrainNumber, trainPathId, operationalDay, Collections.emptyList());

        assertThat(formation.getOperationalTrainNumber()).isEqualTo(operationalTrainNumber);
        assertThat(formation.getOperationalDay()).isEqualTo(operationalDay);
        assertThat(formation.validFormationRuns()).isEqualTo(Collections.emptyList());
    }

    @Test
    void inspectedFormationRuns_empty() {
        Formation formation = new Formation("12345", "12345-001", LocalDate.now(), Collections.emptyList());
        assertThat(formation.validFormationRuns()).isEqualTo(Collections.emptyList());
    }

    @Test
    void inspectedFormationRuns_withInspectedFormationRun() {
        List<FormationRun> inspectedRuns = List.of(mock(FormationRun.class));

        try (MockedStatic<FormationRun> mockedStatic = mockStatic(FormationRun.class)) {
            mockedStatic.when(() -> FormationRun.filterValid(any())).thenReturn(inspectedRuns);

            Formation formation = new Formation(
                "12345",
                "12345-001",
                LocalDate.now(),
                null // mocked
            );

            assertThat(formation.validFormationRuns()).hasSize(1);
        }
    }
}