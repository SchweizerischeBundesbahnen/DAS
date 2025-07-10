package ch.sbb.backend.formation.domain.model;

import ch.sbb.backend.common.TelTsi;
import ch.sbb.zis.trainformation.api.model.BrakeCalculationResult;
import ch.sbb.zis.trainformation.api.model.ConsolidatedBrakingInformation;
import ch.sbb.zis.trainformation.api.model.FormationRun;
import ch.sbb.zis.trainformation.api.model.Load;
import ch.sbb.zis.trainformation.api.model.LocationUic;
import ch.sbb.zis.trainformation.api.model.Vehicle;
import ch.sbb.zis.trainformation.api.model.VehicleGroup;
import ch.sbb.zis.trainformation.api.model.VehicleUnit;
import java.time.LocalDate;
import java.time.OffsetDateTime;
import java.util.Collections;
import java.util.List;
import java.util.function.Function;
import java.util.stream.Stream;
import lombok.AllArgsConstructor;
import lombok.Getter;

/**
 * ZIS-Formation delivers DailyFormationTrain's which consists of FormationRun's. (Remark: a Formation, FormationTrain, Composition or TrainFromation corresponds to a Transmodel "COMPOUND TRAIN".)
 * <p>
 * This class maintains a FormationRun, by means the snapshot between stop-points (de:Betriebspunkte) out of a DailyFormationTrain.
 *
 * @see <a href="https://confluence.sbb.ch/spaces/DASBP/pages/3037422329/Cargo+Formation+ZIS-Formation">ZIS Mapping / Business rules</a>
 */
@AllArgsConstructor
@Getter
public class TrainFormationRun {

    private static final int TON_IN_HECTO_NEWTON = 10;
    private static final int DISABLED_BRAKE_STATUS = 0;

    private OffsetDateTime modifiedDateTime;
    @TelTsi
    private String operationalTrainNumber;
    private LocalDate operationalDay;
    @TelTsi
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
    private Integer tractionGrossWeightInT;
    private Integer hauledLoadWeightInT;
    private Integer formationWeightInT;
    private Integer tractionBrakedWeightInT;
    private Integer hauledLoadBrakedWeightInT;
    private Integer formationBrakedWeightInT;
    private Integer tractionHoldingForceInHectoNewton;
    private Integer hauledLoadHoldingForceInHectoNewton;
    private Integer formationHoldingForceInHectoNewton;
    private boolean brakePositionGForLeadingTraction;
    private boolean brakePositionGForBrakeUnit1to5;
    private boolean brakePositionGForLoadHauled;
    private boolean simTrain;
    private List<String> tractionModes;
    private boolean carCarrierVehicle;
    private boolean dangerousGoods;
    private Integer vehiclesCount;
    private Integer vehiclesWithBrakeDesignLlAndKCount;
    private Integer vehiclesWithBrakeDesignDCount;
    private Integer vehiclesWithDisabledBrakesCount;
    private String europeanVehicleNumberFirst;
    private String europeanVehicleNumberLast;
    private Integer axleLoadMaxInKg;
    private String routeClass;
    private Integer gradientUphillMaxInPermille;
    private Integer gradientDownhillMaxInPermille;
    private String slopeMaxForHoldingForceMinInPermille;

