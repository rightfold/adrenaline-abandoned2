#!/usr/bin/env bash

# TODO: Make this script idempotent so it can be run more than once.

if [[ "$(whoami)" != 'postgres' ]]; then
    >&2 echo "$0 must run as 'postgres', not as '$(whoami)'."
    exit 1
fi

psql <<'EOF'
    CREATE ROLE adrenaline_application LOGIN PASSWORD 'adrenaline_application';
    CREATE ROLE adrenaline_migrations LOGIN PASSWORD 'adrenaline_migrations';
    CREATE ROLE adrenaline_test LOGIN PASSWORD 'adrenaline_test';
    CREATE DATABASE adrenaline_test OWNER adrenaline_migrations;
EOF

PGDATABASE=adrenaline_test psql <<'EOF'
    DROP SCHEMA public;
EOF
