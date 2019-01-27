-- Deploy adrenaline:schema to pg

BEGIN;

CREATE SCHEMA adrenaline;

GRANT USAGE
    ON SCHEMA adrenaline
    TO adrenaline_application,
       adrenaline_test;

COMMIT;
