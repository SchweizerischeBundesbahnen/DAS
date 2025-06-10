package ch.sbb.backend.formation.infrastructure.trainformation.model;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.SequenceGenerator;
import java.time.LocalDate;
import java.time.LocalDateTime;
import lombok.Getter;
import lombok.Setter;

//todo send properties to ZIS with comment pesche

@Getter
@Setter
@Entity(name = "train_formation_run")
public class TrainFormationRunEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.SEQUENCE, generator = "train_formation_run_id_seq")
    @SequenceGenerator(name = "train_formation_run_id_seq", allocationSize = 1)
    private Integer id;

    /**
     * Zuletzt geändert (wann wurde Brems- und Lastzettel angeliefert, Datum und Zeit)
     */
    private LocalDateTime modifiedDateTime;
    /**
     * Zugnummer
     */
    @TelTsi
    private String operationalTrainNumber;

    /**
     * Datum
     */
    @TelTsi
    private LocalDate startDate;

    // todo: could be only company_id/rics

    /**
     * RRU (responsible railway undertaker, ehemals SMS-EVU) Da es keine ausführende EVU in ZIS gibt, wird diese EVU auch als "ausführende EVU" interpretiert.
     * <p>
     * According to RICS code.
     */
    @TelTsi
    // todo: with this constraint the company must exist
    @JoinColumn(name = "company", referencedColumnName = "codeRics")
    private String company;

    /**
     * Von Betriebspunkt UIC
     */
    private String startTafTapLocationReference;

    /**
     * Bis Betriebspunkt UIC
     */
    private String endTafTapLocationReference;

    /**
     * Zugreihe
     */
    private String trainCategoryCode;

    /**
     * Bremsreihe
     */
    private Integer brakedWeightPercentage;

    /**
     * Vmax (Triebfahrzeuge)
     */
    private Integer tractionMaxSpeedInKmh;

    /**
     * Vmax (Anhängelast)
     */
    private Integer hauledLoadMaxSpeedInKmh;

    /**
     * Vmax (Gesamtzug)
     */
    private Integer formationMaxSpeedInKmh;

    /**
     * Länge (Triebfahrzeuge)
     */
    private Integer tractionLengthInCm;

    /**
     * Länge (Anhängelast)
     */
    private Integer hauledLoadLengthInCm;
    /**
     * Länge (Gesamtzug)
     */
    private Integer formationLengthInCm;

    /**
     * Gewicht (Triebfahrzeuge)
     */
    @Column(name = "traction_gross_weight_in_t")
    private Integer tractionGrossWeightInT;

    /**
     * Gewicht (Anhängelast)
     */
    @Column(name = "hauled_load_weight_in_t")
    private Integer hauledLoadWeightInT;

    /**
     * Gewicht (Gesamtzug)
     */
    @Column(name = "formation_weight_in_t")
    private Integer formationWeightInT;

    /**
     * Bremsgewicht (Triebfahrzeuge)
     */
    @Column(name = "traction_braked_weight_in_t")
    private Integer tractionBrakedWeightInT;

    /**
     * Bremsgewicht (Anhängelast)
     */
    @Column(name = "hauled_load_braked_weight_in_t")
    private Integer hauledLoadBrakedWeightInT;

    /**
     * Bremsgewicht (Gesamtzug)
     */
    @Column(name = "formation_braked_weight_in_t")
    private Integer formationBrakedWeightInT;

    /**
     * Festhaltekraft (Triebfahrzeuge)
     */
    private Integer tractionHoldingForceInHectoNewton;

    /**
     * Festhaltekraft (Anhängelast)
     */
    private Integer hauledLoadHoldingForceInHectoNewton;

    /**
     * Festhaltekraft (Gesamtzug)
     */
    private Integer formationHoldingForceInHectoNewton;

    /**
     * Triebfahrzeug Stellung G
     */
    @Column(name = "brake_position_g_for_leading_traction")
    private boolean brakePositionGForLeadingTraction;

    /**
     * G-Bremse Anhängelast teilw.
     */
    @Column(name = "brake_position_g_for_brake_unit_1_to_5")
    private boolean brakePositionGForBrakeUnit1to5;

    /**
     * Ganze Anhängelast Stellung G
     */
    @Column(name = "brake_position_g_for_load_hauled")
    private boolean brakePositionGForLoadHauled;

    /**
     * SIM Zug
     */
    private boolean simTrain;

    /**
     * Lok (Serie)
     */
    @Enumerated(EnumType.STRING)
    private TractionMode tractionMode;

    /**
     * Bel. Autodoppelst. Wg.
     */
    private boolean carCarrierVehicle;

    /**
     * Gefährliche Güter
     */
    private boolean dangerousGoods;

    /**
     * Wagen Total
     */
    private Integer numberOfVehicles;

    /**
     * Anzahl Wagen mit LL und K
     */
    @Column(name = "number_of_vehicles_with_brake_design_ll_and_k")
    private Integer numberOfVehiclesWithBrakeDesignLlAndK;

    /**
     * Anzahl Wagen mit D
     */
    @Column(name = "number_of_vehicles_with_brake_design_d")
    private Integer numberOfVehiclesWithBrakeDesignD;

    /**
     * Ausgeschaltete Bremsen
     */
    private Integer numberOfVehiclesWithDisabledBrakes;

    /**
     * Erster Wagen EVN
     */
    private String europeanVehicleNumberFirst;

    /**
     * Letzter Wagen EVN
     */
    private String europeanVehicleNumberLast;

    /**
     * Max. Achslast
     */
    private Integer axleLoadMaxInKg;

    /**
     * Streckenklasse Anhängelast
     */
    private String routeClass;

    /**
     * Teilbremsverhältnis (Spitze)
     */
    private Integer gradientUphillMaxInPermille;

    /**
     * Teilbremsverhältnis (Schluss)
     */
    private Integer gradientDownhillMaxInPermille;

    /**
     * Mindestfesthaltekraft
     */
    private String slopeMaxForHoldingForceMinInPermille;

}