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
VERSION=3.2.2
wget https://github.com/navikt/fluent-bit-release/releases/download/v${VERSION}/fluent-bit-${VERSION}-linux-x86_64-static.tar.gz
tar -xzf fluent-bit-${VERSION}-linux-x86_64-static.tar.gz
cd fluent-bit-linux-x86_64
./fluent-bit --version
```

## Manual Trigger

To manually trigger a build:

1. Go to the [Actions](https://github.com/navikt/fluent-bit-release/actions) tab
2. Select "Build and Release Fluent Bit" workflow
3. Click "Run workflow"

The workflow will check for the latest Fluent Bit version and create a release if one doesn't already exist.