    public TrainFormationRun(OffsetDateTime modifiedDateTime, LocalDate operationalDay, String operationalTrainNumber, FormationRun formationRun) {
        this.modifiedDateTime = modifiedDateTime;
        this.operationalDay = operationalDay;
        this.operationalTrainNumber = operationalTrainNumber;
        //        todo check company
        this.company = formationRun.getSmsEvu();
        this.tafTapLocationReferenceStart = toLocationReference(formationRun.getStartLocationUic());
        this.tafTapLocationReferenceEnd = toLocationReference(formationRun.getEndLocationUic());
        this.trainCategoryCode = formationRun.getTrainSequence();
        this.brakedWeightPercentage = formationRun.getBrakeSequence();
        ConsolidatedBrakingInformation consolidatedBrakingInformation = formationRun.getConsolidatedBrakingInformation();
        this.tractionMaxSpeedInKmh = consolidatedBrakingInformation.getTractionMaxSpeedInKilometerPerHour();
        this.hauledLoadMaxSpeedInKmh = consolidatedBrakingInformation.getHauledLoadMaxSpeedInKilometerPerHour();
        this.formationMaxSpeedInKmh = consolidatedBrakingInformation.getFormationMaxSpeedInKilometerPerHour();
        BrakeCalculationResult brakeCalculationResult = formationRun.getFormationRunInspection().getBrakeCalculationResult();
        this.tractionLengthInCm = brakeCalculationResult.getTractionLengthInCentimeter();
        this.hauledLoadLengthInCm = brakeCalculationResult.getHauledLoadLengthInCentimeter();
        this.formationLengthInCm = brakeCalculationResult.getTotalLengthInCentimeter();
        this.tractionGrossWeightInT = brakeCalculationResult.getTractionGrossWeightInTonne();
        this.hauledLoadWeightInT = brakeCalculationResult.getHauledLoadInTonne();
        this.formationWeightInT = sum(this.tractionGrossWeightInT, this.hauledLoadWeightInT);
        this.tractionBrakedWeightInT = brakeCalculationResult.getTractionBrakedWeightInTonne();
        this.hauledLoadBrakedWeightInT = brakeCalculationResult.getHauledLoadBrakedWeightInTonne();
        this.formationBrakedWeightInT = sum(this.tractionBrakedWeightInT, this.hauledLoadBrakedWeightInT);
        List<Vehicle> allVehicles = extractVehicles(formationRun.getVehicleGroups());
        this.tractionHoldingForceInHectoNewton = tractionHoldingForce(allVehicles);
        this.hauledLoadHoldingForceInHectoNewton = hauledLoadHoldingForce(allVehicles);
        this.formationHoldingForceInHectoNewton = sum(this.tractionHoldingForceInHectoNewton, this.hauledLoadHoldingForceInHectoNewton);
        this.brakePositionGForLeadingTraction = brakeCalculationResult.getBrakePositionGForLeadingTraction() != null && brakeCalculationResult.getBrakePositionGForLeadingTraction();
        this.brakePositionGForBrakeUnit1to5 = brakeCalculationResult.getBrakePositionGForBrakeUnit1to5() != null && brakeCalculationResult.getBrakePositionGForBrakeUnit1to5();
        this.brakePositionGForLoadHauled = brakeCalculationResult.getBrakePositionGForLoadHauled() != null && brakeCalculationResult.getBrakePositionGForLoadHauled();
        this.simTrain = consolidatedBrakingInformation.getIsSimZug() != null && consolidatedBrakingInformation.getIsSimZug();
        this.tractionModes = tractionModes(allVehicles);
        this.carCarrierVehicle = consolidatedBrakingInformation.getCarCarrierWagon() != null && consolidatedBrakingInformation.getCarCarrierWagon();
        this.dangerousGoods = hasDangerousGoods(allVehicles);
        this.vehiclesCount = allVehicles.size();
        this.vehiclesWithBrakeDesignLlAndKCount = vehiclesWithBrakeDesignLlAndKCount(allVehicles);
        this.vehiclesWithBrakeDesignDCount = vehiclesWithBrakeDesignDCount(allVehicles);
        this.vehiclesWithDisabledBrakesCount = vehiclesWithDisabledBrakesCount(allVehicles);
        europeanVehicleNumbers(allVehicles);
        this.axleLoadMaxInKg = consolidatedBrakingInformation.getMaxAxleLoadInKilogrammes();
        this.routeClass = consolidatedBrakingInformation.getRouteClass();
        if (consolidatedBrakingInformation.getMaxUphillDownhillGradients() != null) {
            this.gradientUphillMaxInPermille = consolidatedBrakingInformation.getMaxUphillDownhillGradients().getMaxUphillGradientInPermille();
            this.gradientDownhillMaxInPermille = consolidatedBrakingInformation.getMaxUphillDownhillGradients().getMaxDownhillGradientInPermille();
        }
        this.slopeMaxForHoldingForceMinInPermille = consolidatedBrakingInformation.getMaximumSlopeForMinimumHoldingForceInPermille();
    }

    private static Function<Vehicle, Stream<? extends VehicleUnit>> extractVehicleUnits() {
        return vehicle -> vehicle.getVehicleUnits() == null ? Stream.empty() : vehicle.getVehicleUnits().stream();
    }

