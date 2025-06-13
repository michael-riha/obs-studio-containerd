
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
# SRT input from `ffmpeg` to `srt://obs:xxxx...`

step into the container `docker compose exec ffmpeg bash`

`ffmpeg -f lavfi -i testsrc=size=1920x1080:rate=30 -f lavfi -i sine=frequency=440:sample_rate=44100 -c:v libx264 -pix_fmt yuv420p -preset ultrafast -tune zerolatency -b:v 2500k -c:a aac -b:a 128k -f mpegts -f mpegts "srt://obs:9999?pkt_size=1316&mode=caller"`

## from your native `linux` device

### Cam

get your devices: `v4l2-ctl --list-devices` <br>
(e.g., `sudo apt install v4l-utils` on Debian/Ubuntu, `sudo dnf install v4l-utils` on Fedora/CentOS).

`ffmpeg -f v4l2 -i /dev/video0 -f alsa -i default -c:v libx264 -pix_fmt yuv420p -preset ultrafast -tune zerolatency -b:v 2500k -c:a aac -b:a 128k -f mpegts "srt://localhost:2000?pkt_size=1316&mode=caller"`

`ffmpeg -f v4l2 -i /dev/video4 -f alsa -i default -c:v libx264 -pix_fmt yuv420p -preset ultrafast -tune zerolatency -b:v 2500k -c:a aac -b:a 128k -f mpegts "srt://localhost:2000?pkt_size=1316&mode=caller"`

### Test Source

`ffmpeg -f lavfi -i testsrc=size=1920x1080:rate=30 -f lavfi -i sine=frequency=440:sample_rate=44100 -c:v libx264 -pix_fmt yuv420p -preset ultrafast -tune zerolatency -b:v 2500k -c:a aac -b:a 128k -f mpegts -f mpegts "srt://localhost:2000?pkt_size=1316&mode=caller"`

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