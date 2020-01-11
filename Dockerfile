FROM flum1025/gdrive-cron:20200110223857

COPY ./mounter.sh /mounter.sh
COPY ./entrypoint.sh /entrypoint.sh
