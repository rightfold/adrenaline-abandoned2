-- Revert adrenaline:schema from pg

BEGIN;

DROP SCHEMA adrenaline;

COMMIT;
