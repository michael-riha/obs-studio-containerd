#!/bin/bash

# Setup shutdown logic
trap 'trap " " SIGINT; kill -SIGINT 0; wait;' SIGINT SIGTERM

# Clean up any stale files
rm -f /run/dbus/pid
rm -f /var/run/dbus/pid
rm -f /var/run/pulse/pid
rm -rf /tmp/pulse-*

# Start D-Bus
mkdir -p /var/run/dbus
dbus-uuidgen > /var/lib/dbus/machine-id
dbus-daemon --system --nopidfile &
sleep 2

echo "Setting up PulseAudio..."

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
pulseaudio --system --disallow-exit --log-level=info --daemonize

# Give PulseAudio time to initialize
sleep 2

# Set the environment variable for all future commands
export PULSE_SERVER=/var/run/pulse/native

# Verify PulseAudio connection
echo "Testing PulseAudio connection..."
if pactl info; then
    echo "PulseAudio is working correctly!"
    
    # List available sinks for verification
    echo -e "\nAvailable audio sinks:"
    pactl list short sinks
    
    # List available sources for verification
    echo -e "\nAvailable audio sources:"
    pactl list short sources
else
    echo "PulseAudio connection failed."
    exit 1
fi

echo "PulseAudio configuration complete!"

# Export this for any child processes
echo "export PULSE_SERVER=/var/run/pulse/native" >> /etc/environment
echo "export PULSE_SERVER=/var/run/pulse/native" >> /etc/profile.d/pulse.sh

# Now you can start OBS with the correct environment variable
PULSE_SERVER=/var/run/pulse/native ./install/bin/obs --studio-mode &
# initial command which works!
#ffmpeg -y -nostdin -f alsa -i pulse -f mpegts -codec:a mp2 http://proxy:8081/audiostream

#optimized trial to become realtime
ffmpeg -y -nostdin -f alsa -i pulse \
       -f mpegts -codec:a mp2 \
       -fflags nobuffer \
       -flags low_delay \
       -threads 1 \
       -muxdelay 0 \
       -muxpreload 0 \
       -flush_packets 1 \
       -bufsize 512k \
       -af "aresample=async=1:first_pts=0" \
       http://proxy:8081/audiostream

# proxy test which works!
# ffmpeg -re -f lavfi -i 'sine=frequency=520:duration=0' -f mpegts -codec:a mp2 http://proxy:8081/audiostream
# Keep the container running
wait