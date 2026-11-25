ALTER TABLE IF EXISTS preloaded_segment_profile
    ADD COLUMN zip_key     TEXT,
    ADD COLUMN pending_xml TEXT;

UPDATE preloaded_segment_profile
SET zip_key = 'Segments_' || file_id || '.zip';

ALTER TABLE IF EXISTS preloaded_segment_profile
    DROP COLUMN file_id;

CREATE INDEX IF NOT EXISTS preloaded_segment_profile_zip_key_idx
    ON preloaded_segment_profile (zip_key);
