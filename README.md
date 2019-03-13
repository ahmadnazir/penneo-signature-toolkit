# Penneo Signature Toolkit

Docker image with utilities and wrapper functions to validate Penneo signatures
from the command line

## Build the Image

```
docker build . -t ahmadnazir/penneo-signature-toolkit:0.2
```

## Run the container

```
docker run           \
  -v `pwd`:/mnt      \
  -u `id -u`:`id -g` \
  -it                \
  --rm               \
  -w /mnt            \
  ahmadnazir/penneo-signature-toolkit:0.2
```

## What can you do inside the container?

### Extract the attachments from a signed document:

```
pdfdetach -saveall signed.pdf
```

This will show you all the attachments for `signed.pdf`:

```
bash-4.4$ ls
3fc266fd847e707c.xml  audit.txt             penneo.json           signed.pdf
```

### Extract the certificates (x509) from the `Signature File` / `Penneo Signature`

Usually, there are 3 certificates in every Penneo signature:

```
cat 3fc266fd847e707c.xml | extract-certificate 1 # intermediate certificate
cat 3fc266fd847e707c.xml | extract-certificate 2 # root certificate
cat 3fc266fd847e707c.xml | extract-certificate 3 # signer certificate
```

### What is the common name in a certificate?

Let's take the signer certificate which usually is at index `3`:

```
cat 3fc266fd847e707c.xml | extract-certificate 3 | base64 -d | der-to-pem | x509
```

### What is the visible data that is being signed?

```
cat 3fc266fd847e707c.xml | extract-sign-text
```
