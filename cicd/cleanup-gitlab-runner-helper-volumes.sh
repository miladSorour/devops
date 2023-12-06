#!/bin/bash

# Define the pattern for volume names to be removed
VOLUME_PATTERN="runner-*"

# Define the maximum age of volumes in hours
MAX_AGE_HOURS=1

# Find and remove volumes matching the pattern and older than the specified age
docker volume ls -q -f name=$VOLUME_PATTERN | while read -r volume; do
  creation_time=$(docker volume inspect --format '{{.CreatedAt}}' "$volume")
  creation_timestamp=$(date -d "$creation_time" +%s)
  current_timestamp=$(date +%s)
  age_hours=$(( (current_timestamp - creation_timestamp) / 3600 ))

  if [ "$age_hours" -gt "$MAX_AGE_HOURS" ]; then
    echo "Removing volume: $volume (Age: $age_hours hours)"
    docker volume rm "$volume"
  fi
done
