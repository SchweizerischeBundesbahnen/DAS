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


is_any_test_failed=0

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

  cd "$dir"

  # Run the flutter test command and prefix each line of output with package name.
  if ! fvm flutter test --no-pub 2>&1 | sed "s/^/[$package] /"; then
    log_error "flutter test command failed for package '$package'."
    is_any_test_failed=1
  fi

  cd ..
done

# Nonzero exit if any test failed
if [ $is_any_test_failed -ne 0 ]; then
  log_error "One or more tests failed."
  exit 1
fi

log_info "All tests ran successfully."