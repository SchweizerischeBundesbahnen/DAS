DROP INDEX IF EXISTS train_identification_idx;
DROP TABLE IF EXISTS train_identification;

CREATE TABLE IF NOT EXISTS train
(
    path_id            VARCHAR(50) NOT NULL,
    period             INT         NOT NULL,
    train_number       VARCHAR(20) NOT NULL,
    infrastructure_net VARCHAR(50) NOT NULL,
    ordering_ru        VARCHAR(50) NOT NULL,
    CONSTRAINT train_pk PRIMARY KEY (path_id, period)
);
CREATE INDEX IF NOT EXISTS train_by_train_number_idx ON train (train_number);


CREATE TABLE IF NOT EXISTS train_run_dates
(
    path_id          VARCHAR(50) NOT NULL,
    period           INT         NOT NULL,
    operational_date DATE        NOT NULL,
    start_date       DATE        NOT NULL,
    train_run_id     INT         NOT NULL,
    CONSTRAINT train_run_dates_pk PRIMARY KEY (path_id, period, operational_date)
);
CREATE INDEX IF NOT EXISTS train_run_dates_idx ON train_run_dates (path_id, period, operational_date, start_date);


CREATE TABLE IF NOT EXISTS train_run
(
    path_id          VARCHAR(50)  NOT NULL,
    period           INT          NOT NULL,
    train_run_id     INT          NOT NULL,
    train_run_points TEXT         NOT NULL,
    sms_rus          VARCHAR(200) NOT NULL,
    CONSTRAINT train_run_pk PRIMARY KEY (path_id, period, train_run_id)
);


CREATE VIEW train_view AS
SELECT t.path_id,
       t.period,
       t.infrastructure_net,
       t.ordering_ru,
       t.train_number,
       tr.train_run_id,
       tr.sms_rus,
       tr.train_run_points,
       trd.operational_date,
       trd.start_date
FROM train t
         JOIN train_run_dates trd ON t.period = trd.period AND t.path_id = trd.path_id
         JOIN train_run tr ON t.period = tr.period AND t.path_id = tr.path_id AND
                              tr.train_run_id = trd.train_run_id;
