package ch.sbb.backend.formation.infrastructure;

import ch.sbb.backend.formation.domain.model.BrakeDesign;
import ch.sbb.backend.formation.domain.model.BrakeStatus;
import ch.sbb.backend.formation.domain.model.EuropeanVehicleNumber;
import ch.sbb.backend.formation.domain.model.Goods;
import ch.sbb.backend.formation.domain.model.IntermodalLoadingUnit;
import ch.sbb.backend.formation.domain.model.Load;
import ch.sbb.backend.formation.domain.model.TractionMode;
import ch.sbb.backend.formation.domain.model.Vehicle;
import ch.sbb.backend.formation.domain.model.VehicleUnit;
import ch.sbb.backend.formation.domain.model.VehicleUnit.VehicleUnitBuilder;
import ch.sbb.zis.trainformation.api.model.CargoTransport;
import ch.sbb.zis.trainformation.api.model.DangerousGoods;
import ch.sbb.zis.trainformation.api.model.UnitEffectiveOperationalData;
import ch.sbb.zis.trainformation.api.model.UnitTechnicalData;
import ch.sbb.zis.trainformation.api.model.VehicleEffectiveTractionData;
import ch.sbb.zis.trainformation.api.model.VehicleGroup;
import ch.sbb.zis.trainformation.api.model.VehicleType;
import java.util.Collections;
import java.util.List;
import java.util.stream.Stream;
import lombok.AccessLevel;
import lombok.NoArgsConstructor;
import org.springframework.util.CollectionUtils;

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
        return new Vehicle(toTractionMode(vehicle.getVehicleEffectiveTractionData()), vehicle.getVehicleCategory(), toVehicleUnits(vehicle.getVehicleUnits()),
            toEuropeanVehicleNumber(vehicle.getEuropeanVehicleNumber()));
    }

    private static List<VehicleUnit> toVehicleUnits(List<ch.sbb.zis.trainformation.api.model.VehicleUnit> vehicleUnits) {
        return vehicleUnits.stream().map(VehicleFactory::toVehicleUnit).toList();
    }

    private static VehicleUnit toVehicleUnit(ch.sbb.zis.trainformation.api.model.VehicleUnit vehicleUnit) {
        VehicleUnitBuilder builder = VehicleUnit.builder();
        applyUnitTechnichalData(builder, vehicleUnit.getUnitTechnicalData());
        applyUnitEffectiveOperationalData(builder, vehicleUnit.getUnitEffectiveOperationalData());
        applyCargoTransport(builder, vehicleUnit.getCargoTransport());
        applyVehicleType(builder, vehicleUnit.getVehicleType());
        return builder.build();
    }

    private static void applyVehicleType(VehicleUnitBuilder builder, VehicleType vehicleType) {
        if (vehicleType == null) {
            return;
        }
        builder.vehicleTypeIdentifier(vehicleType.getVehicleTypeIdentifier());
    }

    private static void applyCargoTransport(VehicleUnitBuilder builder, CargoTransport cargoTransport) {
        if (cargoTransport == null || cargoTransport.getLoad() == null) {
            return;
        }
        List<Goods> goodsList = toGoodsList(cargoTransport.getLoad().getGoods());
        List<IntermodalLoadingUnit> intermodalLoadingUnits = toIntermodalLoadingUnits(cargoTransport.getLoad().getIntermodalLoadingUnits());
        builder.load(new Load(goodsList, intermodalLoadingUnits));
    }

    private static void applyUnitEffectiveOperationalData(VehicleUnitBuilder builder, UnitEffectiveOperationalData unitEffectiveOperationalData) {
        if (unitEffectiveOperationalData == null) {
            return;
        }
        builder
            .brakeStatus(new BrakeStatus(unitEffectiveOperationalData.getBrakeStatus()))
            .effectiveOperationalHoldingForceInHectoNewton(unitEffectiveOperationalData.getHoldingForceInHectonewton());
    }

    private static void applyUnitTechnichalData(VehicleUnitBuilder builder, UnitTechnicalData unitTechnicalData) {
        if (unitTechnicalData == null) {
            return;
        }
        builder
            .brakeDesign(toBrakeDesign(unitTechnicalData.getBrakeDesign()))
            .technicalHoldingForceInHectoNewton(unitTechnicalData.getHoldingForceInHectonewton())
            .handBrakeWeightInT(unitTechnicalData.getHandBrakeWeightInTonne());
    }

    private static List<IntermodalLoadingUnit> toIntermodalLoadingUnits(List<ch.sbb.zis.trainformation.api.model.IntermodalLoadingUnit> intermodalLoadingUnits) {
        if (intermodalLoadingUnits == null) {
            return Collections.emptyList();
        }
        return intermodalLoadingUnits.stream().map(VehicleFactory::toIntermodalLoadingUnit).toList();
    }

    private static IntermodalLoadingUnit toIntermodalLoadingUnit(ch.sbb.zis.trainformation.api.model.IntermodalLoadingUnit intermodalLoadingUnit) {
        return new IntermodalLoadingUnit(isDangerous(intermodalLoadingUnit.getDangerousGoods()), toGoodsList(intermodalLoadingUnit.getGoods()));
    }

    private static List<Goods> toGoodsList(List<ch.sbb.zis.trainformation.api.model.Goods> goods) {
        if (goods == null) {
            return Collections.emptyList();
        }
        return goods.stream().map(VehicleFactory::toGoods).toList();
    }

    private static Goods toGoods(ch.sbb.zis.trainformation.api.model.Goods goods) {
        return new Goods(isDangerous(goods.getDangerousGoods()));
    }

    private static boolean isDangerous(List<DangerousGoods> dangerousGoods) {
        return !CollectionUtils.isEmpty(dangerousGoods);
    }

    private static BrakeDesign toBrakeDesign(Integer brakeDesign) {
        if (brakeDesign == null) {
            return null;
        }
        return BrakeDesign.valueOfKey(brakeDesign);
    }

    private static TractionMode toTractionMode(VehicleEffectiveTractionData vehicleEffectiveTractionData) {
        if (vehicleEffectiveTractionData == null || vehicleEffectiveTractionData.getTractionMode() == null) {
            return null;
        }
        return TractionMode.valueOfKey(vehicleEffectiveTractionData.getTractionMode());
    }

    private static EuropeanVehicleNumber toEuropeanVehicleNumber(ch.sbb.zis.trainformation.api.model.EuropeanVehicleNumber europeanVehicleNumber) {
        if (europeanVehicleNumber == null) {
            return null;
        }
        return new EuropeanVehicleNumber(europeanVehicleNumber.getTypeCode(), europeanVehicleNumber.getCountryCodeUic(), europeanVehicleNumber.getVehicleNumber(),
            europeanVehicleNumber.getCheckDigit());
    }
}
