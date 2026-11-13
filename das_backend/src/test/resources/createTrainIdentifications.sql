-- Departures relative to FIXED_NOW (2026-03-10 12:00 Europe/Zurich) in TrainIdentificationControllerTest
DELETE
FROM train_identification;

INSERT INTO train_identification (id, train_path_id, period, operational_train_number,
                                  start_date_time, companies, operational_day)
VALUES (nextval('train_identification_id_seq'), '728-1', 2025, '728', '2026-03-10 13:00:00+01',
        'MOCK_A,MOCK_B', '2026-03-10'),
       (nextval('train_identification_id_seq'), '728-2', 2025, '728', '2026-03-10 18:00:00+01',
        'MOCK_C', '2026-03-10'),
       (nextval('train_identification_id_seq'), '999-3', 2025, '999', '2026-03-10 14:00:00+01',
        'MOCK_A', '2026-03-10'),
       (nextval('train_identification_id_seq'), '555-1', 2025, '555', '2026-03-10 15:00:00+01',
        'MOCK_A,NOT_IN_DB', '2026-03-10');
