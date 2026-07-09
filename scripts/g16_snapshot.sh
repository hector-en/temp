#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'USAGE'
Usage:
  g16_snapshot.sh <private_bundle_root> <batch_slug> <update_topic> [smoke_report_path] [--export-dir DIR] [--export-name NAME] [--dry-run]

Example:
  g16_snapshot.sh \
    /workspace/private/agentfield-grn-private_real_v0 \
    01-runtime-substrate \
    workflow_smoke_automation \
    /workspace/runs/smoke/20260627T161903Z-skeleton-progress/SMOKE_REPORT.md \
    --export-dir /mnt/egress/private-bundles \
    --export-name agentfield-grn-private_real_v0_workflow_smoke_automation.zip

Purpose:
  G16 snapshot-copy for an already-run skeleton batch update.
  Copies canonical runtime evidence into the private bundle under:
    sources/evidence_snapshots/skeleton/<batch_slug>/...
  copies update_workflow.md into:
    sources/workflow/update_workflow.md
  and optionally exports the updated private bundle zip to /mnt/egress.

Safety:
  - Does not modify historical evidence.
  - Does not rerun smoke.
  - Does not run live or mutating infrastructure actions.
  - Writes to /mnt/egress only when --export-dir is explicitly provided.
USAGE
}

if [ "${1:-}" = "-h" ] || [ "${1:-}" = "--help" ]; then
  usage
  exit 0
fi

if [ "$#" -lt 3 ]; then
  usage >&2
  exit 2
fi

BUNDLE_ROOT="$1"
BATCH_SLUG="$2"
UPDATE_TOPIC="$3"
shift 3

SMOKE_REPORT_PATH=""
EXPORT_DIR=""
EXPORT_NAME=""
DRY_RUN=0

if [ "$#" -gt 0 ] && [ "${1#--}" = "$1" ]; then
  SMOKE_REPORT_PATH="$1"
  shift
fi

while [ "$#" -gt 0 ]; do
  case "$1" in
    --export-dir)
      [ "$#" -ge 2 ] || { echo "ERROR: --export-dir needs a value" >&2; exit 2; }
      EXPORT_DIR="$2"
      shift 2
      ;;
    --export-name)
      [ "$#" -ge 2 ] || { echo "ERROR: --export-name needs a value" >&2; exit 2; }
      EXPORT_NAME="$2"
      shift 2
      ;;
    --dry-run)
      DRY_RUN=1
      shift
      ;;
    *)
      echo "ERROR: unknown argument: $1" >&2
      usage >&2
      exit 2
      ;;
  esac
done

SRC_EGRESS_BATCH="/mnt/egress/dev-recordings/skeleton/${BATCH_SLUG}"
SRC_UPDATE_DIR="${SRC_EGRESS_BATCH}/updates/${UPDATE_TOPIC}"
SRC_UPDATE_WORKFLOW="/mnt/ingress/infra/plans/workflow/update_workflow.md"

DST_WORKFLOW_DIR="${BUNDLE_ROOT}/sources/workflow"
DST_EVIDENCE_BATCH="${BUNDLE_ROOT}/sources/evidence_snapshots/skeleton/${BATCH_SLUG}"
DST_UPDATE_DIR="${DST_EVIDENCE_BATCH}/updates/${UPDATE_TOPIC}"

require_file() {
  local path="$1"
  if [ ! -f "$path" ]; then
    echo "ERROR: missing required file: $path" >&2
    exit 1
  fi
}

require_dir() {
  local path="$1"
  if [ ! -d "$path" ]; then
    echo "ERROR: missing required directory: $path" >&2
    exit 1
  fi
}

run_cmd() {
  if [ "$DRY_RUN" -eq 1 ]; then
    printf 'DRY_RUN:'
    printf ' %q' "$@"
    printf '\n'
  else
    "$@"
  fi
}

require_dir "$BUNDLE_ROOT"
require_file "$SRC_UPDATE_WORKFLOW"
require_file "${SRC_EGRESS_BATCH}/POSTCHECK.md"
require_file "${SRC_EGRESS_BATCH}/INTEGRATION_REQUEST.md"
require_file "${SRC_UPDATE_DIR}/UPDATE_POSTCHECK.md"
require_file "${SRC_UPDATE_DIR}/UPDATE_INTEGRATION_REQUEST.md"
require_file "${SRC_UPDATE_DIR}/CHANGESET_MANIFEST.md"

