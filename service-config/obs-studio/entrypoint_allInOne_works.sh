#!/bin/bash
set -e

# Setup shutdown logic
trap 'trap " " SIGINT; kill -SIGINT 0; wait;' SIGINT SIGTERM

# Make sure screen is installed
command -v screen >/dev/null 2>&1 || { echo "Screen is not installed. Installing..."; apt-get update && apt-get install -y screen; }

# Create log directory
mkdir -p /var/log/obs-services

# Set the services directory
SERVICES_DIR="$(dirname "$0")/services"

# Make all service scripts executable
chmod +x ${SERVICES_DIR}/*.sh

# Function to start a service in a screen session with logging
start_service() {
    local name="$1"
    local script="$2"
    local logfile="/var/log/obs-services/${name}.log"
    
    echo "Starting $name service..."
    # Start the service in a detached screen session, with logging
    screen -dmS "$name" bash -c "$script 2>&1 | tee $logfile"
    echo "$name started in screen session. View with: screen -r $name"
    echo "Logs available at: $logfile"
}

# Start services in the correct order
start_service "dbus" "${SERVICES_DIR}/dbus-service.sh"
sleep 2  # Give D-Bus time to start

start_service "pulseaudio" "${SERVICES_DIR}/pulseaudio-service.sh"
sleep 3  # Give PulseAudio time to initialize

# Export environment variables for other processes
export PULSE_SERVER=/var/run/pulse/native
echo "export PULSE_SERVER=/var/run/pulse/native" >> /etc/environment
echo "export PULSE_SERVER=/var/run/pulse/native" >> /etc/profile.d/pulse.sh

# Start OBS and FFmpeg
start_service "obs" "${SERVICES_DIR}/obs-service.sh"
start_service "ffmpeg" "${SERVICES_DIR}/ffmpeg-service.sh"

# Print instructions for accessing the screen sessions
echo ""
echo "All services started in screen sessions."
echo "To list all sessions: screen -ls"
echo "To attach to a session: screen -r [session_name]"
echo "To detach from a session: Ctrl+A, D"
echo ""
echo "Log files available in /var/log/obs-services/"

# Keep checking if all services are running
while true; do
    # You can add service health checks here if needed
    sleep 60
done