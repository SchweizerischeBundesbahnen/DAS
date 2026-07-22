package ch.sbb.das.backend.cargo.api.v1.internal;

import static org.assertj.core.api.Assertions.assertThat;

import ch.sbb.das.backend.cargo.api.v1.model.FormationRun;
import ch.sbb.das.backend.cargo.infrastructure.model.TrainFormationRunEntity;
import ch.sbb.das.backend.companies.CompanyCode;
import java.time.LocalDate;
import java.time.OffsetDateTime;
import java.util.List;
import org.junit.jupiter.api.Test;

class FormationRunMapperTest {

    private final FormationRunMapper mapper = new FormationRunMapper();

    @Test
    void toFormationRun_maps_all_fields() {
        OffsetDateTime inspectionDateTime = OffsetDateTime.parse("2026-07-22T10:15:30+02:00");
        TrainFormationRunEntity entity = TrainFormationRunEntity.builder()
            .position(0)
            .inspectionDateTime(inspectionDateTime)
            .operationalTrainNumber("54233")
            .trainPathId("54233-001")
            .operationalDay(LocalDate.of(2026, 7, 22))
            .company(new CompanyCode("2185"))
            .tafTapLocationReferenceStart("CH52344")
            .tafTapLocationReferenceEnd("CH04212")
            .trainCategoryCode("CAT")
            .brakedWeightPercentage(435)
            .tractionMaxSpeedInKmh(80)
            .hauledLoadMaxSpeedInKmh(70)
            .formationMaxSpeedInKmh(65)
            .tractionLengthInCm(278)
            .hauledLoadLengthInCm(333)
            .formationLengthInCm(611)
            .tractionWeightInT(100)
            .hauledLoadWeightInT(932)
            .formationWeightInT(1032)
            .tractionBrakedWeightInT(64)
            .hauledLoadBrakedWeightInT(23)
            .formationBrakedWeightInT(87)
            .tractionHoldingForceInHectoNewton(120)
            .hauledLoadHoldingForceInHectoNewton(893)
            .formationHoldingForceInHectoNewton(1013)
            .brakePositionGForLeadingTraction(true)
            .brakePositionGForBrakeUnit1to5(false)
            .brakePositionGForLoadHauled(false)
            .simTrain(false)
            .additionalTractions(List.of("A1", "A2"))
            .carCarrierVehicle(false)
            .dangerousGoods(true)
            .vehiclesCount(12)
            .vehiclesWithBrakeDesignLAndLlAndKCount(5)
            .vehiclesWithBrakeDesignDCount(3)
            .vehiclesWithDisabledBrakesCount(1)
            .europeanVehicleNumberFirst("5623789313")
            .europeanVehicleNumberLast("5623789314")
            .axleLoadMaxInKg(31)
            .routeClass("A")
            .gradientUphillMaxInPermille(79)
            .gradientDownhillMaxInPermille(45)
            .slopeMaxForHoldingForceMinInPermille("40.2")
            .build();

        FormationRun result = mapper.toFormationRun(entity);

        assertThat(result.inspectionDateTime()).isEqualTo(inspectionDateTime);
        assertThat(result.tafTapLocationReferenceStart()).isEqualTo("CH52344");
        assertThat(result.tafTapLocationReferenceEnd()).isEqualTo("CH04212");
        assertThat(result.trainCategoryCode()).isEqualTo("CAT");
        assertThat(result.brakedWeightPercentage()).isEqualTo(435);
        assertThat(result.tractionMaxSpeedInKmh()).isEqualTo(80);
        assertThat(result.hauledLoadMaxSpeedInKmh()).isEqualTo(70);
        assertThat(result.formationMaxSpeedInKmh()).isEqualTo(65);
        assertThat(result.tractionLengthInCm()).isEqualTo(278);
        assertThat(result.hauledLoadLengthInCm()).isEqualTo(333);
        assertThat(result.formationLengthInCm()).isEqualTo(611);
        assertThat(result.tractionWeightInT()).isEqualTo(100);
        assertThat(result.hauledLoadWeightInT()).isEqualTo(932);
        assertThat(result.formationWeightInT()).isEqualTo(1032);
        assertThat(result.tractionBrakedWeightInT()).isEqualTo(64);
        assertThat(result.hauledLoadBrakedWeightInT()).isEqualTo(23);
        assertThat(result.formationBrakedWeightInT()).isEqualTo(87);
        assertThat(result.tractionHoldingForceInHectoNewton()).isEqualTo(120);
        assertThat(result.hauledLoadHoldingForceInHectoNewton()).isEqualTo(893);
        assertThat(result.formationHoldingForceInHectoNewton()).isEqualTo(1013);
        assertThat(result.brakePositionGForLeadingTraction()).isTrue();
        assertThat(result.brakePositionGForBrakeUnit1to5()).isFalse();
        assertThat(result.brakePositionGForLoadHauled()).isFalse();
        assertThat(result.simTrain()).isFalse();
        assertThat(result.additionalTractions()).containsExactly("A1", "A2");
        assertThat(result.carCarrierVehicle()).isFalse();
        assertThat(result.dangerousGoods()).isTrue();
        assertThat(result.vehiclesCount()).isEqualTo(12);
        assertThat(result.vehiclesWithBrakeDesignLlAndKCount()).isEqualTo(5);
        assertThat(result.vehiclesWithBrakeDesignLAndLlAndKCount()).isEqualTo(5);
        assertThat(result.vehiclesWithBrakeDesignDCount()).isEqualTo(3);
        assertThat(result.vehiclesWithDisabledBrakesCount()).isEqualTo(1);
        assertThat(result.europeanVehicleNumberFirst()).isEqualTo("5623789313");
        assertThat(result.europeanVehicleNumberLast()).isEqualTo("5623789314");
        assertThat(result.axleLoadMaxInKg()).isEqualTo(31);
        assertThat(result.routeClass()).isEqualTo("A");
        assertThat(result.gradientUphillMaxInPermille()).isEqualTo(79);
        assertThat(result.gradientDownhillMaxInPermille()).isEqualTo(45);
        assertThat(result.slopeMaxForHoldingForceMinInPermille()).isEqualTo("40.2");
    }

    @Test
    void toFormationRuns_maps_list() {
        TrainFormationRunEntity first = TrainFormationRunEntity.builder()
            .tafTapLocationReferenceStart("CH00001")
            .tafTapLocationReferenceEnd("CH00002")
            .vehiclesWithBrakeDesignLAndLlAndKCount(1)
            .build();
        TrainFormationRunEntity second = TrainFormationRunEntity.builder()
            .tafTapLocationReferenceStart("CH00003")
            .tafTapLocationReferenceEnd("CH00004")
            .vehiclesWithBrakeDesignLAndLlAndKCount(2)
            .build();

        List<FormationRun> result = mapper.toFormationRuns(List.of(first, second));

        assertThat(result).hasSize(2);
        assertThat(result.getFirst().tafTapLocationReferenceStart()).isEqualTo("CH00001");
        assertThat(result.getLast().tafTapLocationReferenceStart()).isEqualTo("CH00003");
        assertThat(result.getFirst().vehiclesWithBrakeDesignLlAndKCount()).isEqualTo(1);
        assertThat(result.getLast().vehiclesWithBrakeDesignLlAndKCount()).isEqualTo(2);
    }
}
