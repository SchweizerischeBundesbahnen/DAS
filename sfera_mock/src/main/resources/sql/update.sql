UPDATE driver_advisory_system.train_formation_run
SET dangerous_goods = true
WHERE operational_train_number = ?
  AND operational_day = ?
  AND company = ?
  AND train_path_id = 'ux_test'
  AND taf_tap_location_reference_start = 'CH09991';
