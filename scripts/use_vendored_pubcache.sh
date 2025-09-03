#!/usr/bin/env bash
set -euo pipefail

# Usage: ./scripts/use_vendored_pubcache.sh [path-to-vendored-cache] [packages...]
# If no packages provided, will run for packages/sltt_core and packages/sync_manager

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
VENDORED=${1:-"$REPO_ROOT/vendor/pub-cache"}
shift || true
PACKAGES=("${@:-packages/sltt_core packages/sync_manager}")

if [ ! -d "$VENDORED" ]; then
  echo "Vendored pub cache not found at: $VENDORED"
  echo "Please add a vendored pub-cache at that path (tarball or extracted), or run 'rsync -a --delete \"~/.pub-cache/\" $REPO_ROOT/vendor/pub-cache/' while online."
  exit 2
fi

echo "Using vendored pub cache: $VENDORED"
export PUB_CACHE="$VENDORED"

for pkg in "${PACKAGES[@]}"; do
  echo "\n=== Processing $pkg ==="
  if [ ! -d "$REPO_ROOT/$pkg" ]; then
    echo "Package directory not found: $REPO_ROOT/$pkg — skipping"
    continue
  fi

  cd "$REPO_ROOT/$pkg"
  echo "Running: dart pub get --offline in $pkg"
  if ! PUB_CACHE="$PUB_CACHE" dart pub get --offline; then
    echo "dart pub get --offline failed for $pkg"
    exit 3
  fi

  # Only attempt build_runner if build.yaml or pubspec references build_runner
  if grep -q "build_runner" pubspec.yaml 2>/dev/null || [ -f build.yaml ]; then
    echo "Running: dart run build_runner build --delete-conflicting-outputs in $pkg"
    PUB_CACHE="$PUB_CACHE" dart run build_runner build --delete-conflicting-outputs || {
      echo "build_runner failed for $pkg"
      exit 4
    }
  else
    echo "No build_runner usage detected in $pkg — skipping codegen step"
  fi
done

echo "\nAll done. Vendored cache used from: $VENDORED"
