Goal was to run it multi-arch

From this tutorial: https://www.blacksmith.sh/blog/building-multi-platform-docker-images-for-arm64-in-github-actions

Tested locally on `amd64` by installing

- `sudo apt-get install qemu-system`
- `sudo apt-get install qemu-user-static`
- `docker buildx ls`
- `docker buildx build --platform linux/amd64 -t <IMAGE-URI> -f Dockerfile .`
    - [more to read for local development](https://sergiiblog.com/devops-basics-how-to-build-docker-image-for-arm64-cpu-architecture-while-using-amd64-at-ubuntu/)

Debug missing `arm`-dependencies:

-  `docker buildx build --platform linux/arm64 --target dependencies -t miriha/obs-studio-containerd:latest -f Dockerfile-arm64 .`

- `docker run --rm -ti --pla
tform linux/arm64 miriha/obs-studio-containerd:latest bash`