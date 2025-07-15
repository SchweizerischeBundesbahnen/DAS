package ch.sbb.backend.formation.domain.model;

import ch.sbb.backend.common.TelTsi;
import java.util.List;
import lombok.AllArgsConstructor;

@AllArgsConstructor
public class FormationRun {

    private Boolean inspected;
    @TelTsi
    private String company;
    private TafTapLocationReference tafTapLocationReferenceStart;
    private TafTapLocationReference tafTapLocationReferenceEnd;
    private String trainCategoryCode;
    private Integer brakedWeightPercentage;
    private Integer tractionMaxSpeedInKmh;
    private Integer hauledLoadMaxSpeedInKmh;
    private Integer tractionLengthInCm;
    private Integer hauledLoadLengthInCm;
    private Integer tractionGrossWeightInT;
    private Integer hauledLoadGrossWeightInT;
    private Integer tractionBrakedWeightInT;
    private Integer hauledLoadBrakedWeightInT;
    private Boolean brakePositionGForLeadingTraction;
    private Boolean brakePositionGForBrakeUnit1to5;
    private Boolean brakePositionGForLoadHauled;
    private Boolean simTrain;
    private Boolean carCarrierVehicle;
    private Integer axleLoadMaxInKg;
    private String routeClass;
    private Integer gradientUphillMaxInPermille;
    private Integer gradientDownhillMaxInPermille;
    private String slopeMaxForHoldingForceMinInPermille;
    private List<Vehicle> vehicles;

    static List<FormationRun> inspected(List<FormationRun> formationRuns) {
        if (formationRuns == null || formationRuns.isEmpty()) {
            return List.of();
        }
        return formationRuns.stream()
            .filter(formationRun -> formationRun.inspected)
            .toList();
    }

    public String getCompany() {
        return company;
    }

    public TafTapLocationReference getTafTapLocationReferenceStart() {
        return tafTapLocationReferenceStart;
    }

    public TafTapLocationReference getTafTapLocationReferenceEnd() {
        return tafTapLocationReferenceEnd;
    }

    public String getTrainCategoryCode() {
        return trainCategoryCode;
    }

    public Integer getBrakedWeightPercentage() {
        return brakedWeightPercentage;
    }

    public Integer getTractionMaxSpeedInKmh() {
        return tractionMaxSpeedInKmh;
    }

    public Integer getHauledLoadMaxSpeedInKmh() {
        return hauledLoadMaxSpeedInKmh;
    }

    public Integer getTractionLengthInCm() {
        return tractionLengthInCm;
    }

    public Integer getHauledLoadLengthInCm() {
        return hauledLoadLengthInCm;
    }

    public Integer getTractionGrossWeightInT() {
        return tractionGrossWeightInT;
    }

    public Integer getHauledLoadGrossWeightInT() {
        return hauledLoadGrossWeightInT;
    }

    public Integer getTractionBrakedWeightInT() {
        return tractionBrakedWeightInT;
    }

    public Integer getHauledLoadBrakedWeightInT() {
        return hauledLoadBrakedWeightInT;
    }

    public boolean isBrakePositionGForLeadingTraction() {
        return brakePositionGForLeadingTraction;
    }

    public boolean isBrakePositionGForBrakeUnit1to5() {
        return brakePositionGForBrakeUnit1to5;
    }

    public boolean isBrakePositionGForLoadHauled() {
        return brakePositionGForLoadHauled;
    }

    public boolean isSimTrain() {
        return simTrain;
    }

    public boolean isCarCarrierVehicle() {
        return carCarrierVehicle;
    }

    public Integer getAxleLoadMaxInKg() {
        return axleLoadMaxInKg;
    }

    public String getRouteClass() {
        return routeClass;
    }

    public Integer getGradientUphillMaxInPermille() {
        return gradientUphillMaxInPermille;
    }

    public Integer getGradientDownhillMaxInPermille() {
        return gradientDownhillMaxInPermille;
    }

    public String getSlopeMaxForHoldingForceMinInPermille() {
        return slopeMaxForHoldingForceMinInPermille;
    }

    public Integer formationMaxSpeedInKmh() {
        return tractionMaxSpeedInKmh + hauledLoadMaxSpeedInKmh;
    }

    public Integer formationLenghtInCm() {
        return tractionMaxSpeedInKmh + hauledLoadMaxSpeedInKmh;
    }

    public Integer formationGrossWeightInT() {
        return tractionGrossWeightInT + hauledLoadGrossWeightInT;
    }

    public Integer formationBrakedWeightInT() {
        return tractionBrakedWeightInT + hauledLoadBrakedWeightInT;
    }

    public Integer tractionHoldingForceInHectoNewton() {
        return Vehicle.filterTraction(vehicles).stream()
            .mapToInt(Vehicle::holdingForce).sum();
    }

    public Integer hauledLoadHolding() {
        return Vehicle.filterHauledLoad(vehicles).stream()
            .mapToInt(Vehicle::holdingForce).sum();
    }

    public Integer formationHoldingForceInHectoNewton() {
        return vehicles.stream().mapToInt(Vehicle::holdingForce).sum();
    }

    public List<TractionMode> tractionModes() {
        return vehicles.stream()
            .filter(Vehicle::isTraction)
            .map(Vehicle::getTractionMode)
            .toList();
    }

    public boolean hasDangerousGoods() {
        return Vehicle.hasDangerousGoods(vehicles);
    }

    public Integer vehicleCount() {
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
        return Vehicle.first(vehicles) != null ? Vehicle.last(vehicles).getEuropeanVehicleNumber() : null;
    }
}