if [ -z "$SMOKE_REPORT_PATH" ]; then
  SMOKE_REPORT_PATH="$(find /workspace/runs/smoke -type f -path '*/SMOKE_REPORT.md' 2>/dev/null | sort | tail -n 1 || true)"
fi

if [ -z "$SMOKE_REPORT_PATH" ]; then
  echo "ERROR: no smoke report path provided and none found under /workspace/runs/smoke" >&2
  exit 1
fi
require_file "$SMOKE_REPORT_PATH"

run_cmd mkdir -p "$DST_WORKFLOW_DIR" "$DST_EVIDENCE_BATCH" "$DST_UPDATE_DIR"

run_cmd cp "$SRC_UPDATE_WORKFLOW" "${DST_WORKFLOW_DIR}/update_workflow.md"
run_cmd cp "${SRC_EGRESS_BATCH}/POSTCHECK.md" "${DST_EVIDENCE_BATCH}/POSTCHECK.md"
run_cmd cp "${SRC_EGRESS_BATCH}/INTEGRATION_REQUEST.md" "${DST_EVIDENCE_BATCH}/INTEGRATION_REQUEST.md"
run_cmd cp "$SMOKE_REPORT_PATH" "${DST_EVIDENCE_BATCH}/SMOKE_REPORT.md"
run_cmd cp "${SRC_UPDATE_DIR}/UPDATE_POSTCHECK.md" "${DST_UPDATE_DIR}/UPDATE_POSTCHECK.md"
run_cmd cp "${SRC_UPDATE_DIR}/UPDATE_INTEGRATION_REQUEST.md" "${DST_UPDATE_DIR}/UPDATE_INTEGRATION_REQUEST.md"
run_cmd cp "${SRC_UPDATE_DIR}/CHANGESET_MANIFEST.md" "${DST_UPDATE_DIR}/CHANGESET_MANIFEST.md"

EXPORT_PATH=""
if [ -n "$EXPORT_DIR" ]; then
  if [ -z "$EXPORT_NAME" ]; then
    EXPORT_NAME="$(basename "$BUNDLE_ROOT")_${BATCH_SLUG}_${UPDATE_TOPIC}_g16.zip"
  fi

  EXPORT_PATH="${EXPORT_DIR}/${EXPORT_NAME}"
  BUNDLE_PARENT="$(dirname "$BUNDLE_ROOT")"
  BUNDLE_BASENAME="$(basename "$BUNDLE_ROOT")"

  run_cmd mkdir -p "$EXPORT_DIR"

  if [ "$DRY_RUN" -eq 1 ]; then
    echo "DRY_RUN: (cd $BUNDLE_PARENT && zip -r $EXPORT_PATH $BUNDLE_BASENAME)"
  else
    python3 - "$BUNDLE_ROOT" "$EXPORT_PATH" <<'PYZIP'
import os
import sys
import zipfile
from pathlib import Path

bundle_root = Path(sys.argv[1]).resolve()
export_path = Path(sys.argv[2]).resolve()
export_path.parent.mkdir(parents=True, exist_ok=True)

with zipfile.ZipFile(export_path, "w", compression=zipfile.ZIP_DEFLATED) as zf:
    for path in bundle_root.rglob("*"):
        if path.is_file():
            zf.write(path, path.relative_to(bundle_root.parent))
PYZIP
    test -f "$EXPORT_PATH"
  fi
fi

cat <<REPORT
G16 snapshot-copy complete.

Bundle root:
- $BUNDLE_ROOT

Copied workflow:
- ${DST_WORKFLOW_DIR}/update_workflow.md

Copied original evidence snapshot:
- ${DST_EVIDENCE_BATCH}/POSTCHECK.md
- ${DST_EVIDENCE_BATCH}/INTEGRATION_REQUEST.md
- ${DST_EVIDENCE_BATCH}/SMOKE_REPORT.md

Copied update evidence snapshot:
- ${DST_UPDATE_DIR}/UPDATE_POSTCHECK.md
- ${DST_UPDATE_DIR}/UPDATE_INTEGRATION_REQUEST.md
- ${DST_UPDATE_DIR}/CHANGESET_MANIFEST.md

Source smoke report:
- $SMOKE_REPORT_PATH
REPORT

if [ -n "$EXPORT_PATH" ]; then
  cat <<REPORT

Export zip:
- $EXPORT_PATH
REPORT
fi