    private Integer sum(Integer a, Integer b) {
        return (a != null ? a : 0) + (b != null ? b : 0);
    }

    List<String> tractionModes(List<Vehicle> vehicles) {
        return vehicles.stream().filter(this::isTractionVehicle)
            .filter(vehicle -> vehicle.getVehicleEffectiveTractionData() != null && vehicle.getVehicleEffectiveTractionData().getTractionMode() != null)
            .map(vehicle -> vehicle.getVehicleEffectiveTractionData().getTractionMode())
            .toList();
    }

    void europeanVehicleNumbers(List<Vehicle> vehicles) {
        List<Vehicle> hauledLoadVehicles = vehicles.stream().filter(vehicle -> !isTractionVehicle(vehicle)).toList();
        if (hauledLoadVehicles.isEmpty()) {
            return;
        }
        this.europeanVehicleNumberFirst = europeanVehicleNumber(hauledLoadVehicles.getFirst());
        this.europeanVehicleNumberLast = europeanVehicleNumber(hauledLoadVehicles.getLast());
    }

    String europeanVehicleNumber(Vehicle vehicle) {
        if (vehicle.getEuropeanVehicleNumber() != null && vehicle.getEuropeanVehicleNumber().getCountryCodeUic() != null && vehicle.getEuropeanVehicleNumber().getVehicleNumber() != null) {
            return vehicle.getEuropeanVehicleNumber().getCountryCodeUic() + vehicle.getEuropeanVehicleNumber().getVehicleNumber();
        }
        return null;
    }

    boolean hasDangerousGoods(List<Vehicle> vehicles) {
        return vehicles.stream()
            .flatMap(extractVehicleUnits())
            .map(vehicleUnit -> vehicleUnit.getCargoTransport() == null ? null : vehicleUnit.getCargoTransport().getLoad())
            .anyMatch(this::hasLoadDangerousGoods);
    }

    private boolean hasLoadDangerousGoods(Load load) {
        if (load == null) {
            return false;
        }
        boolean hasDangerousGoods = load.getGoods() != null && load.getGoods().stream()
            .anyMatch(goods -> goods.getDangerousGoods() != null && !goods.getDangerousGoods().isEmpty());
        boolean hasIntermodalLoadingUnitsDangerousGoods = load.getIntermodalLoadingUnits() != null && load.getIntermodalLoadingUnits().stream()
            .anyMatch(unit -> unit.getGoods() != null && unit.getGoods().stream()
                .anyMatch(goods -> goods.getDangerousGoods() != null && !goods.getDangerousGoods().isEmpty()));
        return hasDangerousGoods || hasIntermodalLoadingUnitsDangerousGoods;
    }

    List<Vehicle> extractVehicles(List<VehicleGroup> vehicleGroups) {
        if (vehicleGroups == null) {
            return Collections.emptyList();
        }
        return vehicleGroups.stream()
            .flatMap(group -> group.getVehicles() == null ? Stream.empty() : group.getVehicles().stream())
            .toList();
    }

    private int tractionHoldingForce(List<Vehicle> vehicles) {
        return vehicles.stream()
            .filter(this::isTractionVehicle)
            .flatMap(extractVehicleUnits())
            .map(vehicleUnit -> {
                if (vehicleUnit != null && vehicleUnit.getUnitTechnicalData() != null && vehicleUnit.getUnitTechnicalData().getHoldingForceInHectonewton() != null) {
                    return vehicleUnit.getUnitTechnicalData().getHoldingForceInHectonewton();
                }
                if (vehicleUnit != null && vehicleUnit.getUnitTechnicalData() != null && vehicleUnit.getUnitTechnicalData().getHandBrakeWeightInTonne() != null) {
                    return vehicleUnit.getUnitTechnicalData().getHandBrakeWeightInTonne() * TON_IN_HECTO_NEWTON;
                }
                return 0;
            })
            .mapToInt(Integer::intValue)
            .sum();
    }

