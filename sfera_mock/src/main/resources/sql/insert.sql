insert into driver_advisory_system.train_formation_run (id, inspection_date_time,
                                                        operational_train_number, operational_day,
                                                        company, taf_tap_location_reference_start,
                                                        taf_tap_location_reference_end,
                                                        train_category_code,
                                                        braked_weight_percentage,
                                                        traction_max_speed_in_kmh,
                                                        hauled_load_max_speed_in_kmh,
                                                        formation_max_speed_in_kmh,
                                                        traction_length_in_cm,
                                                        hauled_load_length_in_cm,
                                                        formation_length_in_cm,
                                                        traction_weight_in_t,
                                                        hauled_load_weight_in_t,
                                                        formation_weight_in_t,
                                                        traction_braked_weight_in_t,
                                                        hauled_load_braked_weight_in_t,
                                                        formation_braked_weight_in_t,
                                                        traction_holding_force_in_hecto_newton,
                                                        hauled_load_holding_force_in_hecto_newton,
                                                        formation_holding_force_in_hecto_newton,
                                                        brake_position_g_for_leading_traction,
                                                        brake_position_g_for_brake_unit_1_to_5,
                                                        brake_position_g_for_load_hauled, sim_train,
                                                        additional_tractions, car_carrier_vehicle,
                                                        dangerous_goods, vehicles_count,
                                                        vehicles_with_brake_design_ll_and_k_count,
                                                        vehicles_with_brake_design_d_count,
                                                        vehicles_with_disabled_brakes_count,
                                                        european_vehicle_number_first,
                                                        european_vehicle_number_last,
                                                        axle_load_max_in_kg, route_class,
                                                        gradient_uphill_max_in_permille,
                                                        gradient_downhill_max_in_permille,
                                                        slope_max_for_holding_force_min_in_permille,
                                                        train_path_id)
values (nextval('train_formation_run_id_seq'),
        now(),
        ?,
        ?,
        ?,
        'CH00001', --Graftal
        'CH00003', --Twinn
        'A', -- train_category_code
        95, -- braked_weight_percentage
        140, -- traction_max_speed_in_kmh
        120, -- hauled_load_max_speed_in_kmh
        120, -- formation_max_speed_in_kmh
        1900, -- traction_length_in_cm
        26400, -- hauled_load_length_in_cm
        28300, -- formation_length_in_cm
        120, -- traction_weight_in_t
        484, -- hauled_load_weight_in_t
        604, -- formation_weight_in_t
        150, -- traction_braked_weight_in_t
        436, -- hauled_load_braked_weight_in_t
        586, -- formation_braked_weight_in_t
        48, -- traction_holding_force_in_hecto_newton
        297, -- hauled_load_holding_force_in_hecto_newton
        345, -- formation_holding_force_in_hecto_newton
        false, -- brake_position_g_for_leading_traction
        false, -- brake_position_g_for_brake_unit_1_to_5
        false, -- brake_position_g_for_load_hauled
        false, -- sim_train
        null, -- additional_tractions
        false, -- car_carrier_vehicle
        false, -- dangerous_goods
        12, -- vehicles_count
        12, -- vehicles_with_brake_design_ll_and_k_count
        0, -- vehicles_with_brake_design_d_count
        0, -- vehicles_with_disabled_brakes_count
        378045644663, -- european_vehicle_number_first
        318545521086, -- european_vehicle_number_last
        19993, -- axle_load_max_in_kg
        'C2', -- route_class
        39, -- gradient_uphill_max_in_permille
        40, -- gradient_downhill_max_in_permille
        15, -- slope_max_for_holding_force_min_in_permille
        'ux_test'),
       (nextval('train_formation_run_id_seq'),
        now(),
        ?,
        ?,
        ?,
        'CH00003', --Twinn
        'CH00006', --Baumen
        'A', -- train_category_code
        105, -- braked_weight_percentage
        140, -- traction_max_speed_in_kmh
        100, -- hauled_load_max_speed_in_kmh
        100, -- formation_max_speed_in_kmh
        1900, -- traction_length_in_cm
        33400, -- hauled_load_length_in_cm
        35300, -- formation_length_in_cm
        120, -- traction_weight_in_t
        599, -- hauled_load_weight_in_t
        719, -- formation_weight_in_t
        150, -- traction_braked_weight_in_t
        616, -- hauled_load_braked_weight_in_t
        766, -- formation_braked_weight_in_t
        48, -- traction_holding_force_in_hecto_newton
        435, -- hauled_load_holding_force_in_hecto_newton
        483, -- formation_holding_force_in_hecto_newton
        false, -- brake_position_g_for_leading_traction
        false, -- brake_position_g_for_brake_unit_1_to_5
        false, -- brake_position_g_for_load_hauled
        false, -- sim_train
        null, -- additional_tractions
        false, -- car_carrier_vehicle
        true, -- dangerous_goods
        16, -- vehicles_count
        16, -- vehicles_with_brake_design_ll_and_k_count
        0, -- vehicles_with_brake_design_d_count
        0, -- vehicles_with_disabled_brakes_count
        378045644663, -- european_vehicle_number_first
        378079335360, -- european_vehicle_number_last
        19993, -- axle_load_max_in_kg
        'C2', -- route_class
        39, -- gradient_uphill_max_in_permille
        40, -- gradient_downhill_max_in_permille
        15, -- slope_max_for_holding_force_min_in_permille
        'ux_test'),
       (nextval('train_formation_run_id_seq'),
        now(),
        ?,
        ?,
        ?,
        'CH00006', --Twinn
        'CH00011', --Baumen
        'A', -- train_category_code
        95, -- braked_weight_percentage
        120, -- traction_max_speed_in_kmh
        120, -- hauled_load_max_speed_in_kmh
        120, -- formation_max_speed_in_kmh
        1900, -- traction_length_in_cm
        28100, -- hauled_load_length_in_cm
        30000, -- formation_length_in_cm
        120, -- traction_weight_in_t
        506, -- hauled_load_weight_in_t
        626, -- formation_weight_in_t
        150, -- traction_braked_weight_in_t
        458, -- hauled_load_braked_weight_in_t
        608, -- formation_braked_weight_in_t
        48, -- traction_holding_force_in_hecto_newton
        321, -- hauled_load_holding_force_in_hecto_newton
        369, -- formation_holding_force_in_hecto_newton
        false, -- brake_position_g_for_leading_traction
        false, -- brake_position_g_for_brake_unit_1_to_5
        false, -- brake_position_g_for_load_hauled
        false, -- sim_train
        null, -- additional_tractions
        true, -- car_carrier_vehicle
        true, -- dangerous_goods
        13, -- vehicles_count
        13, -- vehicles_with_brake_design_ll_and_k_count
        0, -- vehicles_with_brake_design_d_count
        0, -- vehicles_with_disabled_brakes_count
        378045644663, -- european_vehicle_number_first
        218524611660, -- european_vehicle_number_last
        19993, -- axle_load_max_in_kg
        'C2', -- route_class
        39, -- gradient_uphill_max_in_permille
        40, -- gradient_downhill_max_in_permille
        15, -- slope_max_for_holding_force_min_in_permille
        'ux_test')

