CREATE TABLE special_holiday
(
    id               INTEGER   NOT NULL,
    name             TEXT      NOT NULL,
    date             DATE      NOT NULL,
    schedule_type    TEXT      NOT NULL,
    companies        TEXT      NOT NULL,
    last_modified_at TIMESTAMP NOT NULL,
    last_modified_by TEXT      NOT NULL
);

ALTER TABLE IF EXISTS special_holiday
    ADD CONSTRAINT special_holiday_id_pk PRIMARY KEY (id);

CREATE SEQUENCE special_holiday_id_seq START WITH 1 INCREMENT BY 1;
