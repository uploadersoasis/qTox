#!/bin/bash
set -euo pipefail

usage() {
  echo "Usage: $0 --source-dir <dir> --target-dir <dir>"
}

if [ $# -lt 4 ]; then
  usage
  exit 1
fi

while (($# > 0)); do
  case $1 in
    --source-dir) SRCDIR="$2"; shift 2 ;;
    --target-dir) BUILD_DIR="$2"; shift 2 ;;
    *) echo "Unexpected argument $1"; usage; exit 1 ;;
  esac
done

# Ensure build directory exists
mkdir -p "$BUILD_DIR"

# Build qTox using CMake and Ninja
# We use -DUPDATE_CHECK=OFF for native packages as zypper handles updates
cmake "$SRCDIR" -B"$BUILD_DIR" -GNinja \
  -DCMAKE_INSTALL_PREFIX=/usr \
  -DBUILD_TESTING=OFF \
  -DUSE_QT6=ON \
  -DSPELL_CHECK=ON
  -DSMILEYS=ON \
  -DUPDATE_CHECK=OFF
cmake --build "$BUILD_DIR" --target package

# Look for the generated RPM. OpenSUSE naming usually skips the '-fc' suffix.
rpm_file="$(ls "$BUILD_DIR" | grep -E "qtox-.*\.rpm" | head -n 1 || echo "")"

if [ -z "$rpm_file" ]; then
  echo "Error! The RPM package was not built!"
  exit 1
fi

echo "$rpm_file was successfully generated."
