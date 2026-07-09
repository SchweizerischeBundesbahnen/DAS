ALTER TABLE IF EXISTS ru_feature
    ADD COLUMN IF NOT EXISTS company_code TEXT;

UPDATE ru_feature
SET company_code = (SELECT code FROM company WHERE company.id = ru_feature.company_id)
WHERE company_id IS NOT NULL;

ALTER TABLE IF EXISTS ru_feature
    DROP CONSTRAINT IF EXISTS ru_feature_company_id_fk;

ALTER TABLE IF EXISTS ru_feature
    DROP CONSTRAINT IF EXISTS ru_feature_company_id_name_unique;

ALTER TABLE IF EXISTS ru_feature
    DROP COLUMN IF EXISTS company_id;

ALTER TABLE IF EXISTS ru_feature
    ALTER COLUMN company_code SET NOT NULL;

ALTER TABLE IF EXISTS ru_feature
    ADD CONSTRAINT ru_feature_company_code_key_value_unique UNIQUE (company_code, key_value);
