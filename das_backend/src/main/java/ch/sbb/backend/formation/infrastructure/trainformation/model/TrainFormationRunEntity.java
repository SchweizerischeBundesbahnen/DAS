package ch.sbb.backend.formation.infrastructure.trainformation.model;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.SequenceGenerator;
import java.time.LocalDate;
import java.time.LocalDateTime;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
@Entity(name = "train_formation_run")
public class TrainFormationRunEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.SEQUENCE, generator = "train_formation_run_id_seq")
    @SequenceGenerator(name = "train_formation_run_id_seq", allocationSize = 1)
    private Integer id;

    private LocalDateTime modifiedDateTime;

    @TelTsi
    private String operationalTrainNumber;

    @TelTsi
    private LocalDate startDate;

    @TelTsi
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

    @Column(name = "traction_gross_weight_in_t")
    private Integer tractionGrossWeightInT;

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
    private boolean brakePositionGForLeadingTraction;

    @Column(name = "brake_position_g_for_brake_unit_1_to_5")
    private boolean brakePositionGForBrakeUnit1to5;

    @Column(name = "brake_position_g_for_load_hauled")
    private boolean brakePositionGForLoadHauled;

    private boolean simTrain;

    @Enumerated(EnumType.STRING)
    private TractionMode tractionMode;

    private boolean carCarrierVehicle;

    private boolean dangerousGoods;

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
}