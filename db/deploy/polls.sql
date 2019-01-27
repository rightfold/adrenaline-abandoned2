-- Deploy adrenaline:polls to pg
-- requires: monitors

BEGIN;

CREATE TABLE adrenaline.polls (
    monitor_id  uuid                        NOT NULL,
    timestamp   TIMESTAMP WITH TIME ZONE    NOT NULL,

    status      double precision,

    CONSTRAINT polls_pk
        PRIMARY KEY (monitor_id, timestamp),

    CONSTRAINT polls_monitor_fk
        FOREIGN KEY (monitor_id)
        REFERENCES adrenaline.monitors (id)
        ON DELETE CASCADE
);

COMMENT ON COLUMN adrenaline.polls.status IS
    'If the status is not NULL, it is the status of the object at the time the
     object was polled. If the status is NULL and the poll happened less than
     the monitor''s interval ago, the poll is still ongoing. If the status is
     NULL and the poll happened more than the monitor''s interval ago, the poll
     somehow crashed.';

GRANT SELECT, INSERT, UPDATE, DELETE
    ON TABLE adrenaline.polls
    TO adrenaline_application,
       adrenaline_test;

COMMIT;
