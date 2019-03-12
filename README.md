# Penneo Signature Toolkit

Docker image with utilities and wrapper functions to validate Penneo signatures
from the command line

## Build the Image

```
docker build . -t ahmadnazir/penneo-signature-toolkit:0.1
```

## Run the container

```
docker run           \
  -v `pwd`:/mnt      \
  -u `id -u`:`id -g` \
  -it                \
  --rm               \
  -w /mnt            \
  ahmadnazir/penneo-signature-toolkit:0.1
```
