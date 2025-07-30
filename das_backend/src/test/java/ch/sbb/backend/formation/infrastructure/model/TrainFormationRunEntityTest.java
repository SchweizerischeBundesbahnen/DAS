package ch.sbb.backend.formation.infrastructure.model;

import static org.assertj.core.api.Assertions.assertThat;

import ch.sbb.backend.formation.domain.model.BrakeDesign;
import ch.sbb.backend.formation.domain.model.BrakeStatus;
import ch.sbb.backend.formation.domain.model.EuropeanVehicleNumber;
import ch.sbb.backend.formation.domain.model.Formation;
import ch.sbb.backend.formation.domain.model.FormationRun;
import ch.sbb.backend.formation.domain.model.Goods;
import ch.sbb.backend.formation.domain.model.IntermodalLoadingUnit;
import ch.sbb.backend.formation.domain.model.Load;
import ch.sbb.backend.formation.domain.model.TafTapLocationReference;
import ch.sbb.backend.formation.domain.model.TractionMode;
import ch.sbb.backend.formation.domain.model.Vehicle;
import ch.sbb.backend.formation.domain.model.VehicleUnit;
import java.time.LocalDate;
import java.time.OffsetDateTime;
import java.util.Collections;
import java.util.List;
import org.junit.jupiter.api.Test;

class TrainFormationRunEntityTest {

    @Test
    void from_null() {

        Formation formation = new Formation(null, null, null, null);

        List<TrainFormationRunEntity> entities = TrainFormationRunEntity.from(formation);

        assertThat(entities).isEmpty();
    }

    @Test
    void from_empty() {
        OffsetDateTime modifiedDateTime = OffsetDateTime.now();
        String operationalTrainNumber = "7889";
        LocalDate operationalDay = LocalDate.of(2023, 10, 1);

        Formation formation = new Formation(modifiedDateTime, operationalTrainNumber, operationalDay, Collections.emptyList());

        List<TrainFormationRunEntity> entities = TrainFormationRunEntity.from(formation);

        assertThat(entities).isEmpty();
    }

