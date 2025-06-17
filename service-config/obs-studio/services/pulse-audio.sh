#!/bin/bash
set -e

echo "Setting up PulseAudio..."

# Clean up any stale files
rm -f /var/run/pulse/pid
rm -rf /tmp/pulse-*

# Create pulse user if needed
if ! id -u pulse > /dev/null 2>&1; then
    useradd -r -s /bin/false -d /var/run/pulse pulse
fi

# Create needed directories and set permissions
mkdir -p /var/run/pulse
chown -R pulse:pulse /var/run/pulse

# Create the system.pa file without including the modules that get loaded automatically
mkdir -p /etc/pulse
cat > /etc/pulse/system.pa << EOF
#!/usr/bin/pulseaudio -nF
# Only load modules that aren't loaded automatically
load-module module-native-protocol-unix auth-anonymous=1
load-module module-null-sink sink_name=v1 sink_properties=device.description="Virtual_Sink"
load-module module-null-sink sink_name=obs_output sink_properties=device.description="OBS_Output"
set-default-sink v1
set-default-source v1.monitor
EOF

# Kill any existing PulseAudio instances
pkill -9 pulseaudio || true
sleep 1

echo "Starting PulseAudio in system mode..."
pulseaudio --system --disallow-exit --log-level=info

# This script doesn't need to maintain a background job since pulseaudio runs as a daemon