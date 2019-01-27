-- Deploy adrenaline:monitors to pg
-- requires: schema

BEGIN;

CREATE TABLE adrenaline.monitors (
    id                      uuid                NOT NULL,

    poll_interval           INTERVAL            NOT NULL,

    object_type             "char"              NOT NULL,
    object_ping_host        CHARACTER VARYING,
    object_ping_timeout     INTERVAL,

    CONSTRAINT monitors_id
        PRIMARY KEY (id),

    CONSTRAINT monitors_poll_interval
        CHECK (poll_interval >= INTERVAL '00:00:00'),

    CONSTRAINT monitors_object_type
        CHECK (object_type IN ('P')),

    CONSTRAINT monitors_object_ping
        CHECK (
            object_type <> 'P' OR
            object_ping_host    IS NOT NULL      AND
            object_ping_timeout IS NOT NULL      AND
            object_ping_timeout <= poll_interval
        )
);

GRANT SELECT, INSERT, UPDATE, DELETE
    ON TABLE adrenaline.monitors
    TO adrenaline_application,
       adrenaline_test;

COMMIT;
