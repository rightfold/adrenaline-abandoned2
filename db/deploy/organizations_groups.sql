-- Deploy adrenaline:organizations_groups to pg
-- requires: monitors

BEGIN;

CREATE TABLE adrenaline.organizations (
    id                  uuid    NOT NULL,

    CONSTRAINT organizations_pk
        PRIMARY KEY (id)
);

CREATE TABLE adrenaline.groups (
    id                  uuid    NOT NULL,
    organization_id     uuid    NOT NULL,

    CONSTRAINT groups_pk
        PRIMARY KEY (id),

    CONSTRAINT groups_organization_fk
        FOREIGN KEY (organization_id)
        REFERENCES adrenaline.organizations (id)
        ON DELETE CASCADE
);

CREATE INDEX groups_organization_id
    ON adrenaline.groups
    (organization_id);

ALTER TABLE adrenaline.monitors
ADD COLUMN group_id uuid NOT NULL,
ADD CONSTRAINT monitors_group_fk
    FOREIGN KEY (group_id)
    REFERENCES adrenaline.groups (id)
    ON DELETE CASCADE;

GRANT SELECT, INSERT, UPDATE, DELETE
    ON TABLE adrenaline.organizations,
             adrenaline.groups
    TO adrenaline_application,
       adrenaline_test;

COMMIT;
