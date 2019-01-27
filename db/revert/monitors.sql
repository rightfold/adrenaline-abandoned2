-- Revert adrenaline:monitors from pg

BEGIN;

DROP TABLE adrenaline.monitors;

COMMIT;
