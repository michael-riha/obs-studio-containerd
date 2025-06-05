
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

# SRT input from `ffmpeg`

`ffmpeg -f lavfi -i testsrc=size=1920x1080:rate=30 -f lavfi -i sine=frequency=440:sample_rate=44100 -c:v libx264 -pix_fmt yuv420p -preset ultrafast -tune zerolatency -b:v 2500k -c:a aac -b:a 128k -f mpegts -f mpegts "srt://obs:9999?pkt_size=1316&mode=caller"`

After a few 
```
   Last message repeated 1 times

[out#0/mpegts @ 0x5d41bfec8340] Error muxing a packet

```

Improved command
https://obsproject.com/kb/srt-protocol-streaming-guide

https://ffmpeg.org/ffmpeg-protocols.html#srt
 Maybe works better with https://johnvansickle.com/ffmpeg/