#!/bin/bash

# This script runs flutter test using fvm in a flutter repository characterized by Package by Component.
# Only runs the test if `test` directory is present in the component.

set -euo pipefail

trap 'echo "Error occurred on line $LINENO. Exiting." >&2' ERR

# Function to print banner messages
log_info() {
  echo "[INFO] $1"
}

log_error() {
  echo "[ERROR] $1" >&2
}

# Check if any package directories exist
shopt -s nullglob
package_dirs=(*/)
if [ ${#package_dirs[@]} -eq 0 ]; then
  log_info "No package directories found. Exiting."
  exit 0
fi

# Iterate through each package directory
for dir in "${package_dirs[@]}"; do
  package="${dir%/}"  # Remove trailing slash for logging purposes
  if ! [ -f "$dir/pubspec.yaml" ]; then
    continue
  fi
  if ! [ -d "$dir/test" ]; then
    log_info "Skipping package '$package' as it does not contain test directory."
    continue
  fi
  log_info "Running flutter test for package '$package' in directory..."
  # Change to package directory; if fails, exit
  cd "$dir" || { log_error "Failed to change to directory '$dir'"; exit 1; }

  # Run build_runner command and prefix each line of output with package name.
  if ! fvm flutter test --no-pub 2>&1 | sed "s/^/[$package] /"; then
    log_error "flutter test command failed for package '$package'."
    exit 1
  fi

  cd ..
done

log_info "All tests ran."