ALTER SEQUENCE ru_feature_seq RESTART WITH 1;

insert into ru_feature(id, company_code, name, enabled, last_modified_at, last_modified_by)
values (nextval('ru_feature_seq'), '1345', 'RUFEATURE', TRUE, '2025-04-17 10:18:34', 'unit_test');