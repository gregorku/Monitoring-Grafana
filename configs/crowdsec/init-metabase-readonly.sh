#!/bin/bash

###############################################################################
#
# Monitoring-Grafana Project
#
# File:
#   configs/crowdsec/init-metabase-readonly.sh
#
# Description:
#   Runs once, on first init of postgres-crowdsec (empty
#   data directory). Creates a read-only Postgres role for
#   Metabase, so it can query CrowdSec's alerts/decisions
#   without being able to write to CrowdSec's own database.
#
###############################################################################

set -e

psql -v ON_ERROR_STOP=1 --username "${POSTGRES_USER}" --dbname "${POSTGRES_DB}" <<-EOSQL

    CREATE ROLE ${METABASE_RO_USER} WITH LOGIN PASSWORD '${METABASE_RO_PASSWORD}';

    GRANT CONNECT ON DATABASE ${POSTGRES_DB} TO ${METABASE_RO_USER};

    GRANT USAGE ON SCHEMA public TO ${METABASE_RO_USER};

    GRANT SELECT ON ALL TABLES IN SCHEMA public TO ${METABASE_RO_USER};

    ALTER DEFAULT PRIVILEGES IN SCHEMA public
        GRANT SELECT ON TABLES TO ${METABASE_RO_USER};

EOSQL
