ALTER TABLE IF EXISTS ru_indication_template
    ADD COLUMN IF NOT EXISTS tenant TEXT NOT NULL DEFAULT 'unknown-tenant';

CREATE INDEX IF NOT EXISTS ru_indication_template_tenant_idx
    ON ru_indication_template (tenant);

ALTER TABLE IF EXISTS ru_indication_template
    DROP COLUMN IF EXISTS companies;
