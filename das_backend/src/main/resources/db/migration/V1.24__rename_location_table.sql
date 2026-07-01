ALTER TABLE IF EXISTS location
    RENAME TO taf_tap_location;
ALTER TABLE IF EXISTS taf_tap_location
    RENAME CONSTRAINT location_id_pk TO taf_tap_location_id_pk;
ALTER TABLE IF EXISTS taf_tap_location
    RENAME CONSTRAINT location_unique TO taf_tap_location_unique;
ALTER SEQUENCE IF EXISTS location_id_seq RENAME TO taf_tap_location_id_seq;
