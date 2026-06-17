ALTER TABLE IF EXISTS ru_indication_template
    ADD COLUMN IF NOT EXISTS companies TEXT NOT NULL default '1285'
