package ch.sbb.backend.formation.infrastructure.model;

import ch.sbb.backend.common.SFERA;
import ch.sbb.backend.common.StringListConverter;
import ch.sbb.backend.common.TelTsi;
import ch.sbb.backend.formation.domain.model.BrakeDesign;
import ch.sbb.backend.formation.domain.model.Formation;
import ch.sbb.backend.formation.domain.model.FormationRun;
import ch.sbb.backend.formation.domain.model.TractionMode;
import jakarta.persistence.Column;
import jakarta.persistence.Convert;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.SequenceGenerator;
import java.time.LocalDate;
import java.time.OffsetDateTime;
import java.util.List;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

@Entity(name = "train_formation_run")
@Builder
@Getter
@NoArgsConstructor
@AllArgsConstructor
// todo: a default value must be defined for all non-primitive Boolean and Integer fields (by business or source systems)
public class TrainFormationRunEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.SEQUENCE, generator = "train_formation_run_id_seq")
    @SequenceGenerator(name = "train_formation_run_id_seq", allocationSize = 1)
    private Integer id;

    private OffsetDateTime modifiedDateTime;

    @SFERA @TelTsi
    private String operationalTrainNumber;

    @SFERA(nsp = true)
    private LocalDate operationalDay;

    @SFERA @TelTsi
    @JoinColumn(name = "company", referencedColumnName = "codeRics")
    private String company;

    private String tafTapLocationReferenceStart;

    private String tafTapLocationReferenceEnd;

    private String trainCategoryCode;

    private Integer brakedWeightPercentage;

    private Integer tractionMaxSpeedInKmh;

    private Integer hauledLoadMaxSpeedInKmh;

    private Integer formationMaxSpeedInKmh;

    private Integer tractionLengthInCm;

    private Integer hauledLoadLengthInCm;

    private Integer formationLengthInCm;

    @Column(name = "traction_weight_in_t")
    private Integer tractionWeightInT;

    @Column(name = "hauled_load_weight_in_t")
    private Integer hauledLoadWeightInT;

    @Column(name = "formation_weight_in_t")
    private Integer formationWeightInT;

    @Column(name = "traction_braked_weight_in_t")
    private Integer tractionBrakedWeightInT;

    @Column(name = "hauled_load_braked_weight_in_t")
    private Integer hauledLoadBrakedWeightInT;

    @Column(name = "formation_braked_weight_in_t")
    private Integer formationBrakedWeightInT;

    private Integer tractionHoldingForceInHectoNewton;

    private Integer hauledLoadHoldingForceInHectoNewton;

    private Integer formationHoldingForceInHectoNewton;

    @Column(name = "brake_position_g_for_leading_traction")
    private Boolean brakePositionGForLeadingTraction;

    @Column(name = "brake_position_g_for_brake_unit_1_to_5")
    private Boolean brakePositionGForBrakeUnit1to5;

    @Column(name = "brake_position_g_for_load_hauled")
    private Boolean brakePositionGForLoadHauled;

    private Boolean simTrain;

    @Convert(converter = StringListConverter.class)
    private List<String> tractionModes;

    private Boolean carCarrierVehicle;

    private Boolean dangerousGoods;

    private Integer vehiclesCount;

    @Column(name = "vehicles_with_brake_design_ll_and_k_count")
    private Integer vehiclesWithBrakeDesignLlAndKCount;

    @Column(name = "vehicles_with_brake_design_d_count")
    private Integer vehiclesWithBrakeDesignDCount;

    private Integer vehiclesWithDisabledBrakesCount;

    private String europeanVehicleNumberFirst;

    private String europeanVehicleNumberLast;

    private Integer axleLoadMaxInKg;

    private String routeClass;

    private Integer gradientUphillMaxInPermille;

    private Integer gradientDownhillMaxInPermille;

    private String slopeMaxForHoldingForceMinInPermille;

    public static List<TrainFormationRunEntity> from(Formation formation) {
        return formation.validFormationRuns().stream()
            .map(formationRun -> {
                TrainFormationRunEntityBuilder builder = TrainFormationRunEntity.builder();
                applyFormationRun(builder, formationRun);
                builder
                    .modifiedDateTime(formation.getModifiedDateTime())
                    .operationalTrainNumber(formation.getOperationalTrainNumber())
                    .operationalDay(formation.getOperationalDay());
                return builder.build();
            })
            .toList();
    }

    private static void applyFormationRun(TrainFormationRunEntityBuilder builder, FormationRun formationRun) {
        builder
            .company(formationRun.getCompany())
            .tafTapLocationReferenceStart(formationRun.getTafTapLocationReferenceStart().toLocationCode())
            .tafTapLocationReferenceEnd(formationRun.getTafTapLocationReferenceEnd().toLocationCode())
            .trainCategoryCode(formationRun.getTrainCategoryCode())
            .brakedWeightPercentage(formationRun.getBrakedWeightPercentage())
            .tractionMaxSpeedInKmh(formationRun.getTractionMaxSpeedInKmh())
            .hauledLoadMaxSpeedInKmh(formationRun.getHauledLoadMaxSpeedInKmh())
            .formationMaxSpeedInKmh(formationRun.getFormationMaxSpeedInKmh())
            .tractionLengthInCm(formationRun.getTractionLengthInCm())
            .hauledLoadLengthInCm(formationRun.getHauledLoadLengthInCm())
            .formationLengthInCm(formationRun.getFormationLengthInCm())
            .tractionWeightInT(formationRun.getTractionGrossWeightInT())
            .hauledLoadWeightInT(formationRun.getHauledLoadGrossWeightInT())
            .formationWeightInT(formationRun.getFormationGrossWeightInT())
            .tractionBrakedWeightInT(formationRun.getTractionBrakedWeightInT())
            .hauledLoadBrakedWeightInT(formationRun.getHauledLoadBrakedWeightInT())
            .formationBrakedWeightInT(formationRun.getFormationBrakedWeightInT())
            .tractionHoldingForceInHectoNewton(formationRun.getTractionHoldingForceInHectoNewton())
            .hauledLoadHoldingForceInHectoNewton(formationRun.getHauledLoadHoldingForceInHectoNewton())
            .formationHoldingForceInHectoNewton(formationRun.getFormationHoldingForceInHectoNewton())
            .brakePositionGForLeadingTraction(formationRun.getBrakePositionGForLeadingTraction())
            .brakePositionGForBrakeUnit1to5(formationRun.getBrakePositionGForBrakeUnit1to5())
            .brakePositionGForLoadHauled(formationRun.getBrakePositionGForLoadHauled())
            .simTrain(formationRun.getSimTrain())
            .tractionModes(mapTractionModes(formationRun.getTractionModes()))
            .carCarrierVehicle(formationRun.getCarCarrierVehicle())
            .dangerousGoods(formationRun.hasDangerousGoods())
            .vehiclesCount(formationRun.vehicleCount())
            .vehiclesWithBrakeDesignLlAndKCount(formationRun.vehiclesWithBrakeDesignCount(BrakeDesign.LL_KUNSTSTOFF_LEISE_LEISE, BrakeDesign.KUNSTSTOFF_BREMSKLOETZE))
            .vehiclesWithBrakeDesignDCount(formationRun.vehiclesWithBrakeDesignCount(BrakeDesign.NORMALE_BREMSAUSRUESTUNG_KEINE_MERKMALE))
            .vehiclesWithDisabledBrakesCount(formationRun.vehiclesWithDisabledBrakeCount())
            .europeanVehicleNumberFirst(formationRun.europeanVehicleNumberFirst() != null ? formationRun.europeanVehicleNumberFirst().toVehicleCode() : null)
            .europeanVehicleNumberLast(formationRun.europeanVehicleNumberLast() != null ? formationRun.europeanVehicleNumberLast().toVehicleCode() : null)
            .axleLoadMaxInKg(formationRun.getAxleLoadMaxInKg())
            .routeClass(formationRun.getRouteClass())
            .gradientUphillMaxInPermille(formationRun.getGradientUphillMaxInPermille())
            .gradientDownhillMaxInPermille(formationRun.getGradientDownhillMaxInPermille())
            .slopeMaxForHoldingForceMinInPermille(formationRun.getSlopeMaxForHoldingForceMinInPermille());

    }

    private static List<String> mapTractionModes(List<TractionMode> tractionModes) {
        return tractionModes.stream()
            .map(TractionMode::getKey)
            .toList();
    }
}