    private int hauledLoadHoldingForce(List<Vehicle> vehicles) {
        return vehicles.stream()
            .filter(vehicle -> !isTractionVehicle(vehicle))
            .flatMap(extractVehicleUnits())
            .map(vehicleUnit -> {
                if (vehicleUnit != null && vehicleUnit.getUnitEffectiveOperationalData() != null && vehicleUnit.getUnitEffectiveOperationalData().getHoldingForceInHectonewton() != null) {
                    return vehicleUnit.getUnitEffectiveOperationalData().getHoldingForceInHectonewton();
                }
                if (vehicleUnit != null && vehicleUnit.getUnitTechnicalData() != null && vehicleUnit.getUnitTechnicalData().getHandBrakeWeightInTonne() != null) {
                    return vehicleUnit.getUnitTechnicalData().getHandBrakeWeightInTonne() * TON_IN_HECTO_NEWTON;
                }
                return 0;
            })
            .mapToInt(Integer::intValue)
            .sum();
    }

    private boolean isTractionVehicle(Vehicle vehicle) {
        String vehicleCategory = vehicle.getVehicleCategory();
        TractionMode vehicleTractionMode = vehicle.getVehicleEffectiveTractionData() != null ? TractionMode.valueOfKey(vehicle.getVehicleEffectiveTractionData().getTractionMode()) : null;
        return TractionMode.SCHLEPPLOK != vehicleTractionMode &&
            (VehicleCategory.LOKOMOTIVE.name().equals(vehicleCategory) || VehicleCategory.TRIEBWAGEN.name().equals(vehicleCategory) || VehicleCategory.GLIEDERFAHRZEUG.name().equals(vehicleCategory));
    }

    String toLocationReference(LocationUic locationUic) {
        return String.format("%02d", locationUic.getCountryCodeUic()) + String.format("%06d", locationUic.getUicCode());
    }

    private Integer vehiclesWithBrakeDesignLlAndKCount(List<Vehicle> vehicles) {
        return filterVehiclesByBrakeDesigns(vehicles, List.of(BrakeDesign.LL_KUNSTSTOFF_LEISE_LEISE, BrakeDesign.KUNSTSTOFF_BREMSKLOETZE)).size();
    }

    private Integer vehiclesWithBrakeDesignDCount(List<Vehicle> vehicles) {
        return filterVehiclesByBrakeDesigns(vehicles, List.of(BrakeDesign.NORMALE_BREMSAUSRUESTUNG_KEINE_MERKMALE)).size();
    }

    private Integer vehiclesWithDisabledBrakesCount(List<Vehicle> vehicles) {
        return vehicles.stream()
            .filter(vehicle -> vehicle.getVehicleUnits().stream()
                .anyMatch(vehicleUnit -> {
                    if (vehicleUnit != null && vehicleUnit.getUnitEffectiveOperationalData() != null && vehicleUnit.getUnitEffectiveOperationalData().getBrakeStatus() != null) {
                        Integer brakeStatus = vehicleUnit.getUnitEffectiveOperationalData().getBrakeStatus();
                        return brakeStatus == DISABLED_BRAKE_STATUS;
                    }
                    return false;
                }))
            .toList()
            .size();
    }

    private List<Vehicle> filterVehiclesByBrakeDesigns(List<Vehicle> vehicles, List<BrakeDesign> brakeDesigns) {
        return vehicles.stream()
            .filter(vehicle -> vehicle.getVehicleUnits().stream()
                .anyMatch(vehicleUnit -> {
                    if (vehicleUnit != null && vehicleUnit.getUnitTechnicalData() != null && vehicleUnit.getUnitTechnicalData().getBrakeDesign() != null) {
                        BrakeDesign brakeDesign = BrakeDesign.valueOfKey(vehicleUnit.getUnitTechnicalData().getBrakeDesign());
                        return brakeDesigns.contains(brakeDesign);
                    }
                    return false;
                }))
            .toList();
    }

    // todo: check if hauled load really is the negation of traction
    //    private boolean isHauledLoad(Vehicle vehicle) {
    //        String vehicleCategory = vehicle.getVehicleCategory();
    //        TractionMode tractionMode = vehicle.getVehicleEffectiveTractionData() != null ? TractionMode.valueOfKey(vehicle.getVehicleEffectiveTractionData().getTractionMode()) : null;
    //        return !Objects.equals(vehicleCategory, "LOKOMOTIVE") && !Objects.equals(vehicleCategory, "TRIEBWAGEN") && !Objects.equals(vehicleCategory, "GLIEDERFAHRZEUG")
    //            || Objects.equals(tractionMode, TractionMode.SCHLEPPLOK);
    //    }

}
