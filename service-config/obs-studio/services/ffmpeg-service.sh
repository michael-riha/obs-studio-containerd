#!/bin/bash
set -e

echo "Starting FFmpeg audio streaming..."

# Set the environment variable for PulseAudio
export PULSE_SERVER=/var/run/pulse/native

# Start FFmpeg streaming
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

# FFmpeg will keep running in the foreground