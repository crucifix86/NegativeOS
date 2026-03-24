# NegativeOS APK Repository

Self-hosted package repository for NegativeOS.

## Structure

```
apk-repo/
├── x86_64/          built packages for 64-bit
├── x86/             built packages for 32-bit (i686)
├── noarch/          architecture-independent packages
├── keys/            signing keys (private key never committed)
│   ├── negativeos-packages.rsa      ← NEVER commit this
│   └── negativeos-packages.rsa.pub  ← bundle into OS image
└── scripts/
    ├── setup-repo.sh       generate signing keypair, init structure
    ├── build-package.sh    build an APKBUILD and drop into repo
    ├── index-repo.sh       sign + index all packages
    └── serve-repo.sh       local HTTP server for testing
```

## First-time setup

```bash
# 1. Generate signing key + init repo
./scripts/setup-repo.sh

# 2. Build a package
./scripts/build-package.sh palemoon

# 3. Index and sign
./scripts/index-repo.sh

# 4. Serve locally for testing
./scripts/serve-repo.sh 8080
```

## Production hosting

Point a web server (nginx, caddy) at this directory.
Update `overlay/etc/apk/repositories` with your public URL before building the ISO.

## Client usage (on NegativeOS)

```bash
apk update
apk add palemoon
apk upgrade
```
