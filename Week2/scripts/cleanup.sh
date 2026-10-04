#!/usr/bin/env bash
# Usage: cleanup.sh <target_dir> [days_old=30] [--dry-run]
# Deletes regular files older than N days. Defaults to --dry-run-friendly and refuses dangerous paths.
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

DRY_RUN=false; ARGS=()
for a in "$@"; do [[ "$a" == "--dry-run" ]] && DRY_RUN=true || ARGS+=("$a"); done
[[ ${#ARGS[@]} -ge 1 ]] || die "Usage: $0 <target_dir> [days_old] [--dry-run]"
TARGET="$(realpath "${ARGS[0]}" 2>/dev/null)" || die "Invalid path: ${ARGS[0]}"
DAYS="${ARGS[1]:-30}"

[[ -d "$TARGET" ]] || die "Not a directory: $TARGET"
[[ "$DAYS" =~ ^[0-9]+$ ]] || die "Days must be a number"
# Safety guard: never operate on system-critical or home root paths
case "$TARGET" in
  /|/bin|/boot|/dev|/etc|/home|/lib*|/proc|/root|/sbin|/sys|/usr|/var|"$HOME")
    die "Refusing to clean protected path: $TARGET" ;;
esac
acquire_lock

COUNT=0
while IFS= read -r -d '' f; do
  if $DRY_RUN; then info "[dry-run] would delete $f"; else rm -f -- "$f"; info "deleted $f"; fi
  COUNT=$((COUNT+1))
done < <(find "$TARGET" -type f -mtime +"$DAYS" -print0)

info "Cleanup complete: $COUNT file(s) $($DRY_RUN && echo 'would be ')deleted from $TARGET (older than $DAYS days)"
