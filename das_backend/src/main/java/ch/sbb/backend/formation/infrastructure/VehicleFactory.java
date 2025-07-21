package ch.sbb.backend.formation.infrastructure;

import ch.sbb.backend.formation.domain.model.BrakeDesign;
import ch.sbb.backend.formation.domain.model.BrakeStatus;
import ch.sbb.backend.formation.domain.model.EuropeanVehicleNumber;
import ch.sbb.backend.formation.domain.model.Good;
import ch.sbb.backend.formation.domain.model.IntermodalLoadingUnit;
import ch.sbb.backend.formation.domain.model.Load;
import ch.sbb.backend.formation.domain.model.TractionMode;
import ch.sbb.backend.formation.domain.model.Vehicle;
import ch.sbb.backend.formation.domain.model.VehicleUnit;
import ch.sbb.backend.formation.domain.model.VehicleUnit.VehicleUnitBuilder;
import ch.sbb.zis.trainformation.api.model.CargoTransport;
import ch.sbb.zis.trainformation.api.model.Goods;
import ch.sbb.zis.trainformation.api.model.UnitEffectiveOperationalData;
import ch.sbb.zis.trainformation.api.model.UnitTechnicalData;
import ch.sbb.zis.trainformation.api.model.VehicleEffectiveTractionData;
import ch.sbb.zis.trainformation.api.model.VehicleGroup;
import java.util.Collections;
import java.util.List;
import java.util.stream.Stream;
import lombok.AccessLevel;
import lombok.NoArgsConstructor;

@NoArgsConstructor(access = AccessLevel.PRIVATE)
public final class VehicleFactory {

    public static List<Vehicle> create(List<VehicleGroup> vehicleGroups) {
        return extractVehicles(vehicleGroups).stream()
            .map(VehicleFactory::create)
            .toList();
    }

    private static List<ch.sbb.zis.trainformation.api.model.Vehicle> extractVehicles(List<VehicleGroup> vehicleGroups) {
        if (vehicleGroups == null) {
            return Collections.emptyList();
        }
        return vehicleGroups.stream()
            .flatMap(group -> group.getVehicles() == null ? Stream.empty() : group.getVehicles().stream())
            .toList();
    }

    private static Vehicle create(ch.sbb.zis.trainformation.api.model.Vehicle vehicle) {
        return new Vehicle(mapToTractionMode(vehicle.getVehicleEffectiveTractionData()), vehicle.getVehicleCategory(), mapToVehicleUnits(vehicle.getVehicleUnits()),
            mapToEuropeanVehicleNumber(vehicle.getEuropeanVehicleNumber()));
    }

    private static List<VehicleUnit> mapToVehicleUnits(List<ch.sbb.zis.trainformation.api.model.VehicleUnit> vehicleUnits) {
        return vehicleUnits.stream().map(VehicleFactory::mapToVehicleUnit).toList();
    }

    private static VehicleUnit mapToVehicleUnit(ch.sbb.zis.trainformation.api.model.VehicleUnit vehicleUnit) {
        VehicleUnitBuilder builder = VehicleUnit.builder();
        builder = mapUnitTechnichalData(builder, vehicleUnit.getUnitTechnicalData());
        builder = mapUnitEffectiveOperationalData(builder, vehicleUnit.getUnitEffectiveOperationalData());
        builder = mapLoad(builder, vehicleUnit.getCargoTransport());
        return builder.build();
    }

    private static VehicleUnitBuilder mapLoad(VehicleUnitBuilder builder, CargoTransport cargoTransport) {
        if (cargoTransport == null || cargoTransport.getLoad() == null) {
            return builder;
        }
        return builder.load(mapToLoad(cargoTransport.getLoad()));
    }

    private static VehicleUnitBuilder mapUnitEffectiveOperationalData(VehicleUnitBuilder builder, UnitEffectiveOperationalData unitEffectiveOperationalData) {
        if (unitEffectiveOperationalData == null) {
            return builder;
        }
        return builder
            .brakeStatus(new BrakeStatus(unitEffectiveOperationalData.getBrakeStatus()))
            .effectiveOperationalHoldingForceInHectonewton(unitEffectiveOperationalData.getHoldingForceInHectonewton());
    }

    private static VehicleUnitBuilder mapUnitTechnichalData(VehicleUnitBuilder builder, UnitTechnicalData unitTechnicalData) {
        if (unitTechnicalData == null) {
            return builder;
        }
        return builder
            .brakeDesign(mapToBrakeDesign(unitTechnicalData.getBrakeDesign()))
            .technicalHoldingForceInHectonewton(unitTechnicalData.getHoldingForceInHectonewton())
            .handBrakeWeightInTonne(unitTechnicalData.getHandBrakeWeightInTonne());
    }

    private static Load mapToLoad(ch.sbb.zis.trainformation.api.model.Load load) {
        return new Load(mapToGoodsList(load.getGoods()), mapToIntermodalLoadingUnits(load.getIntermodalLoadingUnits()));
    }

    private static List<IntermodalLoadingUnit> mapToIntermodalLoadingUnits(List<ch.sbb.zis.trainformation.api.model.IntermodalLoadingUnit> intermodalLoadingUnits) {
        return intermodalLoadingUnits.stream().map(VehicleFactory::mapToIntermodalLoadingUnit).toList();
    }

    private static IntermodalLoadingUnit mapToIntermodalLoadingUnit(ch.sbb.zis.trainformation.api.model.IntermodalLoadingUnit intermodalLoadingUnit) {
        return new IntermodalLoadingUnit(mapToGoodsList(intermodalLoadingUnit.getGoods()));
    }

    private static List<Good> mapToGoodsList(List<Goods> goods) {
        return goods.stream().map(VehicleFactory::mapToGood).toList();
    }

    private static Good mapToGood(Goods goods) {
        return new Good(!goods.getDangerousGoods().isEmpty());
    }

    private static BrakeDesign mapToBrakeDesign(Integer brakeDesign) {
        if (brakeDesign == null) {
            return null;
        }
        return BrakeDesign.valueOfKey(brakeDesign);
    }

    private static TractionMode mapToTractionMode(VehicleEffectiveTractionData vehicleEffectiveTractionData) {
        if (vehicleEffectiveTractionData == null || vehicleEffectiveTractionData.getTractionMode() == null) {
            return null;
        }
        return TractionMode.valueOfKey(vehicleEffectiveTractionData.getTractionMode());
    }

    private static EuropeanVehicleNumber mapToEuropeanVehicleNumber(ch.sbb.zis.trainformation.api.model.EuropeanVehicleNumber europeanVehicleNumber) {
        if (europeanVehicleNumber == null) {
            return null;
        }
        return new EuropeanVehicleNumber(europeanVehicleNumber.getCountryCodeUic(), europeanVehicleNumber.getVehicleNumber());
    }
}
