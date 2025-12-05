ALTER TABLE IF EXISTS event_publication
    ADD COLUMN IF NOT EXISTS status TEXT;

ALTER TABLE IF EXISTS event_publication
    ADD COLUMN IF NOT EXISTS completion_attempts INT;

ALTER TABLE IF EXISTS event_publication
    ADD COLUMN IF NOT EXISTS last_resubmission_date TIMESTAMP WITH TIME ZONE;
