#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'USAGE'
export_public_bundle.sh

Export the current InfraCTL public prompt bundle for upload into a new chat.

Default behavior:
  /workspace/repos/infractl-public
    -> /mnt/egress/public-bundle/infractl-public_v<N>/infractl.md
    -> /mnt/egress/public-bundle/infractl-public_v<N>/infractl.zip
    -> /mnt/egress/public-bundle/infractl-public_v<N>_bundle.zip

Usage:
  export_public_bundle.sh [INFRCTL_ROOT] [OUT_DIR] [--dry-run]

Arguments:
  INFRCTL_ROOT  Current public InfraCTL repository root.
                Default: /workspace/repos/infractl-public
  OUT_DIR       Export directory.
                Default: /mnt/egress/public-bundle
  --dry-run     Print planned output without creating files.

Rules:
  - Does not mutate INFRCTL_ROOT.
  - Does not overwrite existing exports.
  - Produces both separate upload files: infractl.md and infractl.zip.
  - The zip uses the current flat public-bundle layout at the zip root.
  - Produces an optional bundle zip containing both files.
USAGE
}

INFRCTL_ROOT="/workspace/repos/infractl-public"
OUT_DIR="/mnt/egress/public-bundle"
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
  INFRCTL_ROOT="${args[0]}"
fi
if [ "${#args[@]}" -ge 2 ]; then
  OUT_DIR="${args[1]}"
fi
if [ "${#args[@]}" -gt 2 ]; then
  echo "ERROR: too many positional arguments" >&2
  usage >&2
  exit 2
fi

INFRCTL_MD="$INFRCTL_ROOT/infractl.md"

if [ ! -f "$INFRCTL_MD" ]; then
  echo "ERROR: infractl.md not found: $INFRCTL_MD" >&2
  exit 1
fi

BUNDLE_ITEMS=(
  "README.md"
  "infractl.md"
  "prompt_guide.md"
  "workflow.md"
  "pyproject.toml"
  "dots"
  "examples"
  "infractl"
  "infractl_workflow.md"
  "instructions.md"
  "schemas"
  "scripts"
  "templates"
)

for item in "${BUNDLE_ITEMS[@]}"; do
  if [ ! -e "$INFRCTL_ROOT/$item" ]; then
    echo "ERROR: required bundle item not found: $INFRCTL_ROOT/$item" >&2
    exit 1
  fi
done

max_ver=-1
shopt -s nullglob
for path in "$OUT_DIR"/infractl-public_v*; do
  name="$(basename "$path")"
  ver_part="${name#infractl-public_v}"
  if [[ "$ver_part" =~ ^[0-9]+$ ]]; then
    if [ "$ver_part" -gt "$max_ver" ]; then
      max_ver="$ver_part"
    fi
  fi
done
for path in "$OUT_DIR"/infractl-public_v*_bundle.zip; do
  file="$(basename "$path")"
  ver_part="${file#infractl-public_v}"
  ver_part="${ver_part%_bundle.zip}"
  if [[ "$ver_part" =~ ^[0-9]+$ ]]; then
    if [ "$ver_part" -gt "$max_ver" ]; then
      max_ver="$ver_part"
    fi
  fi
done
shopt -u nullglob

next_ver=$((max_ver + 1))
RELEASE_DIR="$OUT_DIR/infractl-public_v${next_ver}"
OUT_MD="$RELEASE_DIR/infractl.md"
OUT_INFRCTL_ZIP="$RELEASE_DIR/infractl.zip"
OUT_BUNDLE_ZIP="$OUT_DIR/infractl-public_v${next_ver}_bundle.zip"
MANIFEST="$OUT_DIR/infractl-public_v${next_ver}_manifest.md"

for p in "$RELEASE_DIR" "$OUT_BUNDLE_ZIP" "$MANIFEST"; do
  if [ -e "$p" ]; then
    echo "ERROR: output already exists, refusing overwrite: $p" >&2
    exit 1
  fi
done

cat <<PLAN
Public InfraCTL export plan:
  infractl root: $INFRCTL_ROOT
  input markdown: $INFRCTL_MD
  bundle items: ${BUNDLE_ITEMS[*]}
  output dir: $OUT_DIR
  existing highest version: $max_ver
  release dir: $RELEASE_DIR
  output markdown: $OUT_MD
  output folder zip: $OUT_INFRCTL_ZIP
  optional combined bundle: $OUT_BUNDLE_ZIP
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

mkdir -p "$OUT_DIR"
mkdir -p "$RELEASE_DIR"
cp "$INFRCTL_MD" "$OUT_MD"

(
  cd "$INFRCTL_ROOT"
  zip -r "$OUT_INFRCTL_ZIP" "${BUNDLE_ITEMS[@]}" \
    -x "*/__pycache__/*" \
    -x "*.pyc" \
    -x "*/.DS_Store" \
    -x "generated/*" \
    >/dev/null
)

(
  cd "$RELEASE_DIR"
  zip -r "$OUT_BUNDLE_ZIP" "infractl.md" "infractl.zip" >/dev/null
)

sha_line() {
  local path="$1"
  if command -v sha256sum >/dev/null 2>&1; then
    sha256sum "$path" | awk '{print $1}'
  else
    echo "unavailable: sha256sum not found"
  fi
}

MD_SHA="$(sha_line "$OUT_MD")"
ZIP_SHA="$(sha_line "$OUT_INFRCTL_ZIP")"
BUNDLE_SHA="$(sha_line "$OUT_BUNDLE_ZIP")"

{
  echo "# Public InfraCTL Export Manifest"
  echo
  echo "- Created UTC: $(date -u +%Y%m%dT%H%M%SZ)"
  echo "- Source root: $INFRCTL_ROOT"
  echo "- Release dir: $RELEASE_DIR"
  echo "- Markdown: $OUT_MD"
  echo "- Markdown SHA256: $MD_SHA"
  echo "- Infractl folder zip: $OUT_INFRCTL_ZIP"
  echo "- Infractl zip SHA256: $ZIP_SHA"
  echo "- Combined bundle zip: $OUT_BUNDLE_ZIP"
  echo "- Combined bundle SHA256: $BUNDLE_SHA"
  echo "- Overwrite: no"
  echo "- Mutated source files: no"
  echo
  echo "## Expected upload set"
  echo
  echo "Upload these two files into a new chat:"
  echo
  echo "- $OUT_MD"
  echo "- $OUT_INFRCTL_ZIP"
} > "$MANIFEST"

echo "Created release dir: $RELEASE_DIR"
echo "Created markdown: $OUT_MD"
echo "Created infractl zip: $OUT_INFRCTL_ZIP"
echo "Created combined bundle: $OUT_BUNDLE_ZIP"
echo "Manifest: $MANIFEST"
echo "SHA256 infractl.zip: $ZIP_SHA"
