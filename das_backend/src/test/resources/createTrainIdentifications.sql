DELETE
FROM train_identification;

INSERT INTO train_identification (id, train_path_id, period, operational_train_number,
                                  start_date_time, companies, operational_day)
VALUES (nextval('train_identification_id_seq'), '728-1', 2025, '728', '2025-06-15 08:30:00+02',
        'MOCK_A,MOCK_B', '2025-06-15'),
       (nextval('train_identification_id_seq'), '728-2', 2025, '728', '2025-06-16 08:30:00+02',
        'MOCK_C', '2025-06-16'),
       (nextval('train_identification_id_seq'), '999-3', 2025, '999', '2025-06-15 10:00:00+02',
        'MOCK_A', '2025-06-15'),
       (nextval('train_identification_id_seq'), '555-1', 2025, '555', '2025-06-15 12:00:00+02',
        'MOCK_A,NOT_IN_DB', '2025-06-15');
