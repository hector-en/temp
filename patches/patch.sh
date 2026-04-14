#!/usr/bin/env bash
set -euo pipefail

SRC_DIR="/c/Users/hector/documents/scripting/tools/app"
DST_DIR="$HOME/chatgpt_temp/tools/patches"

APPLY_PATCHES=0

if [ "${1-}" = "--apply" ]; then
    APPLY_PATCHES=1
    shift
fi

mkdir -p "$DST_DIR"

MOVED_PATCHES=()

if [ "$#" -gt 0 ]; then
    for arg in "$@"; do
        if [[ "$arg" = /* || "$arg" = ./* || "$arg" = ../* ]]; then
            patch_path="$arg"
        else
            patch_path="$DST_DIR/$arg"
        fi

        if [ ! -f "$patch_path" ]; then
            echo "Missing patch file: $patch_path" >&2
            exit 1
        fi

        MOVED_PATCHES+=("$patch_path")
    done
else
    mapfile -t PATCH_PATHS < <(
        find "$SRC_DIR" -type f -name '*.patch' | sort
    )

    if [ "${#PATCH_PATHS[@]}" -eq 0 ]; then
        echo "No patch files found under $SRC_DIR"
        exit 0
    fi

    for src_path in "${PATCH_PATHS[@]}"; do
        patch_name="$(basename "$src_path")"
        dst_path="$DST_DIR/$patch_name"

        mv "$src_path" "$dst_path"
        MOVED_PATCHES+=("$dst_path")
    done
fi

sudo chown vmuser:vmuser "${MOVED_PATCHES[@]}"
chmod +x "${MOVED_PATCHES[@]}"

for patch_file in "${MOVED_PATCHES[@]}"; do
    mapfile -t TARGET_FILES < <(
        awk '
            /^--- / || /^\+\+\+ / {
                path = substr($0, 5)
                sub(/^[ab]\//, "", path)
                if (path != "/dev/null") print path
            }
        ' "$patch_file" | sort -u
    )

    NORMALIZE_PATHS=()
    for rel_path in "${TARGET_FILES[@]}"; do
        if [ -f "$rel_path" ]; then
            NORMALIZE_PATHS+=("$rel_path")
        fi
    done
    NORMALIZE_PATHS+=("$patch_file")

    perl -0pi -e 's/\r\n/\n/g; s/\n?\z/\n/' "${NORMALIZE_PATHS[@]}"

    if [ "$APPLY_PATCHES" -eq 1 ]; then
        echo "=== Apply: $patch_file ==="
        patch -p1 < "$patch_file"
    else
        echo "=== Dry run: $patch_file ==="
        patch --dry-run -p1 < "$patch_file"
    fi

    echo
done