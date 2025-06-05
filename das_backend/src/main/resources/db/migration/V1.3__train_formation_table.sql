CREATE TABLE IF NOT EXISTS train_formation
(
    id                                                  INTEGER   NOT NULL,

--  unique for the formation train run
    modified_date_time                                  TIMESTAMP NOT NULL,
    company_id                                          INTEGER   NOT NULL,
    teltsi_start_date                                   DATE      NOT NULL,
    teltsi_operational_train_number                     TEXT      NOT NULL,

    start_teltsi_country_code_iso                       TEXT      NOT NULL,
    start_teltsi_location_primary_code                  INTEGER   NOT NULL,
    end_teltsi_country_code_iso                         TEXT      NOT NULL,
    end_teltsi_location_primary_code                    INTEGER   NOT NULL,
--

    brake_positiongfor_brake_unit1to5                   BOOLEAN,
    brake_positiongfor_leading_traction                 BOOLEAN,
    brake_positiongfor_load_hauled                      BOOLEAN,
    braked_weight_percentage                            INTEGER,
    car_carrier_wagon                                   BOOLEAN,
    formation_max_speed_in_kilometer_per_hour           INTEGER,
    has_dangerous_goods                                 BOOLEAN,
    hauled_load_braked_weight_in_tonne                  INTEGER,
    hauled_load_holding_force_in_hectonewton            INTEGER,
    hauled_load_in_tonne                                INTEGER,
    hauled_load_length_in_centimeter                    INTEGER,
    hauled_load_max_speed_in_kilometer_per_hour         INTEGER,
    is_sim_zug                                          BOOLEAN,
    max_axle_load_in_kilogrammes                        INTEGER,
    max_downhill_gradient_in_permille                   INTEGER,
    max_uphill_gradient_in_permille                     INTEGER,
    number_of_wagons_with_brake_design_ll_andk          INTEGER,
    number_of_wagons_with_disabled_brakes               INTEGER,
    number_of_wagons_withd                              INTEGER,
    total_braked_weight_in_tonne                        INTEGER,
    total_holding_force_in_hectonewton                  INTEGER,
    total_length_in_centimeter                          INTEGER,
    total_number_of_wagons                              INTEGER,
    total_weight_in_tonne                               INTEGER,
    traction_braked_weight_in_tonne                     INTEGER,
    traction_gross_weight_in_tonne                      INTEGER,
    traction_holding_force_in_hectonewton               INTEGER,
    traction_length_in_centimeter                       INTEGER,
    traction_max_speed_in_kilometer_per_hour            INTEGER,
    traction_mode                                       TEXT,
    first_wagon_vehicle_number                          TEXT,
    last_wagon_vehicle_number                           TEXT,
    maximum_slope_for_minimum_holding_force_in_permille TEXT,
    route_class                                         TEXT,
    train_category_code                                 TEXT
);

ALTER TABLE IF EXISTS train_formation
    ADD CONSTRAINT train_formation_id_pk PRIMARY KEY (id);
ALTER TABLE IF EXISTS train_formation
    ADD CONSTRAINT train_formation_company_id_fk FOREIGN KEY (company_id) REFERENCES company (id);

CREATE SEQUENCE train_formation_id_seq START WITH 1 INCREMENT BY 1;
