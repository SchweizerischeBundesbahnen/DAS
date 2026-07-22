package ch.sbb.das.backend.cargo.infrastructure.model;

import ch.sbb.das.backend.common.SFERA;
import ch.sbb.das.backend.common.StringListConverter;
import ch.sbb.das.backend.common.TelTsi;
import ch.sbb.das.backend.companies.CompanyCode;
import ch.sbb.das.backend.companies.CompanyCodeConverter;
import jakarta.persistence.Column;
import jakarta.persistence.Convert;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
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

    /**
     * Position of this formation run within the formation.
     */
    @Column(nullable = false)
    private Integer position;

    private String trainPathId;

    private OffsetDateTime inspectionDateTime;

    @SFERA @TelTsi
    private String operationalTrainNumber;

    @SFERA(nsp = true)
    private LocalDate operationalDay;

    @SFERA @TelTsi
    @Convert(converter = CompanyCodeConverter.class)
    private CompanyCode company;

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
    private List<String> additionalTractions;

    private Boolean carCarrierVehicle;

    private Boolean dangerousGoods;

    private Integer vehiclesCount;

    @Column(name = "vehicles_with_brake_design_l_and_ll_and_k_count")
    private Integer vehiclesWithBrakeDesignLAndLlAndKCount;

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
