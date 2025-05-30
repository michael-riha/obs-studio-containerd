
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