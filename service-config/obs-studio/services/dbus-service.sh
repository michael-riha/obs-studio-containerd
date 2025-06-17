#!/bin/bash
set -e

echo "Starting D-Bus service..."

# Clean up any stale files
rm -f /run/dbus/pid
rm -f /var/run/dbus/pid

# Start D-Bus
mkdir -p /var/run/dbus
dbus-uuidgen > /var/lib/dbus/machine-id
dbus-daemon --system --nopidfile

echo "D-Bus service is running"

# Keep the script running to maintain the screen session
while true; do
  sleep 3600
done