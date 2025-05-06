#!/bin/bash

# This script runs the dart build_runner using fvm in a monorepo characterized by package by component.
# Starts a child process for each component that has a build_runner dependency.
# Runs internationalization in the `app` component in the end.

set -euo pipefail

trap 'echo "Error occurred on line $LINENO. Exiting." >&2' ERR

# Function to print banner messages
log_info() {
  echo "[INFO] $1"
}

log_error() {
  echo "[ERROR] $1" >&2
}

# Array to hold background process IDs
pids=()

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
  if ! grep -q 'build_runner' "$dir/pubspec.yaml"; then
    log_info "Skipping package '$package' as it does not depend on build_runner."
    continue
  fi

  log_info "Triggering build_runner for package '$package' in directory '$dir'..."
  (
    # Change to package directory; if fails, exit the subshell.
    cd "$dir" || { log_error "Failed to change to directory '$dir'"; exit 1; }
    # Run build_runner command and prefix each line of output with package name.
    if ! fvm dart run build_runner build --delete-conflicting-outputs 2>&1 | sed "s/^/[$package] /"; then
      log_error "build_runner command failed for package '$package'."
      exit 1
    fi
  ) &
  pids+=("$!") # Save the background process ID
done

# Wait for all background build_runner processes to complete.
for pid in "${pids[@]}"; do
  if ! wait "$pid"; then
    log_error "A build_runner process (PID: $pid) exited with an error."
    exit 1
  fi
done

log_info "All build_runner processes completed successfully."

log_info "Generating internationalization code..."

# Change to app component directory; fail if not existent
cd "app" || { log_error "Failed to change to directory app"; exit 1; }

# Run build_runner and prefix every output line with the package name
if ! fvm flutter gen-l10n ; then
  log_error "Generating the localization code failed."
  exit 1
fi
