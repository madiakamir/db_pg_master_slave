#!/bin/bash
echo "host	replication	merchant_replicator	all	    md5" >> "$PGDATA/pg_hba.conf"
echo "host	all			merchant_user		all		md5" >> "$PGDATA/pg_hba.conf"



set -e
set -u

mkdir /var/lib/postgresql/data/archive;


psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
CREATE USER $PG_REP_USER REPLICATION LOGIN CONNECTION LIMIT 100 ENCRYPTED PASSWORD '$PG_REP_PASSWORD';
EOSQL


cat >> ${PGDATA}/postgresql.conf <<EOF
wal_level = hot_standby
archive_mode = on
archive_command = 'cp %p /var/lib/postgresql/data/archive/%f'
max_wal_senders = 10
wal_keep_segments = 64
hot_standby = on
synchronous_commit = local
synchronous_standby_names = 'pgslave001'
EOF

function create_user_and_database() {
	local database=$1
	echo "  Creating user and database '$database'"
	psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" <<-EOSQL
	    CREATE USER $database;
	    CREATE DATABASE $database;
	    GRANT ALL PRIVILEGES ON DATABASE $database TO $database;
EOSQL
}

if [ -n "$POSTGRES_MULTIPLE_DATABASES" ]; then
	echo "Multiple database creation requested: $POSTGRES_MULTIPLE_DATABASES"
	for db in $(echo $POSTGRES_MULTIPLE_DATABASES | tr ',' ' '); do
		create_user_and_database $db
	done
	echo "Multiple databases created"
fi
