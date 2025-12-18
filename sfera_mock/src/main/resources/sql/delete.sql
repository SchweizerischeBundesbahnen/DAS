DELETE
FROM driver_advisory_system.train_formation_run
WHERE operational_train_number = ?
  AND operational_day = ?
  AND company = ?
  AND train_path_id = 'ux_test';
