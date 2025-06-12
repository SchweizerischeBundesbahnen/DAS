CREATE TABLE IF NOT EXISTS train_formation_run
(
    id                                          INTEGER NOT NULL,
    modified_date_time                          TIMESTAMP,
    operational_train_number                    TEXT,
    start_date                                  DATE,
    company                                     TEXT,
    taf_tap_location_reference_start            TEXT,
    taf_tap_location_reference_end              TEXT,
    train_category_code                         TEXT,
    braked_weight_percentage                    INTEGER,
    traction_max_speed_in_kmh                   INTEGER,
    hauled_load_max_speed_in_kmh                INTEGER,
    formation_max_speed_in_kmh                  INTEGER,
    traction_length_in_cm                       INTEGER,
    hauled_load_length_in_cm                    INTEGER,
    formation_length_in_cm                      INTEGER,
    traction_gross_weight_in_t                  INTEGER,
    hauled_load_weight_in_t                     INTEGER,
    formation_weight_in_t                       INTEGER,
    traction_braked_weight_in_t                 INTEGER,
    hauled_load_braked_weight_in_t              INTEGER,
    formation_braked_weight_in_t                INTEGER,
    traction_holding_force_in_hecto_newton      INTEGER,
    hauled_load_holding_force_in_hecto_newton   INTEGER,
    formation_holding_force_in_hecto_newton     INTEGER,
    brake_position_g_for_leading_traction       BOOLEAN,
    brake_position_g_for_brake_unit_1_to_5      BOOLEAN,
    brake_position_g_for_load_hauled            BOOLEAN,
    sim_train                                   BOOLEAN,
    traction_mode                               TEXT,
    car_carrier_vehicle                         BOOLEAN,
    dangerous_goods                             BOOLEAN,
    vehicles_count                              INTEGER,
    vehicles_with_brake_design_ll_and_k_count   INTEGER,
    vehicles_with_brake_design_d_count          INTEGER,
    vehicles_with_disabled_brakes_count         INTEGER,
    european_vehicle_number_first               TEXT,
    european_vehicle_number_last                TEXT,
    axle_load_max_in_kg                         INTEGER,
    route_class                                 TEXT,
    gradient_uphill_max_in_permille             INTEGER,
    gradient_downhill_max_in_permille           INTEGER,
    slope_max_for_holding_force_min_in_permille TEXT
);

ALTER TABLE IF EXISTS train_formation_run
    ADD CONSTRAINT train_formation_run_id_pk PRIMARY KEY (id);
ALTER TABLE IF EXISTS train_formation_run
    ADD CONSTRAINT train_formation_run_company_fk FOREIGN KEY (company) REFERENCES company (code_rics);
ALTER TABLE IF EXISTS train_formation_run
    ADD CONSTRAINT train_formation_run_unique UNIQUE (modified_date_time,
                                                      operational_train_number,
                                                      start_date, company,
                                                      taf_tap_location_reference_start,
                                                      taf_tap_location_reference_end);

CREATE SEQUENCE train_formation_run_id_seq START WITH 1 INCREMENT BY 1;
