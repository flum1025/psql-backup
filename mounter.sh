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
BACKUP_FILENAME="/tmp/all_$DATE.sql.gz"

psql -h $DB_HOST -U $DB_USER -l
pg_dumpall -h $DB_HOST -U $DB_USER | pigz > $BACKUP_FILENAME

echo "INFO: start rclone"

rclone copy $BACKUP_FILENAME gdrive:$TARGET_DIR

echo "INFO: complete copy $BACKUP_FILENAME to $TARGET_DIR/all_$DATE.sql.gz"

echo "INFO: Remove $BACKUP_FILENAME"

rm $BACKUP_FILENAME

if [ -n "$CHECK_URL" ]; then
  curl -fsS --retry 3 $CHECK_URL && echo
fi

echo "INFO: end"
