package ch.sbb.backend.formation.infrastructure.trainformation.model;

import ch.sbb.backend.admin.infrastructure.settings.model.CompanyEntity;
import jakarta.persistence.AttributeOverride;
import jakarta.persistence.AttributeOverrides;
import jakarta.persistence.Column;
import jakarta.persistence.Embedded;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.SequenceGenerator;
import java.time.LocalDate;
import java.time.LocalDateTime;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
@Entity(name = "train_formation")
public class TrainFormationEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.SEQUENCE, generator = "train_formation_id_seq")
    @SequenceGenerator(name = "train_formation_id_seq", allocationSize = 1)
    private Integer id;

    /**
     * Zuletzt geändert (wann wurde Brems- und Lastzettel angeliefert, Datum und Zeit)
     */
    private LocalDateTime modifiedDateTime;
    /**
     * Zugnummer
     */
    private String teltsiOperationalTrainNumber;

    //   todo not sure about teltsi
    /**
     * Datum
     */
    private LocalDate teltsiStartDate;

    //   todo not sure about teltsi
    /**
     * RRU (responsible railway undertaker, ehemals SMS-EVU) Da es keine ausführende EVU in ZIS gibt, wird diese EVU auch als "ausführende EVU" interpretiert.
     */
    @ManyToOne
    @JoinColumn(name = "company_id")
    private CompanyEntity company;

    /**
     * Von Betriebspunkt UIC
     */
    @Embedded
    @AttributeOverrides({
        @AttributeOverride(name = "teltsiCountryCodeIso", column = @Column(name = "start_teltsi_country_code_iso")),
        @AttributeOverride(name = "teltsiLocationPrimaryCode", column = @Column(name = "start_teltsi_location_primary_code"))
    })
    private TafTapLocationReference startTafTapLocationReference;

    //   todo not sure about tafTap
    /**
     * Bis Betriebspunkt UIC
     */
    @Embedded
    @AttributeOverrides({
        @AttributeOverride(name = "teltsiCountryCodeIso", column = @Column(name = "end_teltsi_country_code_iso")),
        @AttributeOverride(name = "teltsiLocationPrimaryCode", column = @Column(name = "end_teltsi_location_primary_code"))
    })
    private TafTapLocationReference endTafTapLocationReference;

    //   todo not sure about tafTap
    /**
     * Zugreihe
     */
    private String trainCategoryCode;

    //    todo or trainSeries as NSP
    /**
     * Bremsreihe
     */
    private Integer brakedWeightPercentage;

    //    todo or brakeSeries as NSP
    /**
     * Vmax (Triebfahrzeuge)
     */
    private Integer tractionMaxSpeedInKilometerPerHour;
    /**
     * Vmax (Anhängelast)
     */
    private Integer hauledLoadMaxSpeedInKilometerPerHour;
    /**
     * Vmax (Gesamtzug)
     */
    private Integer formationMaxSpeedInKilometerPerHour;
    /**
     * Länge (Triebfahrzeuge)
     */
    private Integer tractionLengthInCentimeter;
    /**
     * Länge (Anhängelast)
     */
    private Integer hauledLoadLengthInCentimeter;
    /**
     * Länge (Gesamtzug)
     */
    private Integer totalLengthInCentimeter;
    /**
     * Gewicht (Triebfahrzeuge)
     */
    private Integer tractionGrossWeightInTonne;
    /**
     * Gewicht (Anhängelast)
     */
    private Integer hauledLoadInTonne;
    /**
     * Gewicht (Gesamtzug)
     */
    private Integer totalWeightInTonne;

    /**
     * Bremsgewicht (Triebfahrzeuge)
     */
    private Integer tractionBrakedWeightInTonne;
    /**
     * Bremsgewicht (Anhängelast)
     */
    private Integer hauledLoadBrakedWeightInTonne;
    /**
     * Bremsgewicht (Gesamtzug)
     */
    private Integer totalBrakedWeightInTonne;

    /**
     * Festhaltekraft (Triebfahrzeuge)
     */
    private Integer tractionHoldingForceInHectonewton;
    /**
     * Festhaltekraft (Anhängelast)
     */
    private Integer hauledLoadHoldingForceInHectonewton;
    /**
     * Festhaltekraft (Gesamtzug)
     */
    private Integer totalHoldingForceInHectonewton;
    /**
     * Triebfahrzeug Stellung G
     */
    private Boolean brakePositionGForLeadingTraction;
    /**
     * G-Bremse Anhängelast teilw.
     */
    private Boolean brakePositionGForBrakeUnit1to5;
    /**
     * Ganze Anhängelast Stellung G
     */
    private Boolean brakePositionGForLoadHauled;
    /**
     * SIM Zug
     */
    private Boolean isSimZug;
    /**
     * Lok (Serie)
     */
    private TractionMode tractionMode;
    /**
     * Bel. Autodoppelst. Wg.
     */
    private Boolean carCarrierWagon;
    /**
     * Gefährliche Güter
     */
    private Boolean hasDangerousGoods;
    /**
     * Wagen Total
     */
    private Integer totalNumberOfWagons;
    /**
     * Anzahl Wagen mit LL und K
     */
    private Integer numberOfWagonsWithBrakeDesignLlAndK;
    /**
     * Anzahl Wagen mit D
     */
    private Integer numberOfWagonsWithD;
    /**
     * Ausgeschaltete Bremsen
     */
    private Integer numberOfWagonsWithDisabledBrakes;
    /**
     * Erster Wagen EVN
     */
    private String firstWagonVehicleNumber;
    /**
     * Letzter Wagen EVN
     */
    private String lastWagonVehicleNumber;
    /**
     * Max. Achslast
     */
    private Integer maxAxleLoadInKilogrammes;
    /**
     * Streckenklasse Anhängelast
     */
    private String routeClass;
    /**
     * Teilbremsverhältnis (Spitze)
     */
    private Integer maxUphillGradientInPermille;
    /**
     * Teilbremsverhältnis (Schluss)
     */
    private Integer maxDownhillGradientInPermille;
    /**
     * Mindestfesthaltekraft
     */
    private String maximumSlopeForMinimumHoldingForceInPermille;

}