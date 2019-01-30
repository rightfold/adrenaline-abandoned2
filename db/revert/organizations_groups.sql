-- Revert adrenaline:organizations_groups from pg

BEGIN;

ALTER TABLE adrenaline.monitors
DROP COLUMN group_id;

DROP TABLE adrenaline.groups;

DROP TABLE adrenaline.organizations;

COMMIT;
