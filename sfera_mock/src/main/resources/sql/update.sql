UPDATE driver_advisory_system.train_formation_run
SET traction_max_speed_in_kmh = 140
WHERE operational_train_number = ?
  AND operational_day = ?
  AND company = ?
  AND train_path_id = 'ux_test'
  AND taf_tap_location_reference_start = 'CH00006';
