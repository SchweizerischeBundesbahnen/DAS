#!/usr/bin/env bash
# -------------------------------------------------------------------
# DAS flavor-switch shell helper
#
# Source this file in your shell profile:
#   source /path/to/das_client/scripts/sf.sh
#
# Then use:
#   sf dev              switch to flavor dev
#   sf inte             switch to flavor inte
#   sf prod             switch to flavor prod (base if no folder)
#   sf rsb              restore base
#   sf sav dev <file>   save a single file to flavor dev
#   sf sva dev          save all git-changed files to flavor dev
#   sf dry dev          dry-run preview of a switch
#   sf tst              run the test-flavors matrix (melos)
#   sf help             show the full --help
#   sf <anything>       passed through to switch-flavor.mjs raw
# -------------------------------------------------------------------

sf() {
  # Locate the das_client repo root by walking up for scripts/switch-flavor.mjs.
  local dir="$PWD" root=""
  while [ "$dir" != "/" ]; do
    if [ -f "$dir/scripts/switch-flavor.mjs" ]; then root="$dir"; break; fi
    if [ -f "$dir/das_client/scripts/switch-flavor.mjs" ]; then root="$dir/das_client"; break; fi
    dir="$(dirname "$dir")"
  done
  if [ -z "$root" ]; then
    echo "sf: not inside the das_client repo (scripts/switch-flavor.mjs not found)" >&2
    return 1
  fi

  local script="$root/scripts/switch-flavor.mjs"
  local sub="${1:-}"; shift 2>/dev/null || true

  case "$sub" in
    dev|inte|prod) node "$script" "$sub" "$@" ;;
    rsb)           node "$script" --restore-base ;;
    sav)           node "$script" --save-to-flavor="$1" "$2" ;;
    sva)           node "$script" --save-to-flavor="$1" --all ;;
    dry)           node "$script" "$1" --dry-run ;;
    tst)           ( cd "$root" && fvm dart run melos test-flavors ) ;;
    ""|help|-h|--help) node "$script" --help ;;
    *)             node "$script" "$sub" "$@" ;;
  esac
}
