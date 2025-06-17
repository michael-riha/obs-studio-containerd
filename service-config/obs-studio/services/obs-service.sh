#!/bin/bash
set -e

echo "Starting OBS Studio..."

# Set the environment variable for PulseAudio
export PULSE_SERVER=/var/run/pulse/native

# Verify PulseAudio connection
echo "Testing PulseAudio connection..."
if ! pactl info; then
    echo "PulseAudio connection failed."
    exit 1
fi

echo "PulseAudio connection verified, starting OBS..."
./install/bin/obs --studio-mode

# OBS will keep running in the foreground