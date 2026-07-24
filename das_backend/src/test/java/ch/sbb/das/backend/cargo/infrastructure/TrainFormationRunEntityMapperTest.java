package ch.sbb.das.backend.cargo.infrastructure;

import static org.assertj.core.api.Assertions.assertThat;

import ch.sbb.das.backend.cargo.domain.model.BrakeDesign;
import ch.sbb.das.backend.cargo.domain.model.BrakeStatus;
import ch.sbb.das.backend.cargo.domain.model.EuropeanVehicleNumber;
import ch.sbb.das.backend.cargo.domain.model.Formation;
import ch.sbb.das.backend.cargo.domain.model.FormationRun;
import ch.sbb.das.backend.cargo.domain.model.Goods;
import ch.sbb.das.backend.cargo.domain.model.IntermodalLoadingUnit;
import ch.sbb.das.backend.cargo.domain.model.Load;
import ch.sbb.das.backend.cargo.domain.model.TractionMode;
import ch.sbb.das.backend.cargo.domain.model.Vehicle;
import ch.sbb.das.backend.cargo.domain.model.VehicleUnit;
import ch.sbb.das.backend.cargo.infrastructure.model.TrainFormationRunEntity;
import ch.sbb.das.backend.companies.CompanyCode;
import ch.sbb.das.backend.locations.TafTapLocationReference;
import java.time.LocalDate;
import java.time.OffsetDateTime;
import java.util.Collections;
import java.util.List;
import org.junit.jupiter.api.Test;

class TrainFormationRunEntityMapperTest {

    private final TrainFormationRunEntityMapper underTest = new TrainFormationRunEntityMapper();

    @Test
    void toEntities_null() {

        Formation formation = new Formation(null, null, null, null);

        List<TrainFormationRunEntity> entities = underTest.toEntities(formation);

        assertThat(entities).isEmpty();
    }

    @Test
    void toEntities_empty() {
        String operationalTrainNumber = "7889";
        String trainPathId = "7889-023";
        LocalDate operationalDay = LocalDate.of(2023, 10, 1);

        Formation formation = new Formation(operationalTrainNumber, trainPathId, operationalDay, Collections.emptyList());

        List<TrainFormationRunEntity> entities = underTest.toEntities(formation);

        assertThat(entities).isEmpty();
    }

    @Test
    void toEntities_correct() {
        OffsetDateTime inspectionDateTime = OffsetDateTime.now();
        String operationalTrainNumber = "6599";
        String trainPathId = "6599-002";
        LocalDate operationalDay = LocalDate.of(2025, 9, 23);

        FormationRun formationRun = FormationRun.builder()
            .inspected(true)
            .inspectionDateTime(inspectionDateTime)
            .company(new CompanyCode("4532"))
            .tafTapLocationReferenceStart(new TafTapLocationReference("CH", 52344))
            .tafTapLocationReferenceEnd(new TafTapLocationReference("CH", 4212))
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
                    .brakeDesign(BrakeDesign.NORMALE_BREMSAUSRUESTUNG_KEINE_MERKMALE)
                    .brakeStatus(new BrakeStatus(3))
                    .technicalHoldingForceInHectoNewton(302)
                    .effectiveOperationalHoldingForceInHectoNewton(893)
                    .load(new Load(List.of(new Goods(false)), List.of(new IntermodalLoadingUnit(false, List.of(new Goods(false))))))
                    .build()
            ), new EuropeanVehicleNumber("56", "23", "78931", "3"))))
            .build();

        Formation formation = new Formation(operationalTrainNumber, trainPathId, operationalDay, List.of(formationRun));

        List<TrainFormationRunEntity> entities = underTest.toEntities(formation);

        assertThat(entities).first().isNotNull();
        TrainFormationRunEntity result = entities.getFirst();
        assertThat(result.getId()).isNull();
        assertThat(result.getInspectionDateTime()).isEqualTo(inspectionDateTime);
        assertThat(result.getOperationalTrainNumber()).isEqualTo(operationalTrainNumber);
        assertThat(result.getTrainPathId()).isEqualTo(trainPathId);
        assertThat(result.getOperationalDay()).isEqualTo(operationalDay);
        assertThat(result.getCompany()).isEqualTo(new CompanyCode("4532"));
        assertThat(result.getTafTapLocationReferenceStart()).isEqualTo("CH52344");
        assertThat(result.getTafTapLocationReferenceEnd()).isEqualTo("CH04212");
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
        assertThat(result.getTractionHoldingForceInHectoNewton()).isNull();
        assertThat(result.getHauledLoadHoldingForceInHectoNewton()).isEqualTo(893);
        assertThat(result.getFormationHoldingForceInHectoNewton()).isEqualTo(893);
        assertThat(result.getBrakePositionGForLeadingTraction()).isTrue();
        assertThat(result.getBrakePositionGForBrakeUnit1to5()).isFalse();
        assertThat(result.getBrakePositionGForLoadHauled()).isFalse();
        assertThat(result.getSimTrain()).isFalse();
        assertThat(result.getAdditionalTractions()).isEmpty();
        assertThat(result.getCarCarrierVehicle()).isFalse();
        assertThat(result.getDangerousGoods()).isFalse();
        assertThat(result.getVehiclesCount()).isEqualTo(1);
        assertThat(result.getVehiclesWithBrakeDesignLAndLlAndKCount()).isZero();
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
