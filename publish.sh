image_name=flum1025/psql-backup:$(date '+%Y%m%d%H%M%S')
docker build -t $image_name .
docker push $image_name
