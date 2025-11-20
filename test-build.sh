#!/bin/bash
set -e

# Parse arguments
VARIANT="${1:-no-lua}"  # Default to no-lua variant

if [[ "$VARIANT" != "no-lua" && "$VARIANT" != "luajit" ]]; then
    echo "Usage: $0 [no-lua|luajit]"
    echo ""
    echo "Variants:"
    echo "  no-lua  - Build without Lua support (default)"
    echo "  luajit  - Build with static LuaJIT support"
    exit 1
fi

# Get latest Fluent Bit version
echo "Fetching latest Fluent Bit version..."
VERSION=$(curl -s https://api.github.com/repos/fluent/fluent-bit/releases/latest | jq -r '.tag_name' | sed 's/^v//')
echo "Latest version: $VERSION"
echo "Building variant: $VARIANT"
echo ""

# Install dependencies (only if not in Docker)
if [[ "$OSTYPE" == "linux-gnu"* ]] && command -v sudo &> /dev/null; then
    echo "Installing dependencies..."
    sudo apt-get update
    sudo apt-get install -y \
        build-essential \
        cmake \
        flex \
        bison \
        libssl-dev \
        libyaml-dev \
        libsystemd-dev \
        wget \
        git
fi

# Download source
echo "Downloading Fluent Bit v${VERSION}..."
wget "https://github.com/fluent/fluent-bit/archive/refs/tags/v${VERSION}.tar.gz"
tar -xzf "v${VERSION}.tar.gz"
cd "fluent-bit-${VERSION}"

# Build
echo "Building Fluent Bit ($VARIANT variant)..."
rm -rf build
mkdir build
cd build

# Set LuaJIT flag based on variant
if [[ "$VARIANT" == "luajit" ]]; then
    LUAJIT_FLAG="Yes"
    SUFFIX="static-luajit"
    echo "Enabling LuaJIT support..."
else
    LUAJIT_FLAG="No"
    SUFFIX="static"
    echo "Building without Lua support..."
fi

cmake -DCMAKE_BUILD_TYPE=Release \
      -DFLB_RELEASE=On \
      -DFLB_DEBUG=No \
      -DFLB_SHARED_LIB=Off \
      -DFLB_STATIC_LIBS=On \
      -DFLB_IN_SYSTEMD=Off \
      -DFLB_CONFIG_YAML=Off \
      -DFLB_WASM=No \
      -DFLB_LUAJIT=${LUAJIT_FLAG} \
      -DOPENSSL_ROOT_DIR=/usr/local/ssl \
      -DOPENSSL_USE_STATIC_LIBS=ON \
      -DZLIB_ROOT=/usr/local/zlib \
      -DZLIB_USE_STATIC_LIBS=ON \
      -DCMAKE_PREFIX_PATH="/usr/local/zstd" \
      -DCMAKE_FIND_LIBRARY_SUFFIXES=".a" \
      -DBUILD_SHARED_LIBS=OFF \
      -DCMAKE_EXE_LINKER_FLAGS="-static -static-libgcc" \
      -DCMAKE_C_FLAGS="-fcommon" \
      ..

make -j$(nproc)

# Verify
echo ""
echo "Build complete! Verifying binary..."
file bin/fluent-bit
echo ""
echo "Checking dependencies (should fail for static binary):"
ldd bin/fluent-bit || echo "✓ Binary is statically linked (expected)"

# Test run
echo ""
echo "Testing binary..."
./bin/fluent-bit --version

# Package
echo ""
echo "Packaging ($VARIANT)..."
mkdir -p fluent-bit-linux-x86_64
cp bin/fluent-bit fluent-bit-linux-x86_64/
tar -czf "fluent-bit-${VERSION}-linux-x86_64-${SUFFIX}.tar.gz" fluent-bit-linux-x86_64

# Generate checksums
sha256sum "fluent-bit-${VERSION}-linux-x86_64-${SUFFIX}.tar.gz" > "fluent-bit-${VERSION}-linux-x86_64-${SUFFIX}.tar.gz.sha256"
sha512sum "fluent-bit-${VERSION}-linux-x86_64-${SUFFIX}.tar.gz" > "fluent-bit-${VERSION}-linux-x86_64-${SUFFIX}.tar.gz.sha512"

echo ""
echo "✓ Success! Package created: fluent-bit-${VERSION}-linux-x86_64-${SUFFIX}.tar.gz"
ls -lh "fluent-bit-${VERSION}-linux-x86_64-${SUFFIX}.tar.gz"*
echo ""
echo "Checksums:"
cat "fluent-bit-${VERSION}-linux-x86_64-${SUFFIX}.tar.gz.sha256"
cat "fluent-bit-${VERSION}-linux-x86_64-${SUFFIX}.tar.gz.sha512"
