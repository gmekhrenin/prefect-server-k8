#!/usr/bin/env bash
set -e

for POSTGRESQL_SCHEMA in $(echo ${POSTGRESQL_SCHEMAS:-public} | tr ";" "\n")
do
  # verify user permission and extensions are on the database
  PGPASSWORD=${REPMGR_PASSWORD} psql -v ON_ERROR_STOP=1 --username ${REPMGR_USERNAME} <<-EOSQL
  GRANT ALL PRIVILEGES ON DATABASE ${POSTGRES_DB} TO ${POSTGRES_USER};
  \c ${POSTGRES_DB};
  CREATE SCHEMA IF NOT EXISTS "${POSTGRESQL_SCHEMA}";
  GRANT ALL PRIVILEGES ON SCHEMA "${POSTGRESQL_SCHEMA}" TO ${POSTGRES_USER};
  ALTER DEFAULT PRIVILEGES IN SCHEMA "${POSTGRESQL_SCHEMA}" GRANT ALL PRIVILEGES ON TABLES TO ${POSTGRES_USER};
  ALTER DEFAULT PRIVILEGES IN SCHEMA "${POSTGRESQL_SCHEMA}" GRANT ALL PRIVILEGES ON SEQUENCES TO ${POSTGRES_USER};
  ALTER DEFAULT PRIVILEGES IN SCHEMA "${POSTGRESQL_SCHEMA}" GRANT ALL PRIVILEGES ON FUNCTIONS TO ${POSTGRES_USER};
  CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
  CREATE EXTENSION IF NOT EXISTS "tablefunc";
  CREATE EXTENSION IF NOT EXISTS "pgcrypto";
  CREATE EXTENSION IF NOT EXISTS "pg_trgm";
EOSQL
done