    @Test
    void from_correct() {
        OffsetDateTime modifiedDateTime = OffsetDateTime.now();
        String operationalTrainNumber = "6599";
        LocalDate operationalDay = LocalDate.of(2025, 9, 23);

        FormationRun formationRun = FormationRun.builder()
            .inspected(true)
            .company("4532")
            .tafTapLocationReferenceStart(new TafTapLocationReference("CH", 102344))
            .tafTapLocationReferenceEnd(new TafTapLocationReference("CH", 504212))
            .trainCategoryCode("CAT")
            .brakedWeightPercentage(435)
            .tractionMaxSpeedInKmh(1)
            .hauledLoadMaxSpeedInKmh(34)
            .formationMaxSpeedInKmh(55)
            .tractionLengthInCm(278)
            .hauledLoadLengthInCm(333)
            .formationLengthInCm(900)
            .tractionGrossWeightInT(100)
            .hauledLoadGrossWeightInT(932)
            .tractionBrakedWeightInT(64)
            .hauledLoadBrakedWeightInT(23)
            .brakePositionGForLeadingTraction(true)
            .brakePositionGForBrakeUnit1to5(false)
            .brakePositionGForLoadHauled(false)
            .simTrain(false)
            .carCarrierVehicle(false)
            .axleLoadMaxInKg(31)
            .routeClass("A")
            .gradientUphillMaxInPermille(79)
            .gradientDownhillMaxInPermille(45)
            .slopeMaxForHoldingForceMinInPermille("40.2")
            .vehicles(List.of(new Vehicle(TractionMode.UEBERFUEHRUNG, "CATE", List.of(
                VehicleUnit.builder()
                    .brakeDesign(BrakeDesign.L_KUNSTSTOFF_LEISE)
                    .brakeStatus(new BrakeStatus(3))
                    .technicalHoldingForceInHectoNewton(302)
                    .effectiveOperationalHoldingForceInHectoNewton(893)
                    .handBrakeWeightInT(90)
                    .load(new Load(List.of(new Goods(false)), List.of(new IntermodalLoadingUnit(List.of(new Goods(false))))))
                    .build()
            ), new EuropeanVehicleNumber("56", "23", "78931", "3"))))
            .build();

        Formation formation = new Formation(modifiedDateTime, operationalTrainNumber, operationalDay, List.of(formationRun));

        List<TrainFormationRunEntity> entities = TrainFormationRunEntity.from(formation);

        assertThat(entities).first().isNotNull();
        TrainFormationRunEntity result = entities.getFirst();
        assertThat(result.getId()).isNull();
        assertThat(result.getModifiedDateTime()).isEqualTo(modifiedDateTime);
        assertThat(result.getOperationalTrainNumber()).isEqualTo(operationalTrainNumber);
        assertThat(result.getOperationalDay()).isEqualTo(operationalDay);
        assertThat(result.getCompany()).isEqualTo("4532");
        assertThat(result.getTafTapLocationReferenceStart()).isEqualTo("CH102344");
        assertThat(result.getTafTapLocationReferenceEnd()).isEqualTo("CH504212");
        assertThat(result.getTrainCategoryCode()).isEqualTo("CAT");
        assertThat(result.getBrakedWeightPercentage()).isEqualTo(435);
        assertThat(result.getTractionMaxSpeedInKmh()).isEqualTo(1);
        assertThat(result.getHauledLoadMaxSpeedInKmh()).isEqualTo(34);
        assertThat(result.getFormationMaxSpeedInKmh()).isEqualTo(55);
        assertThat(result.getTractionLengthInCm()).isEqualTo(278);
        assertThat(result.getHauledLoadLengthInCm()).isEqualTo(333);
        assertThat(result.getFormationLengthInCm()).isEqualTo(900);
        assertThat(result.getTractionWeightInT()).isEqualTo(100);
        assertThat(result.getHauledLoadWeightInT()).isEqualTo(932);
        assertThat(result.getFormationWeightInT()).isEqualTo(1032);
        assertThat(result.getTractionBrakedWeightInT()).isEqualTo(64);
        assertThat(result.getHauledLoadBrakedWeightInT()).isEqualTo(23);
        assertThat(result.getFormationBrakedWeightInT()).isEqualTo(87);
        assertThat(result.getTractionHoldingForceInHectoNewton()).isZero();
        assertThat(result.getHauledLoadHoldingForceInHectoNewton()).isEqualTo(893);
        assertThat(result.getFormationHoldingForceInHectoNewton()).isEqualTo(893);
        assertThat(result.getBrakePositionGForLeadingTraction()).isTrue();
        assertThat(result.getBrakePositionGForBrakeUnit1to5()).isFalse();
        assertThat(result.getBrakePositionGForLoadHauled()).isFalse();
        assertThat(result.getSimTrain()).isFalse();
        assertThat(result.getTractionModes()).isEmpty();
        assertThat(result.getCarCarrierVehicle()).isFalse();
        assertThat(result.getDangerousGoods()).isFalse();
        assertThat(result.getVehiclesCount()).isEqualTo(1);
        assertThat(result.getVehiclesWithBrakeDesignLlAndKCount()).isZero();
        assertThat(result.getVehiclesWithBrakeDesignDCount()).isZero();
        assertThat(result.getVehiclesWithDisabledBrakesCount()).isZero();
        assertThat(result.getEuropeanVehicleNumberFirst()).isEqualTo("5623789313");
        assertThat(result.getEuropeanVehicleNumberLast()).isEqualTo("5623789313");
        assertThat(result.getAxleLoadMaxInKg()).isEqualTo(31);
        assertThat(result.getRouteClass()).isEqualTo("A");
        assertThat(result.getGradientUphillMaxInPermille()).isEqualTo(79);
        assertThat(result.getGradientDownhillMaxInPermille()).isEqualTo(45);
        assertThat(result.getSlopeMaxForHoldingForceMinInPermille()).isEqualTo("40.2");
    }
}