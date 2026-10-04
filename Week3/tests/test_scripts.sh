#!/usr/bin/env bash
# Minimal test harness for backup.sh and cleanup.sh. Run: bash Week3/tests/test_scripts.sh
set -uo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
S="$ROOT/Week2/scripts"
export LOG_DIR; LOG_DIR="$(mktemp -d)"
T="$(mktemp -d)"; PASS=0; FAIL=0
check() { if eval "$2" >/dev/null 2>&1; then echo "PASS: $1"; PASS=$((PASS+1)); else echo "FAIL: $1"; FAIL=$((FAIL+1)); fi; }

mkdir -p "$T/src" "$T/bk"; echo hello > "$T/src/a.txt"

"$S/backup.sh" "$T/src" "$T/bk" 7 2>/dev/null
check "backup creates an archive"            "ls $T/bk/src-*.tar.gz"
check "archive contains the file"            "tar -tzf $T/bk/src-*.tar.gz | grep -q a.txt"
check "backup fails on missing source"       "! $S/backup.sh $T/nope $T/bk 2>/dev/null"
check "backup fails with no arguments"       "! $S/backup.sh 2>/dev/null"

touch -d '40 days ago' "$T/bk/src-OLD.tar.gz"
"$S/backup.sh" "$T/src" "$T/bk" 7 2>/dev/null
check "retention removes old backups"        "! test -f $T/bk/src-OLD.tar.gz"

mkdir -p "$T/logs"; touch -d '40 days ago' "$T/logs/old.log"; touch "$T/logs/new.log"
"$S/cleanup.sh" "$T/logs" 30 --dry-run 2>/dev/null
check "dry-run keeps old file"               "test -f $T/logs/old.log"
"$S/cleanup.sh" "$T/logs" 30 2>/dev/null
check "cleanup deletes old file"             "! test -f $T/logs/old.log"
check "cleanup keeps new file"               "test -f $T/logs/new.log"
check "cleanup refuses protected path /etc"  "! $S/cleanup.sh /etc 1 2>/dev/null"

echo "---- $PASS passed, $FAIL failed"; rm -rf "$T" "$LOG_DIR"; [[ $FAIL -eq 0 ]]
