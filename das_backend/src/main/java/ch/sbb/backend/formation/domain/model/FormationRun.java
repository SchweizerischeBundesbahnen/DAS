package ch.sbb.backend.formation.domain.model;

import ch.sbb.backend.common.TelTsi;
import java.util.Collections;
import java.util.List;
import lombok.Builder;
import lombok.EqualsAndHashCode;
import lombok.Getter;

@Builder
@EqualsAndHashCode
public class FormationRun {

    private Boolean inspected;
    @Getter @TelTsi
    private String company;
    @Getter private TafTapLocationReference tafTapLocationReferenceStart;
    @Getter private TafTapLocationReference tafTapLocationReferenceEnd;
    @Getter private String trainCategoryCode;
    @Getter private Integer brakedWeightPercentage;
    @Getter private Integer tractionMaxSpeedInKmh;
    @Getter private Integer hauledLoadMaxSpeedInKmh;
    @Getter private Integer formationMaxSpeedInKmh;
    @Getter private Integer tractionLengthInCm;
    @Getter private Integer hauledLoadLengthInCm;
    @Getter private Integer formationLengthInCm;
    @Getter private Integer tractionGrossWeightInT;
    @Getter private Integer hauledLoadGrossWeightInT;
    @Getter private Integer tractionBrakedWeightInT;
    @Getter private Integer hauledLoadBrakedWeightInT;
    @Getter private Boolean brakePositionGForLeadingTraction;
    @Getter private Boolean brakePositionGForBrakeUnit1to5;
    @Getter private Boolean brakePositionGForLoadHauled;
    @Getter private Boolean simTrain;
    @Getter private Boolean carCarrierVehicle;
    @Getter private Integer axleLoadMaxInKg;
    @Getter private String routeClass;
    @Getter private Integer gradientUphillMaxInPermille;
    @Getter private Integer gradientDownhillMaxInPermille;
    @Getter private String slopeMaxForHoldingForceMinInPermille;
    private List<Vehicle> vehicles;

    static List<FormationRun> inspected(List<FormationRun> formationRuns) {
        if (formationRuns == null) {
            return Collections.emptyList();
        }
        return formationRuns.stream()
            .filter(formationRun -> formationRun.inspected)
            .toList();
    }

    public Integer formationGrossWeightInT() {
        if (tractionGrossWeightInT == null || hauledLoadGrossWeightInT == null) {
            return null;
        }
        return tractionGrossWeightInT + hauledLoadGrossWeightInT;
    }

    public Integer formationBrakedWeightInT() {
        if (tractionBrakedWeightInT == null || hauledLoadBrakedWeightInT == null) {
            return null;
        }
        return tractionBrakedWeightInT + hauledLoadBrakedWeightInT;
    }

    public Integer tractionHoldingForceInHectoNewton() {
        return Vehicle.tractionHoldingForceInHectoNewton(vehicles);
    }

    public Integer hauledLoadHoldingForceInHectoNewton() {
        return Vehicle.hauledLoadHoldingForceInHectoNewton(vehicles);
    }

    public Integer formationHoldingForceInHectoNewton() {
        return Vehicle.holdingForce(vehicles);
    }

    public List<TractionMode> tractionModes() {
        if (vehicles == null) {
            return Collections.emptyList();
        }
        return vehicles.stream()
            .filter(Vehicle::isTraction)
            .map(Vehicle::getTractionMode)
            .toList();
    }

    public boolean hasDangerousGoods() {
        return Vehicle.hasDangerousGoods(vehicles);
    }

    public Integer vehicleCount() {
        if (vehicles == null) {
            return 0;
        }
        return vehicles.size();
    }

    public Integer vehiclesWithBrakeDesignCount(BrakeDesign... brakeDesigns) {
        return Vehicle.brakeDesignCount(vehicles, brakeDesigns);
    }

    public Integer vehiclesWithDisabledBrakeCount() {
        return Vehicle.disabledBrakeCount(vehicles);
    }

    public EuropeanVehicleNumber europeanVehicleNumberFirst() {
        return Vehicle.first(vehicles) != null ? Vehicle.first(vehicles).getEuropeanVehicleNumber() : null;
    }

    public EuropeanVehicleNumber europeanVehicleNumberLast() {
        return Vehicle.last(vehicles) != null ? Vehicle.last(vehicles).getEuropeanVehicleNumber() : null;
    }
}

