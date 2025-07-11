package ch.sbb.backend.formation.infrastructure.trainformation.model;

import ch.sbb.backend.common.TelTsi;
import ch.sbb.backend.common.utils.StringListConverter;
import ch.sbb.backend.formation.domain.model.TrainFormationRun;
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
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import lombok.Getter;
import lombok.NoArgsConstructor;
import org.hibernate.annotations.JdbcTypeCode;
import org.hibernate.type.SqlTypes;

@Getter
@Entity(name = "train_formation_run")
@NoArgsConstructor
public class TrainFormationRunEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.SEQUENCE, generator = "train_formation_run_id_seq")
    @SequenceGenerator(name = "train_formation_run_id_seq", allocationSize = 1)
    private Integer id;

    private OffsetDateTime modifiedDateTime;

    @TelTsi
    private String operationalTrainNumber;

    private LocalDate operationalDay;

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

    @Convert(converter = StringListConverter.class)
    private List<String> tractionModes;

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

    //    todo remove
    @JdbcTypeCode(SqlTypes.JSON)
    private Map<String, Object> originalZisMessage = new HashMap<>();

    public TrainFormationRunEntity(TrainFormationRun trainFormationRun) {
        modifiedDateTime = trainFormationRun.getModifiedDateTime();
        operationalTrainNumber = trainFormationRun.getOperationalTrainNumber();
        operationalDay = trainFormationRun.getOperationalDay();
        company = trainFormationRun.getCompany();
        tafTapLocationReferenceStart = trainFormationRun.getTafTapLocationReferenceStart();
        tafTapLocationReferenceEnd = trainFormationRun.getTafTapLocationReferenceEnd();
        trainCategoryCode = trainFormationRun.getTrainCategoryCode();
        brakedWeightPercentage = trainFormationRun.getBrakedWeightPercentage();
        tractionMaxSpeedInKmh = trainFormationRun.getTractionMaxSpeedInKmh();
        hauledLoadMaxSpeedInKmh = trainFormationRun.getHauledLoadMaxSpeedInKmh();
        formationMaxSpeedInKmh = trainFormationRun.getFormationMaxSpeedInKmh();
        tractionLengthInCm = trainFormationRun.getTractionLengthInCm();
        hauledLoadLengthInCm = trainFormationRun.getHauledLoadLengthInCm();
        formationLengthInCm = trainFormationRun.getFormationLengthInCm();
        tractionGrossWeightInT = trainFormationRun.getTractionGrossWeightInT();
        hauledLoadWeightInT = trainFormationRun.getHauledLoadWeightInT();
        formationWeightInT = trainFormationRun.getFormationWeightInT();
        tractionBrakedWeightInT = trainFormationRun.getTractionBrakedWeightInT();
        hauledLoadBrakedWeightInT = trainFormationRun.getHauledLoadBrakedWeightInT();
        formationBrakedWeightInT = trainFormationRun.getFormationBrakedWeightInT();
        tractionHoldingForceInHectoNewton = trainFormationRun.getTractionHoldingForceInHectoNewton();
        hauledLoadHoldingForceInHectoNewton = trainFormationRun.getHauledLoadHoldingForceInHectoNewton();
        formationHoldingForceInHectoNewton = trainFormationRun.getFormationHoldingForceInHectoNewton();
        brakePositionGForLeadingTraction = trainFormationRun.isBrakePositionGForLeadingTraction();
        brakePositionGForBrakeUnit1to5 = trainFormationRun.isBrakePositionGForBrakeUnit1to5();
        brakePositionGForLoadHauled = trainFormationRun.isBrakePositionGForLoadHauled();
        simTrain = trainFormationRun.isSimTrain();
        tractionModes = trainFormationRun.getTractionModes();
        carCarrierVehicle = trainFormationRun.isCarCarrierVehicle();
        dangerousGoods = trainFormationRun.isDangerousGoods();
        vehiclesCount = trainFormationRun.getVehiclesCount();
        vehiclesWithBrakeDesignLlAndKCount = trainFormationRun.getVehiclesWithBrakeDesignLlAndKCount();
        vehiclesWithBrakeDesignDCount = trainFormationRun.getVehiclesWithBrakeDesignDCount();
        vehiclesWithDisabledBrakesCount = trainFormationRun.getVehiclesWithDisabledBrakesCount();
        europeanVehicleNumberFirst = trainFormationRun.getEuropeanVehicleNumberFirst();
        europeanVehicleNumberLast = trainFormationRun.getEuropeanVehicleNumberLast();
        axleLoadMaxInKg = trainFormationRun.getAxleLoadMaxInKg();
        routeClass = trainFormationRun.getRouteClass();
        gradientUphillMaxInPermille = trainFormationRun.getGradientUphillMaxInPermille();
        gradientDownhillMaxInPermille = trainFormationRun.getGradientDownhillMaxInPermille();
        slopeMaxForHoldingForceMinInPermille = trainFormationRun.getSlopeMaxForHoldingForceMinInPermille();
    }

    public TrainFormationRun toTrainFormationRun() {
        return new TrainFormationRun(modifiedDateTime, operationalTrainNumber, operationalDay, company,
            tafTapLocationReferenceStart, tafTapLocationReferenceEnd, trainCategoryCode, brakedWeightPercentage,
            tractionMaxSpeedInKmh, hauledLoadMaxSpeedInKmh, formationMaxSpeedInKmh, tractionLengthInCm,
            hauledLoadLengthInCm, formationLengthInCm, tractionGrossWeightInT, hauledLoadWeightInT,
            formationWeightInT, tractionBrakedWeightInT, hauledLoadBrakedWeightInT, formationBrakedWeightInT,
            tractionHoldingForceInHectoNewton, hauledLoadHoldingForceInHectoNewton, formationHoldingForceInHectoNewton,
            brakePositionGForLeadingTraction, brakePositionGForBrakeUnit1to5, brakePositionGForLoadHauled,
            simTrain, tractionModes, carCarrierVehicle, dangerousGoods, vehiclesCount,
            vehiclesWithBrakeDesignLlAndKCount, vehiclesWithBrakeDesignDCount, vehiclesWithDisabledBrakesCount,
            europeanVehicleNumberFirst, europeanVehicleNumberLast, axleLoadMaxInKg, routeClass,
            gradientUphillMaxInPermille, gradientDownhillMaxInPermille, slopeMaxForHoldingForceMinInPermille);
    }
}