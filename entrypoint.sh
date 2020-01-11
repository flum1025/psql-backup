#! /bin/sh

set -e

if [ ! -z "$CRON" ]; then
  echo "$CRON /mounter.sh" > /var/spool/cron/crontabs/root
else
  echo "FATAL: \$CRON not found"
  exit 1
fi

if [[ -z $DB_HOST ]] || [[ -z $DB_USER ]] || [[ -z $DB_PASS ]] || [[ -z $TARGET_DIR ]]; then
  echo "Environment variables are not defined"
  exit 1
fi

cat /var/spool/cron/crontabs/root

crond -l 8 -f -L /dev/stdout
