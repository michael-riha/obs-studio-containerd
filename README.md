
## build it

`docker compose build` (`--no-cache`)

### build Stage 

had something around 4,2 GB

the limited `production`-stage has currently

```python
size_bytes = 991355749
size_mb = size_bytes / (1024 * 1024)
size_gb = size_mb / 1024

print(f"Docker image/container size: {size_mb:.2f} MB or {size_gb:.2f} GB")
```
> Docker image/container size: 945.78 MB or 0.92 GB


`docker compose up` (`--force-recreate`)


## run it



# TODOs:

- `aarch64` compatible -> https://aur.archlinux.org/packages/cef-minimal-obs-bin#:~:text=Required%20by%20(0)-,Sources%20(2),-https%3A//cdn%2Dfastly

- contact : https://github.com/a-rose/obs-headless
- customize or extend: https://github.com/theasp/docker-novnc
- start scripting: 
- https://github.com/obsproject/obs-studio/wiki/Getting-Started-With-OBS-Scripting
    - https://github.com/upgradeQ/Streaming-Software-Scripting-Reference
- add audio to `obs`
    - https://github.com/Envek/dockerized-browser-streamer
    - https://github.com/wu191287278/noVNC-audio
    - https://medium.com/@18bhavyasharma/enabling-sound-card-access-in-docker-containers-using-pulseaudio-d52ff1f5eee4

# Roadmap

- add `arm`-support
- add obs logging analyzer
    - https://github.com/obsproject/loganalyzer

# SRT input from `ffmpeg` to `srt://obs:xxxx...`

step into the container `docker compose exec ffmpeg bash`

`ffmpeg -f lavfi -i testsrc=size=1920x1080:rate=30 -f lavfi -i sine=frequency=440:sample_rate=44100 -c:v libx264 -pix_fmt yuv420p -preset ultrafast -tune zerolatency -b:v 2500k -c:a aac -b:a 128k -f mpegts -f mpegts "srt://obs:9999?pkt_size=1316&mode=caller"`

## from your native `linux` device

### Cam

get your devices: `v4l2-ctl --list-devices` <br>
(e.g., `sudo apt install v4l-utils` on Debian/Ubuntu, `sudo dnf install v4l-utils` on Fedora/CentOS).

`ffmpeg -f v4l2 -i /dev/video0 -f alsa -i default -c:v libx264 -pix_fmt yuv420p -preset ultrafast -tune zerolatency -b:v 2500k -c:a aac -b:a 128k -f mpegts "srt://localhost:2000?pkt_size=1316&mode=caller"`

`ffmpeg -f v4l2 -i /dev/video4 -f alsa -i default -c:v libx264 -pix_fmt yuv420p -preset ultrafast -tune zerolatency -b:v 2500k -c:a aac -b:a 128k -f mpegts "srt://localhost:2000?pkt_size=1316&mode=caller"`

As the above but more stable without errors:

`ffmpeg -f v4l2 -thread_queue_size 512 -i /dev/video4        -f alsa -thread_queue_size 1024 -i default        -c:v libx264 -pix_fmt yuv420p -preset ultrafast -tune zerolatency        -x264-params "nal-hrd=cbr:force-cfr=1" -b:v 2500k -maxrate 2500k -minrate 2500k -bufsize 2500k        -c:a aac -b:a 128k -ar 44100 -ac 2        -flush_packets 0 -muxdelay 0.1 -muxpreload 0.1        -f mpegts "srt://localhost:2000?pkt_size=1316&mode=caller&latency=200000&rcvbuf=10000000&sndbuf=10000000"`

Another approach to now make it with less delay and more aggressive low-latency

```bash
ffmpeg -f v4l2 -thread_queue_size 16 -framerate 30 -input_format yuyv422 -video_size 1280x720 -i /dev/video4 \
       -f alsa -thread_queue_size 512 -i default \
       -c:v libx264 -preset ultrafast -tune zerolatency -profile:v high422 \
       -x264-params "keyint=30:min-keyint=30:no-scenecut=1:rc-lookahead=0:sync-lookahead=0:nal-hrd=cbr" \
       -b:v 2500k -maxrate 2500k -minrate 2500k -bufsize 2500k \
       -g 30 -pix_fmt yuv420p \
       -c:a aac -b:a 128k -ar 48000 -ac 2 -af "aresample=async=1:first_pts=0" \
       -fflags nobuffer -flags low_delay \
       -muxdelay 0 -muxpreload 0 \
       -f mpegts "srt://localhost:2000?pkt_size=1316&mode=caller&latency=125000&tsbpd=yes&transtype=live"
```

### Test Source

`ffmpeg -f lavfi -i testsrc=size=1920x1080:rate=30 -f lavfi -i sine=frequency=440:sample_rate=44100 -c:v libx264 -pix_fmt yuv420p -preset ultrafast -tune zerolatency -b:v 2500k -c:a aac -b:a 128k -f mpegts -f mpegts "srt://localhost:2000?pkt_size=1316&mode=caller"`

### Test inside the `obs-headless` to send to `rtmp`

✋ obs has no display: NOT WORKING



goto: `docker compose exec novnc bash`

- `apt-get update && apt-get install ffmpeg`
    - `ffmpeg -f x11grab -s 1280x720 -i :0.0+100,100 -c:v libx264 -preset ultrafast -tune zerolatency -crf 25 -f flv rtmp://rtmp:1935`

### TODO

#### 🪲 Bug

After a few 
```
   Last message repeated 1 times

[out#0/mpegts @ 0x5d41bfec8340] Error muxing a packet

```

Improved command
https://obsproject.com/kb/srt-protocol-streaming-guide

https://ffmpeg.org/ffmpeg-protocols.html#srt
 Maybe works better with https://johnvansickle.com/ffmpeg/

# RTMP Server

copied from https://github.com/michael-riha/simple-rtmp-server/blob/master/scripts/ffmpeg_cli.sh

Key changes I've made:

- Changed `-index_correction 1` to `-index_correction 0` - This will prevent FFmpeg from trying to correct segment indices, which seems to be causing issues for the Shaka player.

- Changed `-use_timeline 0` to `-use_timeline 1` - Using the timeline feature in DASH can help the player better understand segment availability and timing.

# Frontend

open `http://localhost:8088` in your browser to view the streaming content