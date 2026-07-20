TRUNCATE TABLE taf_tap_location;

ALTER SEQUENCE taf_tap_location_id_seq RESTART WITH 1;

INSERT INTO taf_tap_location(id, location_reference, primary_location_name, location_abbreviation,
                             valid_from, valid_to)
VALUES (1, 'CH07000', 'Bern', 'BN', '2020-01-01', '9999-12-31'),
       (2, 'CH08000', 'Zurich', 'ZH', '2099-01-01', '9999-12-31'),
       (3, 'IT09000', 'Milano', null, '2021-06-01', '9999-12-31');

