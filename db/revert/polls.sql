-- Revert adrenaline:polls from pg

BEGIN;

DROP TABLE adrenaline.polls;

COMMIT;
