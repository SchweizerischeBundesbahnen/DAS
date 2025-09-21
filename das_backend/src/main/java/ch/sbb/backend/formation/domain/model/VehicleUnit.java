package ch.sbb.backend.formation.domain.model;

import java.util.Arrays;
import java.util.List;
import lombok.Builder;
import lombok.EqualsAndHashCode;
import lombok.Getter;
import lombok.ToString;

@Builder
@EqualsAndHashCode
@ToString
public class VehicleUnit {

    private static final int TON_IN_HECTO_NEWTON = 10;

    private BrakeDesign brakeDesign;
    private BrakeStatus brakeStatus;
    private Integer technicalHoldingForceInHectoNewton;
    private Integer effectiveOperationalHoldingForceInHectoNewton;
    private Integer handBrakeWeightInT;
    private Load load;
    @Getter private String vehicleSeries;

    static boolean hasDisabledBrake(List<VehicleUnit> vehicleUnits) {
        if (vehicleUnits == null) {
            return false;
        }
        return vehicleUnits.stream().anyMatch(vehicleUnit -> vehicleUnit.brakeStatus.isDisabled());
    }

    static boolean hasDangerousGoods(List<VehicleUnit> vehicleUnits) {
        if (vehicleUnits == null) {
            return false;
        }
        return vehicleUnits.stream()
            .anyMatch(VehicleUnit::hasDangerousGoods);
    }

    static boolean hasBrakeDesign(List<VehicleUnit> vehicleUnits, BrakeDesign... brakeDesigns) {
        if (vehicleUnits == null) {
            return false;
        }
        return vehicleUnits.stream()
            .anyMatch(vehicleUnit -> vehicleUnit.hasBrakeDesign(brakeDesigns));
    }

    Integer calculateHoldingForce(boolean isTraction) {
        if (isTraction) {
            if (technicalHoldingForceInHectoNewton != null) {
                return technicalHoldingForceInHectoNewton;
            }
        } else {
            if (effectiveOperationalHoldingForceInHectoNewton != null) {
                return effectiveOperationalHoldingForceInHectoNewton;
            }
        }
        if (handBrakeWeightInT != null) {
            return handBrakeWeightInT * TON_IN_HECTO_NEWTON;
        }
        // todo: default value needs to be defined by business
        return 0;
    }

    private boolean hasBrakeDesign(BrakeDesign... brakeDesigns) {
        if (brakeDesigns == null || brakeDesigns.length == 0) {
            return false;
        }
        return Arrays.asList(brakeDesigns).contains(brakeDesign);
    }

    private boolean hasDangerousGoods() {
        return load != null && load.hasDangerousGoods();
    }
}
