package ch.sbb.backend.formation.domain.model;

import java.time.OffsetDateTime;
import java.util.Collections;
import java.util.List;
import lombok.Builder;
import lombok.EqualsAndHashCode;
import lombok.Getter;
import lombok.ToString;

/**
 * <a href="https://confluence.sbb.ch/spaces/DASBP/pages/3037422329/Cargo+Formation+ZIS-Formation">Business rules</a>
 */
@Builder
@EqualsAndHashCode
@ToString
public class FormationRun {

    /**
     * Given in case data provider has no known Company yet.
     */
    public static final String INVALID_COMPANY_CODE = "0000";
    public static final int COMPANY_CODE_LENGTH = 4;

    private Boolean inspected;
    @Getter private OffsetDateTime inspectionDateTime;
    @Getter private String company;
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
    /**
     * Always provided by the source system.
     */
    private List<Vehicle> vehicles;

    /**
     * Reduces formation runs to only the inspected ones as well as valid company. By means relevant for train journeys in reality.
     *
     * @param formationRuns All kind of formation runs (includes also non inspected).
     * @return
     */
    static List<FormationRun> filterValid(List<FormationRun> formationRuns) {
        if (formationRuns == null) {
            return Collections.emptyList();
        }
        return formationRuns.stream()
            .filter(formationRun -> formationRun.isInspected() && formationRun.isValidCompany())
            .toList();
    }

    private static Integer sum(Integer a, Integer b) {
        if (a == null && b == null) {
            return null;
        }
        int aValue = a != null ? a : 0;
        int bValue = b != null ? b : 0;
        return aValue + bValue;
    }

    private boolean isInspected() {
        return Boolean.TRUE.equals(inspected);
    }

    private boolean isValidCompany() {
        if (company != null && company.length() == COMPANY_CODE_LENGTH && !INVALID_COMPANY_CODE.equals(company)) {
            return true;
        } else {
            throw new UnexpectedProviderData(
                "Invalid company code: " + company + " for formation run " + tafTapLocationReferenceStart.toLocationCode() + " - " + tafTapLocationReferenceEnd.toLocationCode());
        }
    }

    public Integer getFormationGrossWeightInT() {
        return sum(tractionGrossWeightInT, hauledLoadGrossWeightInT);
    }

    public Integer getFormationBrakedWeightInT() {
        return sum(tractionBrakedWeightInT, hauledLoadBrakedWeightInT);
    }

    public Integer getTractionHoldingForceInHectoNewton() {
        return Vehicle.calculateTractionHoldingForceInHectoNewton(vehicles);
    }

    public Integer getHauledLoadHoldingForceInHectoNewton() {
        return Vehicle.calculateHauledLoadHoldingForceInHectoNewton(vehicles);
    }

    public Integer getFormationHoldingForceInHectoNewton() {
        return Vehicle.calculateHoldingForce(vehicles);
    }

    public List<String> getAdditionalTractions() {
        return Vehicle.getAdditionalTractions(vehicles);
    }

    public boolean hasDangerousGoods() {
        return Vehicle.hasDangerousGoods(vehicles);
    }

    public Integer hauledLoadVehiclesCount() {
        return Vehicle.hauledLoadCount(vehicles);
    }

    public Integer vehiclesWithBrakeDesignCount(BrakeDesign... brakeDesigns) {
        return Vehicle.countBrakeDesigns(vehicles, brakeDesigns);
    }

    public Integer vehiclesWithDisabledBrakeCount() {
        return Vehicle.countDisabledBrakes(vehicles);
    }

    public String getEuropeanVehicleNumberFirst() {
        return Vehicle.getEuropeanVehicleNumberFirst(vehicles);
    }

    public String getEuropeanVehicleNumberLast() {
        return Vehicle.getEuropeanVehicleNumberLast(vehicles);
    }
}

