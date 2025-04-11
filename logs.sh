#!/bin/bash

# Create logs directory if it doesn't exist
mkdir -p logs

# Start all services in detached mode
echo "Starting services..."
docker compose up --force-recreate --remove-orphans --detach

# Capture logs in real-time to playground.log
echo "Capturing logs to logs/all.log..."
docker compose logs -f | tee logs/all.log

# The script will hang here and show logs in real-time
# When the user presses Ctrl+C, it will continue with the rest of the script

# Capture individual service logs before shutting down
echo "Saving individual service logs..."
SERVICES=$(docker compose ps --services)
for service in $SERVICES; do
  echo "- $service"
  docker compose logs "$service" > "logs/${service}.log"
done

# Shutdown services
echo "Shutting down services..."
docker compose down

echo "Log capture completed. All logs saved to the logs directory."
