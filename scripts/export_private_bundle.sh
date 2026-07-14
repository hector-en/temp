#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'USAGE'
export_private_bundle.sh

Plain versioned private-bundle export.

Default behavior:
  explicit private root
    -> /mnt/egress/private-bundles/<verified-root-basename>.zip

Usage:
  export_private_bundle.sh [SOURCE_ROOT] [OUT_DIR] [--dry-run]

Arguments:
  SOURCE_ROOT   Private bundle root to export.
                Preferred: explicit verified project root.
                Fallback: unique discoverable root under /workspace/private.
  OUT_DIR       Export directory.
                Default: /mnt/egress/private-bundles
  --dry-run     Print planned output without creating files.

Rules:
  - Treat the selected source root as authoritative.
  - Derive zip identity from verified source identity, not recency.
  - Does not mutate SOURCE_ROOT.
  - Does not overwrite existing zips.
  - Preserves the source root folder name inside the zip.
  - Does not include /mnt/ingress, /mnt/egress, or the whole /workspace.
  - Excludes common transient cache files only.
USAGE
}

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SOURCE_ROOT=""
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

discover_source_root() {
  local base="/workspace/private"
  local candidates=()
  local child=""

  if [ ! -d "$base" ]; then
    echo "ERROR: no SOURCE_ROOT supplied and discovery base is missing: $base" >&2
    exit 1
  fi

  shopt -s nullglob
  for child in "$base"/agentfield-grn-private_real_v*; do
    [ -d "$child" ] || continue
    [ -f "$child/project.yaml" ] || continue
    [ -f "$child/layers.yaml" ] || continue
    [ -f "$child/batches.yaml" ] || continue
    [ -f "$child/hooks.yaml" ] || continue
    [ -f "$child/files.yaml" ] || continue
    candidates+=("$child")
  done
  shopt -u nullglob

  if [ "${#candidates[@]}" -eq 0 ]; then
    echo "ERROR: no explicit SOURCE_ROOT supplied and no eligible private roots were found under $base" >&2
    exit 1
  fi
  if [ "${#candidates[@]}" -gt 1 ]; then
    echo "ERROR: multiple eligible private roots found; choose one explicitly:" >&2
    printf '  %s\n' "${candidates[@]}" >&2
    exit 1
  fi

  SOURCE_ROOT="${candidates[0]}"
}

if [ -z "$SOURCE_ROOT" ]; then
  discover_source_root
fi

if [ ! -d "$SOURCE_ROOT" ]; then
  echo "ERROR: SOURCE_ROOT does not exist or is not a directory: $SOURCE_ROOT" >&2
  exit 1
fi

eval "$(
  python3 - "$REPO_ROOT" "$SOURCE_ROOT" <<'PY'
import json
import shlex
import sys

sys.path.insert(0, sys.argv[1])

from infractl.project import PrivateSourceResolutionError, resolve_private_source

try:
    info = resolve_private_source(sys.argv[2])
except PrivateSourceResolutionError as exc:
    print(json.dumps(exc.payload, indent=2), file=sys.stderr)
    raise SystemExit(2)

if info.get("source_kind") != "direct-root":
    raise SystemExit("Selected SOURCE_ROOT must resolve to a direct project root.")

values = {
    "BUNDLE_ROOT_NAME": info["root_basename"],
    "PRIVATE_BUNDLE_VERSION": info["verified_private_bundle_version"],
}
for key, value in values.items():
    print(f"{key}={shlex.quote(str(value))}")
PY
)"

mkdir -p "$OUT_DIR"
OUT_ZIP="$OUT_DIR/${BUNDLE_ROOT_NAME}.zip"
MANIFEST="$OUT_DIR/${BUNDLE_ROOT_NAME}_export_manifest.md"

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
  verified private bundle version: $PRIVATE_BUNDLE_VERSION
  output dir: $OUT_DIR
  output zip: $OUT_ZIP
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
  echo "- Verified private bundle version: $PRIVATE_BUNDLE_VERSION"
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
