# fluent-bit-release

Statically compiled fluent-bit binaries for Linux x86_64.

## Overview

This repository automatically builds and releases statically compiled versions of [Fluent Bit](https://github.com/fluent/fluent-bit) for Linux x86_64. The builds are triggered daily to check for new Fluent Bit releases and can also be manually triggered.

## Features

- **Static Linking**: Binaries are statically linked with no external dependencies
- **Automated Builds**: Daily checks for new Fluent Bit releases
- **Platform**: Linux x86_64
- **Source**: Official Fluent Bit releases from https://github.com/fluent/fluent-bit

## Installation

Download the latest release from the [Releases](https://github.com/navikt/fluent-bit-release/releases) page:

```bash
# Replace VERSION with the desired version
VERSION=4.2.0
wget https://github.com/navikt/fluent-bit-release/releases/download/v${VERSION}/fluent-bit-${VERSION}-linux-x86_64-static.tar.gz
tar -xzf fluent-bit-${VERSION}-linux-x86_64-static.tar.gz
cd fluent-bit-linux-x86_64
./fluent-bit --version
```

### Verify Download Integrity

Each release includes SHA256 and SHA512 checksums for verification:

```bash
# Download checksums
wget https://github.com/navikt/fluent-bit-release/releases/download/v${VERSION}/fluent-bit-${VERSION}-linux-x86_64-static.tar.gz.sha256
wget https://github.com/navikt/fluent-bit-release/releases/download/v${VERSION}/fluent-bit-${VERSION}-linux-x86_64-static.tar.gz.sha512

# Verify SHA256
sha256sum -c fluent-bit-${VERSION}-linux-x86_64-static.tar.gz.sha256

# Or verify SHA512
sha512sum -c fluent-bit-${VERSION}-linux-x86_64-static.tar.gz.sha512
```

## Manual Trigger

To manually trigger a build:

1. Go to the [Actions](https://github.com/navikt/fluent-bit-release/actions) tab
2. Select "Build and Release Fluent Bit" workflow
3. Click "Run workflow"
4. Optionally enable "Dry run mode" to test the build without creating a release

The workflow will check for the latest Fluent Bit version and create a release if one doesn't already exist.

## Dry Run Mode

The workflow includes a dry run mode for testing:

- **Pull Requests**: Automatically runs in dry run mode on PRs to `main` branch
- **Manual Trigger**: Can be enabled via the "Dry run mode" checkbox when manually triggering
- **Behavior**: Builds and packages the binary but skips release creation

This allows testing the build process before merging changes.

## Local Testing

You can test the build process locally using Docker to replicate the GitHub Actions environment:

### Prerequisites

- Docker installed on your system

### Build and Test

```bash
# Build the Docker test image
docker build -f Dockerfile.test -t fluent-bit-test .

# Run the build
docker run -v $(pwd):/output fluent-bit-test
```

The test will:

1. Download the latest Fluent Bit source code
2. Build OpenSSL and zlib statically
3. Build Fluent Bit with static linking
4. Verify the binary is statically linked
5. Generate SHA256 and SHA512 checksums
6. Package everything as a tarball

### Interactive Testing

For debugging or manual testing:

```bash
# Run interactively
docker run -it -v $(pwd):/output fluent-bit-test bash

# Then run the test script manually
./test-build.sh
```

### Test Script

The `test-build.sh` script can also be run directly on Linux systems:

```bash
./test-build.sh
```

Note: On Linux, the script will attempt to install dependencies using `apt-get`. On other systems (macOS), use Docker as shown above.

## Build Configuration

The static builds include:

- **OpenSSL 3.0.15** - Built statically for TLS support
- **zlib 1.3.1** - Built statically for compression
- **zstd 1.5.6** - Built statically for Zstandard compression
- **Disabled features**:
  - systemd input plugin (requires dynamic linking)
  - YAML configuration format (optional dependency)

All builds use:

- `-DFLB_STATIC_LIBS=On` - Enable static library linking
- `-DCMAKE_EXE_LINKER_FLAGS="-static -static-libgcc"` - Force static linking
- Release optimization flags
