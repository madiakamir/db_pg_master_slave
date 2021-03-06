#!/bin/bash

set -e
set -u


if [ ! -s "$PGDATA/PG_VERSION" ]; then
echo "*:*:*:$PG_REP_USER:$PG_REP_PASSWORD" > ~/.pgpass
chmod 0600 ~/.pgpass
until ping -c 1 -W 1 192.168.162.15
do
echo "Waiting for master to ping..."
sleep 1s
done
until pg_basebackup -h  192.168.162.15 -p 5432 -D ${PGDATA} -U ${PG_REP_USER} -P
do
echo "Waiting for master to connect..."
sleep 1s
done

set -e
cat > ${PGDATA}/recovery.conf <<EOF
standby_mode = on
primary_conninfo = 'host=192.168.162.15 port=5432 user=$PG_REP_USER password=$PG_REP_PASSWORD'
restore_command = 'cp /var/lib/postgresql/data/archive/%f %p'
trigger_file = '/tmp/touch_me_to_promote_to_me_master'
EOF
chown postgres. ${PGDATA} -R
chmod 700 ${PGDATA} -R
fi
sed -i 's/wal_level = hot_standby/wal_level = replica/g' ${PGDATA}/postgresql.conf
exec "$@"