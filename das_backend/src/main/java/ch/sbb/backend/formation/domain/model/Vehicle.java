package ch.sbb.backend.formation.domain.model;

import java.util.List;
import lombok.AllArgsConstructor;
import lombok.EqualsAndHashCode;
import lombok.ToString;

@AllArgsConstructor
@EqualsAndHashCode
@ToString
public class Vehicle {

    /**
     * Additional traction modes that are not considered as main traction.
     */
    private static final List<TractionMode> ADDITIONAL_TRACTION_MODES = List.of(TractionMode.ZWISCHENLOK, TractionMode.SCHIEBELOK, TractionMode.UEBERFUEHRUNG);
    private TractionMode tractionMode;
    private String vehicleCategory;
    private List<VehicleUnit> vehicleUnits;
    private EuropeanVehicleNumber europeanVehicleNumber;

    static int hauledLoadCount(List<Vehicle> vehicles) {
        return filterHauledLoad(vehicles).size();
    }

    static String getEuropeanVehicleNumberFirst(List<Vehicle> vehicles) {
        List<Vehicle> hauledLoadVehicles = filterHauledLoad(vehicles);
        if (hauledLoadVehicles.isEmpty() || hauledLoadVehicles.getFirst().europeanVehicleNumber == null) {
            return null;
        }
        return hauledLoadVehicles.getFirst().europeanVehicleNumber.toVehicleCode();
    }

    static String getEuropeanVehicleNumberLast(List<Vehicle> vehicles) {
        List<Vehicle> hauledLoadVehicles = filterHauledLoad(vehicles);
        if (hauledLoadVehicles.isEmpty() || hauledLoadVehicles.getLast().europeanVehicleNumber == null) {
            return null;
        }
        return hauledLoadVehicles.getLast().europeanVehicleNumber.toVehicleCode();
    }

    static boolean hasDangerousGoods(List<Vehicle> vehicles) {
        return vehicles.stream()
            .anyMatch(Vehicle::hasDangerousGoods);
    }

    static Integer countBrakeDesigns(List<Vehicle> vehicles, BrakeDesign... brakeDesigns) {
        return (int) filterHauledLoad(vehicles).stream().filter(vehicle -> vehicle.hasBrakeDesign(brakeDesigns)).count();
    }

    static Integer countDisabledBrakes(List<Vehicle> vehicles) {
        return (int) filterHauledLoad(vehicles).stream().filter(Vehicle::hasDisabledBrake).count();
    }

    static Integer calculateHoldingForce(List<Vehicle> vehicles) {
        List<Integer> holdingForces = vehicles.stream()
            .map(Vehicle::calculateHoldingForce)
            .toList();
        if (holdingForces.isEmpty() || holdingForces.stream().anyMatch(java.util.Objects::isNull)) {
            return null;
        }
        return holdingForces.stream().mapToInt(Integer::intValue).sum();
    }

    static Integer calculateTractionHoldingForceInHectoNewton(List<Vehicle> vehicles) {
        return Vehicle.calculateHoldingForce(Vehicle.filterTraction(vehicles));
    }

    static Integer calculateHauledLoadHoldingForceInHectoNewton(List<Vehicle> vehicles) {
        return Vehicle.calculateHoldingForce(Vehicle.filterHauledLoad(vehicles));
    }

    private static List<Vehicle> filterHauledLoad(List<Vehicle> vehicles) {
        return vehicles.stream()
            .filter(vehicle -> !vehicle.isTraction())
            .toList();
    }

    private static List<Vehicle> filterTraction(List<Vehicle> vehicles) {
        return vehicles.stream()
            .filter(Vehicle::isTraction)
            .toList();
    }

    static List<String> getAdditionalTractions(List<Vehicle> vehicles) {
        return filterAdditionalTractionVehicles(vehicles).stream().map(Vehicle::getAdditionalTraction).toList();
    }

    private static List<Vehicle> filterAdditionalTractionVehicles(List<Vehicle> vehicles) {
        return filterTraction(vehicles).stream().filter(vehicle -> ADDITIONAL_TRACTION_MODES.contains(vehicle.tractionMode)).toList();
    }

    private String getAdditionalTraction() {
        if (vehicleUnits.size() != 1) {
            throw new UnexpectedProviderData("Additional traction vehicle must have exactly one vehicle unit");
        }
        return String.format("%s (%s)", tractionMode.getKey(), vehicleUnits.getFirst().getVehicleSeries());
    }

    private boolean isTraction() {
        return TractionMode.SCHLEPPLOK != this.tractionMode &&
            (VehicleCategory.LOKOMOTIVE.name().equals(this.vehicleCategory) || VehicleCategory.TRIEBWAGEN.name().equals(this.vehicleCategory) || VehicleCategory.GLIEDERFAHRZEUG.name()
                .equals(this.vehicleCategory));
    }

    private boolean hasDangerousGoods() {
        return VehicleUnit.hasDangerousGoods(vehicleUnits);
    }

    private boolean hasDisabledBrake() {
        return VehicleUnit.hasDisabledBrake(vehicleUnits);
    }

    private Integer calculateHoldingForce() {
        List<Integer> holdingForces = vehicleUnits.stream()
            .map(vehicleUnit -> vehicleUnit.calculateHoldingForce(isTraction()))
            .toList();

        if (holdingForces.stream().anyMatch(java.util.Objects::isNull)) {
            return null;
        }
        return holdingForces.stream().mapToInt(Integer::intValue).sum();
    }

    private boolean hasBrakeDesign(BrakeDesign... brakeDesigns) {
        return VehicleUnit.hasBrakeDesign(vehicleUnits, brakeDesigns);
    }
}
