#! /bin/bash

set -eu

echo "INFO: start"

if [ -n "$CHECK_URL" ]; then
  curl -fsS --retry 3 $CHECK_URL/start && echo

  function error_handler() {
    echo "ERROR" >&2
    curl -fsS --retry 3 $CHECK_URL/fail && echo
    exit 1
  }

  trap error_handler ERR
fi

DATE=$(date '+%Y%m%d%H%M%S')
BACKUP_DIR="/tmp/$DATE"
TARGET_PATH="${TARGET_DIR}/${DATE}"

mkdir -p $BACKUP_DIR

psql_opt="-h $DB_HOST -U $DB_USER -p $DB_PORT"
psql_show_database="SELECT pg_database.datname FROM pg_database WHERE pg_database.datname NOT IN('template0', 'template1');"
psql_show_table="SELECT table_name FROM information_schema.tables WHERE table_schema = 'public' ORDER BY table_name;"

psql $psql_opt -l

for database in $(psql $psql_opt -t -c "$psql_show_database")
do
  echo "INFO: processing $database"
  for table in $(psql $psql_opt -t -c "$psql_show_table" $database)
  do
    echo "INFO: dumping ${database}.${table}"
    pg_dump $psql_opt -Fc --compress 9 -t $table $database > "${BACKUP_DIR}/${database}_${table}.dump"
  done
done

echo "INFO: start rclone"

rclone copy $BACKUP_DIR gdrive:$TARGET_PATH

echo "INFO: complete copy $BACKUP_DIR to $TARGET_PATH"

echo "INFO: Remove $BACKUP_DIR"

rm -rf $BACKUP_DIR

if [ -n "$CHECK_URL" ]; then
  curl -fsS --retry 3 $CHECK_URL && echo
fi

echo "INFO: end"
