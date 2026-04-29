#!/usr/bin/env bash

# Resolve project root (script is in Extra/, so go one level up)
ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"

cd "$ROOT_DIR" || exit 1

find . -type d -name "Old" -prune -o -type f -name "*.m" -exec sh -c '
for f do
    echo "=== $f ==="

    # Extract function signature
    sig=$(grep -m 1 "^function" "$f")

    # Extract first comment line
    header=$(grep -m 1 "^%" "$f")

    [ -n "$sig" ] && echo "$sig" || echo "[NO FUNCTION SIGNATURE]"
    [ -n "$header" ] && echo "$header" || echo "[NO HEADER COMMENT]"

    echo
done
' sh {} +