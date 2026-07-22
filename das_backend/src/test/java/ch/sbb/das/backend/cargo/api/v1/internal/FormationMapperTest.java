package ch.sbb.das.backend.cargo.api.v1.internal;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

import ch.sbb.das.backend.cargo.api.v1.model.Formation;
import ch.sbb.das.backend.cargo.infrastructure.model.TrainFormationRunEntity;
import ch.sbb.das.backend.companies.CompanyCode;
import java.time.LocalDate;
import java.util.List;
import org.junit.jupiter.api.Test;

class FormationMapperTest {

    private final FormationMapper mapper = new FormationMapper(new FormationRunMapper());

    @Test
    void toFormation_maps_header_from_first_entity_and_runs() {
        TrainFormationRunEntity first = TrainFormationRunEntity.builder()
            .operationalTrainNumber("54233")
            .operationalDay(LocalDate.of(2026, 7, 22))
            .company(new CompanyCode("2185"))
            .tafTapLocationReferenceStart("CH00001")
            .tafTapLocationReferenceEnd("CH00002")
            .vehiclesWithBrakeDesignLAndLlAndKCount(1)
            .build();
        TrainFormationRunEntity second = TrainFormationRunEntity.builder()
            .operationalTrainNumber("99999")
            .operationalDay(LocalDate.of(2026, 1, 1))
            .company(new CompanyCode("0000"))
            .tafTapLocationReferenceStart("CH00003")
            .tafTapLocationReferenceEnd("CH00004")
            .vehiclesWithBrakeDesignLAndLlAndKCount(2)
            .build();

        Formation result = mapper.toFormation(List.of(first, second));

        assertThat(result.operationalTrainNumber()).isEqualTo("54233");
        assertThat(result.operationalDay()).isEqualTo(LocalDate.of(2026, 7, 22));
        assertThat(result.company()).isEqualTo(new CompanyCode("2185"));
        assertThat(result.formationRuns()).hasSize(2);
        assertThat(result.formationRuns().getFirst().tafTapLocationReferenceStart()).isEqualTo("CH00001");
        assertThat(result.formationRuns().getLast().tafTapLocationReferenceStart()).isEqualTo("CH00003");
    }

    @Test
    void toFormation_throws_on_empty_input() {
        assertThatThrownBy(() -> mapper.toFormation(List.of()))
            .isInstanceOf(IllegalArgumentException.class)
            .hasMessage("Train formation runs cannot be empty");
    }
}
