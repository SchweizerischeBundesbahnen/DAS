CREATE TABLE IF NOT EXISTS tenant
(
    id                    INTEGER NOT NULL,
    name                  TEXT    NOT NULL,
    tenant_id             TEXT    NOT NULL,
    is_admin_role_allowed BOOLEAN NOT NULL DEFAULT FALSE
);

ALTER TABLE IF EXISTS tenant
    ADD CONSTRAINT tenant_id_pk PRIMARY KEY (id);
ALTER TABLE IF EXISTS tenant
    ADD CONSTRAINT tenant_tenant_id_unique UNIQUE (tenant_id);

CREATE SEQUENCE IF NOT EXISTS tenant_id_seq START WITH 1 INCREMENT BY 1;

ALTER TABLE IF EXISTS company
    ADD COLUMN IF NOT EXISTS tenant_id INTEGER;

ALTER TABLE IF EXISTS company
    ADD CONSTRAINT company_tenant_id_fk FOREIGN KEY (tenant_id) REFERENCES tenant (id);

ALTER TABLE IF EXISTS company
    RENAME COLUMN code_rics TO code;
ALTER TABLE IF EXISTS company
    RENAME COLUMN short_name_zis TO short_name;

ALTER TABLE IF EXISTS company
    DROP CONSTRAINT IF EXISTS company_code_rics_unique;
ALTER TABLE IF EXISTS company
    ADD CONSTRAINT company_code_unique UNIQUE (code);
ALTER TABLE IF EXISTS company
    DROP CONSTRAINT IF EXISTS company_code_rics_short_name_zis_unique;
ALTER TABLE IF EXISTS company
    ADD CONSTRAINT company_short_name_unique UNIQUE (short_name);
