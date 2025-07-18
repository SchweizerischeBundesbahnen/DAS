package ch.sbb.backend.formation.domain.model;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.junit.jupiter.api.Assertions.assertNull;
import static org.junit.jupiter.api.Assertions.assertTrue;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.when;

import java.util.ArrayList;
import java.util.List;
import org.junit.jupiter.api.Test;

class VehicleUnitTest {

    @Test
    void hasDisabledBrake_true() {
        BrakeStatus disabledBrakestatus = mock(BrakeStatus.class);
        when(disabledBrakestatus.isDisabled()).thenReturn(true);

        BrakeStatus nonDisabledBrakestatus = mock(BrakeStatus.class);
        when(nonDisabledBrakestatus.isDisabled()).thenReturn(false);

        List<VehicleUnit> vehicleUnits = new ArrayList<>();

        vehicleUnits.add(new VehicleUnit(null, disabledBrakestatus, null, null, null, null));
        vehicleUnits.add(new VehicleUnit(null, nonDisabledBrakestatus, null, null, null, null));

        boolean result = VehicleUnit.hasDisabledBrake(vehicleUnits);

        assertTrue(result);
    }

    @Test
    void hasDisabledBrake_false() {
        BrakeStatus nonDisabledBrakestatus = mock(BrakeStatus.class);
        when(nonDisabledBrakestatus.isDisabled()).thenReturn(false);

        List<VehicleUnit> vehicleUnits = new ArrayList<>();

        vehicleUnits.add(new VehicleUnit(null, nonDisabledBrakestatus, null, null, null, null));
        vehicleUnits.add(new VehicleUnit(null, nonDisabledBrakestatus, null, null, null, null));

        boolean result = VehicleUnit.hasDisabledBrake(vehicleUnits);

        assertFalse(result);
    }

    @Test
    void hasDangerousGoods_true() {
        Load dangerousGoodsLoad = mock(Load.class);
        when(dangerousGoodsLoad.hasDangerousGoods()).thenReturn(true);

        Load nonDangerousGoodsLoad = mock(Load.class);
        when(nonDangerousGoodsLoad.hasDangerousGoods()).thenReturn(false);

        List<VehicleUnit> vehicleUnits = new ArrayList<>();

        vehicleUnits.add(new VehicleUnit(null, null, null, null, null, dangerousGoodsLoad));
        vehicleUnits.add(new VehicleUnit(null, null, null, null, null, nonDangerousGoodsLoad));

        boolean result = VehicleUnit.hasDangerousGoods(vehicleUnits);

        assertTrue(result);
    }

    @Test
    void hasDangerousGoods_false() {
        Load nonDangerousGoodsLoad = mock(Load.class);
        when(nonDangerousGoodsLoad.hasDangerousGoods()).thenReturn(false);

        List<VehicleUnit> vehicleUnits = new ArrayList<>();

        vehicleUnits.add(new VehicleUnit(null, null, null, null, null, nonDangerousGoodsLoad));
        vehicleUnits.add(new VehicleUnit(null, null, null, null, null, nonDangerousGoodsLoad));

        boolean result = VehicleUnit.hasDangerousGoods(vehicleUnits);

        assertFalse(result);
    }

    @Test
    void hasBrakeDesign_true() {
        List<VehicleUnit> vehicleUnits = new ArrayList<>();
        vehicleUnits.add(new VehicleUnit(BrakeDesign.EINLOESIGE_BREMSE, null, null, null, null, null));
        vehicleUnits.add(new VehicleUnit(BrakeDesign.SCHEIBENBREMSEN, null, null, null, null, null));

        boolean result = VehicleUnit.hasBrakeDesign(vehicleUnits, BrakeDesign.EINLOESIGE_BREMSE);

        assertTrue(result);
    }

    @Test
    void hasBrakeDesign_false() {
        List<VehicleUnit> vehicleUnits = new ArrayList<>();
        vehicleUnits.add(new VehicleUnit(BrakeDesign.L_KUNSTSTOFF_LEISE, null, null, null, null, null));
        vehicleUnits.add(new VehicleUnit(BrakeDesign.NICHT_KODIERT, null, null, null, null, null));

        boolean result = VehicleUnit.hasBrakeDesign(vehicleUnits, BrakeDesign.SCHEIBENBREMSEN);

        assertFalse(result);
    }

    @Test
    void hasBrakeDesign_multipleBrakeDesign() {
        List<VehicleUnit> vehicleUnits = new ArrayList<>();
        vehicleUnits.add(new VehicleUnit(BrakeDesign.L_KUNSTSTOFF_LEISE, null, null, null, null, null));
        vehicleUnits.add(new VehicleUnit(BrakeDesign.NICHT_KODIERT, null, null, null, null, null));

        assertTrue(VehicleUnit.hasBrakeDesign(vehicleUnits, BrakeDesign.SCHEIBENBREMSEN, BrakeDesign.NICHT_KODIERT));
        assertTrue(VehicleUnit.hasBrakeDesign(vehicleUnits, BrakeDesign.NICHT_KODIERT, BrakeDesign.L_KUNSTSTOFF_LEISE));
        assertFalse(VehicleUnit.hasBrakeDesign(vehicleUnits, BrakeDesign.LL_KUNSTSTOFF_LEISE_LEISE, BrakeDesign.NORMALE_BREMSAUSRUESTUNG_KEINE_MERKMALE));
    }

    @Test
    void holdingForce_null() {
        VehicleUnit vehicleUnit = new VehicleUnit(null, null, null, null, null, null);

        Integer result = vehicleUnit.holdingForce(true);

        assertNull(result);
    }

    @Test
    void holdingForce_whenTraction() {
        VehicleUnit vehicleUnit = new VehicleUnit(null, null, 13, 22, 10, null);

        Integer result = vehicleUnit.holdingForce(true);

        assertEquals(13, result);
    }

    @Test
    void holdingForce_whenTractionNoHoldingForce() {
        VehicleUnit vehicleUnit = new VehicleUnit(null, null, null, 22, 10, null);

        Integer result = vehicleUnit.holdingForce(true);

        assertEquals(100, result);
    }

    @Test
    void holdingForce_whenNotTraction() {
        VehicleUnit vehicleUnit = new VehicleUnit(null, null, 34, 12, 7, null);

        Integer result = vehicleUnit.holdingForce(false);

        assertEquals(12, result);
    }

    @Test
    void holdingForce_whenNotTractionNoHoldingForce() {
        VehicleUnit vehicleUnit = new VehicleUnit(null, null, 34, null, 9, null);

        Integer result = vehicleUnit.holdingForce(false);

        assertEquals(90, result);
    }
}