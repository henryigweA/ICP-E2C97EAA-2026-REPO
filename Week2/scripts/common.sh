#!/usr/bin/env bash
# Shared helpers: logging, error handling, locking. Source this file; don't run it.
set -euo pipefail

LOG_DIR="${LOG_DIR:-$HOME/devops-logs}"
mkdir -p "$LOG_DIR"
SCRIPT_NAME="$(basename "${0:-script}" .sh)"
LOG_FILE="$LOG_DIR/${SCRIPT_NAME}.log"
LOCK_FILE="/tmp/${SCRIPT_NAME}.lock"

log() { # log LEVEL message...
  local level="$1"; shift
  printf '%s [%s] %s\n' "$(date '+%Y-%m-%d %H:%M:%S')" "$level" "$*" | tee -a "$LOG_FILE" >&2
}
info()  { log INFO  "$@"; }
warn()  { log WARN  "$@"; }
error() { log ERROR "$@"; }
die()   { error "$@"; exit 1; }

on_error() { error "Failed at line $1 (exit code $2)"; }
trap 'on_error $LINENO $?' ERR

# Prevent two copies of the same script running at once (e.g. overlapping cron runs)
acquire_lock() {
  exec 9>"$LOCK_FILE"
  flock -n 9 || die "Another instance of $SCRIPT_NAME is already running"
}

require_cmd() { command -v "$1" >/dev/null 2>&1 || die "Required command not found: $1"; }
