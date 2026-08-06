UPDATE public.train_formation_run
SET inspection_date_time         = '2025-07-25 13:43:23.120000',
    hauled_load_max_speed_in_kmh = 100
WHERE operational_train_number = '54233'
  AND operational_day = '2025-07-25'
  AND company = '2185'
  AND taf_tap_location_uic_start_code = 85000010
  AND taf_tap_location_uic_end_code = 85000020;
