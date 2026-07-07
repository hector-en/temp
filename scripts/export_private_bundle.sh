#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'USAGE'
export_private_bundle.sh

Plain versioned private-bundle export.

Default behavior:
  /workspace/private/agentfield-grn-private_real_v0
    -> /mnt/egress/private-bundles/agentfield-grn-private_real_v<N>.zip

Usage:
  export_private_bundle.sh [SOURCE_ROOT] [OUT_DIR] [--dry-run]

Arguments:
  SOURCE_ROOT   Private bundle root to export.
                Default: /workspace/private/agentfield-grn-private_real_v0
  OUT_DIR       Export directory.
                Default: /mnt/egress/private-bundles
  --dry-run     Print planned output without creating files.

Rules:
  - Does not mutate SOURCE_ROOT.
  - Does not overwrite existing zips.
  - Preserves the source root folder name inside the zip.
  - Does not include /mnt/ingress, /mnt/egress, or the whole /workspace.
  - Excludes common transient cache files only.
USAGE
}

SOURCE_ROOT="/workspace/private/agentfield-grn-private_real_v0"
OUT_DIR="/mnt/egress/private-bundles"
DRY_RUN="no"

args=()
while [ "$#" -gt 0 ]; do
  case "$1" in
    -h|--help)
      usage
      exit 0
      ;;
    --dry-run)
      DRY_RUN="yes"
      shift
      ;;
    *)
      args+=("$1")
      shift
      ;;
  esac
done

if [ "${#args[@]}" -ge 1 ]; then
  SOURCE_ROOT="${args[0]}"
fi
if [ "${#args[@]}" -ge 2 ]; then
  OUT_DIR="${args[1]}"
fi
if [ "${#args[@]}" -gt 2 ]; then
  echo "ERROR: too many positional arguments" >&2
  usage >&2
  exit 2
fi

if [ ! -d "$SOURCE_ROOT" ]; then
  echo "ERROR: SOURCE_ROOT does not exist or is not a directory: $SOURCE_ROOT" >&2
  exit 1
fi

BUNDLE_ROOT_NAME="$(basename "$SOURCE_ROOT")"
# For agentfield-grn-private_real_v0, export family is agentfield-grn-private_real_v<N>.zip
EXPORT_FAMILY="${BUNDLE_ROOT_NAME%_v[0-9]*}"
if [ "$EXPORT_FAMILY" = "$BUNDLE_ROOT_NAME" ]; then
  EXPORT_FAMILY="$BUNDLE_ROOT_NAME"
fi

mkdir -p "$OUT_DIR"

max_ver=-1
shopt -s nullglob
for path in "$OUT_DIR"/"$EXPORT_FAMILY"_v*.zip; do
  file="$(basename "$path")"
  ver_part="${file#${EXPORT_FAMILY}_v}"
  ver_part="${ver_part%.zip}"
  if [[ "$ver_part" =~ ^[0-9]+$ ]]; then
    if [ "$ver_part" -gt "$max_ver" ]; then
      max_ver="$ver_part"
    fi
  fi
done
shopt -u nullglob

next_ver=$((max_ver + 1))
OUT_ZIP="$OUT_DIR/${EXPORT_FAMILY}_v${next_ver}.zip"
MANIFEST="$OUT_DIR/${EXPORT_FAMILY}_v${next_ver}_export_manifest.md"

if [ -e "$OUT_ZIP" ] || [ -e "$MANIFEST" ]; then
  echo "ERROR: output already exists, refusing overwrite:" >&2
  echo "  $OUT_ZIP" >&2
  echo "  $MANIFEST" >&2
  exit 1
fi

cat <<PLAN
Private bundle export plan:
  source root: $SOURCE_ROOT
  source root folder inside zip: $BUNDLE_ROOT_NAME/
  output dir: $OUT_DIR
  existing highest version: $max_ver
  next output zip: $OUT_ZIP
  manifest: $MANIFEST
  dry run: $DRY_RUN
PLAN

if [ "$DRY_RUN" = "yes" ]; then
  exit 0
fi

if ! command -v zip >/dev/null 2>&1; then
  echo "ERROR: zip command is required but not found" >&2
  exit 1
fi

SOURCE_PARENT="$(dirname "$SOURCE_ROOT")"
(
  cd "$SOURCE_PARENT"
  zip -r "$OUT_ZIP" "$BUNDLE_ROOT_NAME" \
    -x "*/__pycache__/*" \
    -x "*.pyc" \
    -x "*/.pytest_cache/*" \
    -x "*/.mypy_cache/*" \
    -x "*/.ruff_cache/*" \
    -x "*/.DS_Store" \
    -x "*/tmp/*" \
    -x "*/.tmp/*" \
    >/dev/null
)

if command -v sha256sum >/dev/null 2>&1; then
  SHA256="$(sha256sum "$OUT_ZIP" | awk '{print $1}')"
else
  SHA256="unavailable: sha256sum not found"
fi

{
  echo "# Private Bundle Export Manifest"
  echo
  echo "- Created UTC: $(date -u +%Y%m%dT%H%M%SZ)"
  echo "- Source root: $SOURCE_ROOT"
  echo "- Zip root folder: $BUNDLE_ROOT_NAME/"
  echo "- Output zip: $OUT_ZIP"
  echo "- SHA256: $SHA256"
  echo "- Overwrite: no"
  echo "- Mutated source files: no"
  echo
  echo "## Exclusions"
  echo
  echo "Common transient cache files only: __pycache__, *.pyc, .pytest_cache, .mypy_cache, .ruff_cache, .DS_Store, tmp, .tmp."
} > "$MANIFEST"

echo "Created: $OUT_ZIP"
echo "SHA256: $SHA256"
echo "Manifest: $MANIFEST"
