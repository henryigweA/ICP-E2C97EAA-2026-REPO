#!/usr/bin/env bash
# Usage: backup.sh <source_dir> <backup_dir> [retention_days=7]
# Creates a timestamped .tar.gz, verifies it, and deletes backups older than retention.
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

[[ $# -ge 2 ]] || die "Usage: $0 <source_dir> <backup_dir> [retention_days]"
SRC="$1"; DEST="$2"; RETENTION="${3:-7}"

require_cmd tar
[[ -d "$SRC" ]] || die "Source directory does not exist: $SRC"
[[ "$RETENTION" =~ ^[0-9]+$ ]] || die "Retention must be a number of days"
acquire_lock
mkdir -p "$DEST"

STAMP="$(date '+%Y%m%d-%H%M%S')"
ARCHIVE="$DEST/$(basename "$SRC")-$STAMP.tar.gz"

info "Backing up $SRC -> $ARCHIVE"
tar -czf "$ARCHIVE" -C "$(dirname "$SRC")" "$(basename "$SRC")"

# Verify the archive is readable - "tar exited 0" alone isn't proof
tar -tzf "$ARCHIVE" >/dev/null || { rm -f "$ARCHIVE"; die "Archive verification failed, removed $ARCHIVE"; }
info "Backup OK ($(du -h "$ARCHIVE" | cut -f1))"

# Retention
DELETED=$(find "$DEST" -maxdepth 1 -name "$(basename "$SRC")-*.tar.gz" -mtime +"$RETENTION" -print -delete | wc -l)
info "Retention: removed $DELETED backup(s) older than $RETENTION days"
