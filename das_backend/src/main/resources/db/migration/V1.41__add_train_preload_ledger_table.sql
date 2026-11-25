CREATE TABLE IF NOT EXISTS train_preload_ledger
(
    id                      INTEGER                  NOT NULL,
    train_identification_id INTEGER                  NOT NULL,
    attempts                INTEGER                  NOT NULL,
    last_attempt_at         TIMESTAMP WITH TIME ZONE NOT NULL,
    last_outcome            TEXT                     NOT NULL,
    last_g2b_code           TEXT,
    preloaded_at            TIMESTAMP WITH TIME ZONE
);

ALTER TABLE IF EXISTS train_preload_ledger
    ADD CONSTRAINT train_preload_ledger_id_pk PRIMARY KEY (id);

ALTER TABLE IF EXISTS train_preload_ledger
    ADD CONSTRAINT train_preload_ledger_train_identification_id_unique UNIQUE (train_identification_id);

-- First ON DELETE CASCADE in the schema: a ledger row is the preload history of exactly one train identification
-- and is meaningless without it, so the train identification clean-up removes it without knowing about the preloader.
ALTER TABLE IF EXISTS train_preload_ledger
    ADD CONSTRAINT train_preload_ledger_train_identification_id_fk FOREIGN KEY (train_identification_id)
        REFERENCES train_identification (id) ON DELETE CASCADE;

CREATE SEQUENCE IF NOT EXISTS train_preload_ledger_id_seq START WITH 1 INCREMENT BY 1;

-- The preload state moves to train_preload_ledger. No backfill: trains preloaded before this migration are preloaded once more.
-- The departure window query is covered by train_identification_start_date_time_idx (V1.12).
DROP INDEX IF EXISTS train_identification_preloaded_at_null_idx;

ALTER TABLE IF EXISTS train_identification
    DROP COLUMN IF EXISTS preloaded_at;
