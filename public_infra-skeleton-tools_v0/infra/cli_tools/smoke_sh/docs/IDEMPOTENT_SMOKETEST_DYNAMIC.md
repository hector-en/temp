# IDEMPOTENT_SMOKETEST.md — Dynamic Platform Smoke-Test Contract

Purpose: this document defines a reusable, idempotent smoke-test system for the current platform development state. The smoke test is not one fixed test. It is an orchestrator that discovers and runs the relevant safe local smoke checks for whatever platform parts currently exist: Kubernetes, Terraform, AgentField, RunPod, GRN, skeleton batches, organ batches, config integration, and future expansion modules.

The smoke test must be safe to run repeatedly. It must not delete user data, mutate live infrastructure, apply Terraform, deploy Kubernetes resources, start live organs, spend money, or change config unless explicitly invoked by a separate guarded integration workflow.

---

## 1. Mental model

| Item | Meaning |
|---|---|
| `IDEMPOTENT_SMOKETEST.md` | The specification/manual for how smoke tests are discovered, classified, run, and reported. |
| `smoke_current_state.sh` | The reusable smoke orchestrator script that runs the checks. |
| `smoke.d/` | Folder of domain-specific smoke test modules. |
| Smoke module | One small safe test for one platform area, for example Kubernetes, Terraform, AgentField, RunPod, GRN, skeleton, organ, or config. |
| Smoke report | The generated result file showing PASS/WARN/FAIL/SKIP per domain and overall. |

The intended design is:

```text
current project state
-> smoke_current_state.sh discovers available smoke modules
-> each module detects whether its domain exists
-> applicable modules run safe local checks only
-> one timestamped SMOKE_REPORT.md is written
```

---

## 2. Required project layout

Recommended stable layout:

```text
/workspace/
  docs/
    IDEMPOTENT_SMOKETEST.md
  scripts/
    smoke_current_state.sh
  tests/
    smoke.d/
      00-core.smoke.sh
      10-skeleton.smoke.sh
      20-organs.smoke.sh
      30-config.smoke.sh
      40-kubernetes.smoke.sh
      50-terraform.smoke.sh
      60-agentfield.smoke.sh
      70-runpod.smoke.sh
      80-grn.smoke.sh
      90-custom.smoke.sh
  runs/
    smoke/
      <timestamp>-<phase>/
        SMOKE_REPORT.md
        raw/
          <module>.stdout.log
          <module>.stderr.log
```

The smoke orchestrator may run even if some modules are missing. Missing optional modules are `SKIP`, not `FAIL`.

---

## 3. How to run it

After each skeleton batch:

```bash
BATCH_SLUG="01-runtime-substrate" bash /workspace/scripts/smoke_current_state.sh skeleton-progress
```

After all skeleton batches:

```bash
bash /workspace/scripts/smoke_current_state.sh skeleton-complete
```

After each organ batch:

```bash
BATCH_SLUG="R01-real-organ-foundation" bash /workspace/scripts/smoke_current_state.sh organ-progress
```

Before operator/config integration:

```bash
bash /workspace/scripts/smoke_current_state.sh pre-config
```

After operator/config integration:

```bash
bash /workspace/scripts/smoke_current_state.sh post-config
```

For any generic current-state check:

```bash
bash /workspace/scripts/smoke_current_state.sh current-state
```

---

## 4. Phase names

| Phase | When to use | Expected behavior |
|---|---|---|
| `skeleton-progress` | After one skeleton batch | Run core, skeleton, GRN/dummy checks if present; warn for organs not ready. |
| `skeleton-complete` | After all skeleton batches | Run full skeleton contract checks; organ modules may still skip. |
| `organ-progress` | After one organ batch | Run core, skeleton contract, organ dry-run, GRN checks if present. |
| `organ-complete` | After all organ batches | Run all skeleton + organ dry-run contract checks. |
| `pre-config` | Before vmuser/operator config integration | Confirm evidence, integration requests, companions, smoke reports exist. |
| `post-config` | After config integration | Confirm config/lv/workflow hooks are present and non-live smoke commands resolve. |
| `current-state` | Anytime | Detect what exists and run all applicable safe tests. |

---

## 5. Smoke module contract

Every file in `/workspace/tests/smoke.d/*.smoke.sh` is a module.

Each module must support this interface:

```bash
bash module.smoke.sh detect
bash module.smoke.sh run <phase> <report_dir>
```

Recommended optional commands:

```bash
bash module.smoke.sh describe
bash module.smoke.sh list-files
```

Exit code contract:

| Exit code | Meaning |
|---|---|
| `0` | PASS. The check ran and passed. |
| `10` | SKIP. Domain not present or not applicable in this phase. |
| `20` | WARN. Domain exists but optional readiness is incomplete. Continue only if expected. |
| `30` | FAIL. Required domain exists but the safe smoke check failed. Fix before continuing. |
| `40` | BLOCKED. Required evidence, permissions, or command is missing. Do not guess. |

Modules must print a short machine-readable final line:

```text
SMOKE_RESULT status=PASS module=grn message="dummy CLI produced expected files"
```

---

## 6. Domain module examples

| Module | Detects | Runs safe checks | Must not do |
|---|---|---|---|
| `00-core.smoke.sh` | `/workspace`, Python, git, basic folders | existence checks, version checks, path permissions | install packages globally, delete files |
| `10-skeleton.smoke.sh` | skeleton code, skeleton batch evidence | dummy CLI, expected output files, contract files | edit config, run real organs |
| `20-organs.smoke.sh` | organ code, organ batch evidence | real-organ dry-run only, output contract preservation | live organ execution, external calls unless mocked |
| `30-config.smoke.sh` | config/lv/workflow files | static config checks, command resolution, non-live status command | rewrite config, enable live mode |
| `40-kubernetes.smoke.sh` | `k8s/`, `charts/`, `kubectl`, manifests | `kubectl --dry-run=client`, `helm template`, YAML parse | `kubectl apply`, cluster mutation |
| `50-terraform.smoke.sh` | `terraform/`, `*.tf` | `terraform fmt -check`, `terraform validate` with no apply | `terraform apply`, remote state mutation |
| `60-agentfield.smoke.sh` | AgentField modules/configs | import checks, schema checks, dry-run planner | launch agents with live side effects |
| `70-runpod.smoke.sh` | RunPod templates/scripts | config presence, dry-run payload generation | create pods, spend credits, call live API unless mocked |
| `80-grn.smoke.sh` | GRN modules, DSL, simulator | import, parse sample DSL, tiny deterministic dry-run | long training, GPU jobs, live model mutation |
| `90-custom.smoke.sh` | future expansions | project-specific safe local checks | anything not explicitly safe/idempotent |

---

## 7. Required safety rules

All smoke modules must follow these rules:

| Rule | Requirement |
|---|---|
| Idempotent | Running the smoke test twice must not break state or create conflicting artifacts. |
| Local-first | Prefer local parse/import/dry-run checks. |
| No live mutation | No deploy, apply, live pod creation, live organ execution, or external cost-spending action. |
| Timestamped output | Reports go under `/workspace/runs/smoke/<timestamp-phase>/`. |
| Non-destructive | Never delete prior smoke reports. |
| Evidence-aware | If required evidence is missing, report `BLOCKED` with exact missing paths. |
| Phase-aware | Some modules skip before their domain exists. |
| Contract-preserving | Skeleton and organ modules must preserve expected output filenames and schemas. |

---

## 8. Orchestrator behavior

`/workspace/scripts/smoke_current_state.sh` should:

1. Accept one phase argument.
2. Create a timestamped report directory.
3. Discover all executable `*.smoke.sh` modules under `/workspace/tests/smoke.d/`.
4. For each module:
   - call `detect`;
   - if not applicable, record `SKIP`;
   - if applicable, call `run <phase> <report_dir>`;
   - capture stdout/stderr to raw logs;
   - record status in `SMOKE_REPORT.md`.
5. Compute overall status:
   - any `FAIL` or `BLOCKED` => overall `FAIL`;
   - no fail but at least one `WARN` => overall `WARN`;
   - all applicable checks pass, skipped optional checks allowed => overall `PASS`.
6. Print final report path.

---

## 9. Minimal orchestrator script

Save as:

```text
/workspace/scripts/smoke_current_state.sh
```

```bash
#!/usr/bin/env bash
set -u

PHASE="${1:-current-state}"
ROOT="${WORKSPACE_ROOT:-/workspace}"
SMOKE_DIR="$ROOT/tests/smoke.d"
RUN_ROOT="$ROOT/runs/smoke"
STAMP="$(date -u +%Y%m%dT%H%M%SZ)"
REPORT_DIR="$RUN_ROOT/${STAMP}-${PHASE}"
RAW_DIR="$REPORT_DIR/raw"
REPORT="$REPORT_DIR/SMOKE_REPORT.md"

mkdir -p "$RAW_DIR"

status_rank() {
  case "$1" in
    PASS) echo 0 ;;
    SKIP) echo 0 ;;
    WARN) echo 1 ;;
    FAIL) echo 2 ;;
    BLOCKED) echo 2 ;;
    *) echo 2 ;;
  esac
}

OVERALL="PASS"

{
  echo "# Smoke Report"
  echo
  echo "| Field | Value |"
  echo "|---|---|"
  echo "| Phase | $PHASE |"
  echo "| Timestamp UTC | $STAMP |"
  echo "| Workspace | $ROOT |"
  echo "| Smoke dir | $SMOKE_DIR |"
  echo "| Batch slug | ${BATCH_SLUG:-not-set} |"
  echo
  echo "## Module Results"
  echo
  echo "| Module | Status | Message |"
  echo "|---|---|---|"
} > "$REPORT"

if [ ! -d "$SMOKE_DIR" ]; then
  echo "| smoke.d | BLOCKED | Missing $SMOKE_DIR |" >> "$REPORT"
  echo "SMOKE_REPORT=$REPORT"
  exit 40
fi

FOUND=0
for module in "$SMOKE_DIR"/*.smoke.sh; do
  [ -e "$module" ] || continue
  FOUND=1
  name="$(basename "$module")"
  out="$RAW_DIR/${name}.stdout.log"
  err="$RAW_DIR/${name}.stderr.log"

  if [ ! -x "$module" ]; then
    chmod +x "$module" 2>/dev/null || true
  fi

  bash "$module" detect >"$out.detect" 2>"$err.detect"
  detect_code=$?

  if [ "$detect_code" -eq 10 ]; then
    echo "| $name | SKIP | Not applicable in current state |" >> "$REPORT"
    continue
  fi

  if [ "$detect_code" -ne 0 ]; then
    echo "| $name | BLOCKED | detect failed; see raw logs |" >> "$REPORT"
    OVERALL="FAIL"
    continue
  fi

  bash "$module" run "$PHASE" "$REPORT_DIR" >"$out" 2>"$err"
  code=$?

  case "$code" in
    0) status="PASS" ;;
    10) status="SKIP" ;;
    20) status="WARN" ;;
    30) status="FAIL" ;;
    40) status="BLOCKED" ;;
    *) status="FAIL" ;;
  esac

  message="see raw/${name}.stdout.log and raw/${name}.stderr.log"
  final_line="$(grep 'SMOKE_RESULT' "$out" | tail -n 1 || true)"
  if [ -n "$final_line" ]; then
    message="$(printf '%s' "$final_line" | sed 's/|/-/g')"
  fi

  echo "| $name | $status | $message |" >> "$REPORT"

  if [ "$(status_rank "$status")" -gt "$(status_rank "$OVERALL")" ]; then
    OVERALL="$status"
  fi
done

if [ "$FOUND" -eq 0 ]; then
  echo "| smoke.d | BLOCKED | No smoke modules found |" >> "$REPORT"
  OVERALL="FAIL"
fi

{
  echo
  echo "## Overall"
  echo
  echo "| Field | Value |"
  echo "|---|---|"
  echo "| Overall status | $OVERALL |"
  echo "| Report path | $REPORT |"
} >> "$REPORT"

echo "SMOKE_REPORT=$REPORT"

case "$OVERALL" in
  PASS|SKIP) exit 0 ;;
  WARN) exit 20 ;;
  *) exit 30 ;;
esac
```

---

## 10. Minimal core module

Save as:

```text
/workspace/tests/smoke.d/00-core.smoke.sh
```

```bash
#!/usr/bin/env bash
set -u

cmd="${1:-}"
phase="${2:-current-state}"
report_dir="${3:-/tmp}"
ROOT="${WORKSPACE_ROOT:-/workspace}"

case "$cmd" in
  detect)
    [ -d "$ROOT" ] || exit 40
    exit 0
    ;;
  run)
    missing=""
    [ -d "$ROOT" ] || missing="$missing $ROOT"
    command -v bash >/dev/null 2>&1 || missing="$missing bash"
    command -v find >/dev/null 2>&1 || missing="$missing find"
    mkdir -p "$ROOT/runs/smoke" 2>/dev/null || missing="$missing $ROOT/runs/smoke"

    if [ -n "$missing" ]; then
      echo "SMOKE_RESULT status=BLOCKED module=core message=\"missing:$missing\""
      exit 40
    fi

    echo "SMOKE_RESULT status=PASS module=core message=\"workspace and base commands available\""
    exit 0
    ;;
  describe)
    echo "Core workspace and base command check."
    exit 0
    ;;
  *)
    echo "usage: $0 detect|run|describe"
    exit 40
    ;;
esac
```

---

## 11. Minimal skeleton module

Save as:

```text
/workspace/tests/smoke.d/10-skeleton.smoke.sh
```

```bash
#!/usr/bin/env bash
set -u

cmd="${1:-}"
phase="${2:-current-state}"
report_dir="${3:-/tmp}"
ROOT="${WORKSPACE_ROOT:-/workspace}"
BATCH="${BATCH_SLUG:-}"
EVIDENCE_ROOT="/mnt/egress/dev-recordings/skeleton"

case "$cmd" in
  detect)
    if [ -d "$ROOT" ] && { [ -d "$ROOT/nca_art_grn" ] || [ -d "$ROOT/src" ] || [ -d "$EVIDENCE_ROOT" ]; }; then
      exit 0
    fi
    exit 10
    ;;
  run)
    status="PASS"
    msg="skeleton checks passed"

    if [ -n "$BATCH" ]; then
      [ -f "$EVIDENCE_ROOT/$BATCH/POSTCHECK.md" ] || { status="WARN"; msg="missing POSTCHECK.md for $BATCH"; }
      [ -f "$EVIDENCE_ROOT/$BATCH/INTEGRATION_REQUEST.md" ] || { status="WARN"; msg="missing INTEGRATION_REQUEST.md for $BATCH"; }
    fi

    if command -v python >/dev/null 2>&1; then
      python - <<'PY' >/dev/null 2>&1
import sys
print(sys.version)
PY
    else
      echo "SMOKE_RESULT status=BLOCKED module=skeleton message=\"python not found\""
      exit 40
    fi

    echo "SMOKE_RESULT status=$status module=skeleton message=\"$msg\""
    [ "$status" = "PASS" ] && exit 0 || exit 20
    ;;
  describe)
    echo "Skeleton evidence and safe local import/contract check."
    exit 0
    ;;
  *)
    echo "usage: $0 detect|run|describe"
    exit 40
    ;;
esac
```

---

## 12. Minimal organ module

Save as:

```text
/workspace/tests/smoke.d/20-organs.smoke.sh
```

```bash
#!/usr/bin/env bash
set -u

cmd="${1:-}"
phase="${2:-current-state}"
report_dir="${3:-/tmp}"
ROOT="${WORKSPACE_ROOT:-/workspace}"
BATCH="${BATCH_SLUG:-}"
EVIDENCE_ROOT="/mnt/egress/organs/dev-recordings/organs"

case "$cmd" in
  detect)
    if [ -d "$EVIDENCE_ROOT" ] || find "$ROOT" -maxdepth 4 -iname '*organ*' 2>/dev/null | head -n 1 | grep -q .; then
      exit 0
    fi
    exit 10
    ;;
  run)
    status="PASS"
    msg="organ dry-run evidence checks passed"

    if [ -n "$BATCH" ]; then
      [ -f "$EVIDENCE_ROOT/$BATCH/POSTCHECK.md" ] || { status="WARN"; msg="missing organ POSTCHECK.md for $BATCH"; }
      [ -f "$EVIDENCE_ROOT/$BATCH/INTEGRATION_REQUEST.md" ] || { status="WARN"; msg="missing organ INTEGRATION_REQUEST.md for $BATCH"; }
    fi

    echo "SMOKE_RESULT status=$status module=organs message=\"$msg\""
    [ "$status" = "PASS" ] && exit 0 || exit 20
    ;;
  describe)
    echo "Organ evidence and dry-run contract check. Never runs live organs."
    exit 0
    ;;
  *)
    echo "usage: $0 detect|run|describe"
    exit 40
    ;;
esac
```

---

## 13. Minimal Kubernetes module

Save as:

```text
/workspace/tests/smoke.d/40-kubernetes.smoke.sh
```

```bash
#!/usr/bin/env bash
set -u

cmd="${1:-}"
phase="${2:-current-state}"
report_dir="${3:-/tmp}"
ROOT="${WORKSPACE_ROOT:-/workspace}"

case "$cmd" in
  detect)
    [ -d "$ROOT/k8s" ] || [ -d "$ROOT/charts" ] || find "$ROOT" -maxdepth 4 -name '*.yaml' 2>/dev/null | grep -q 'k8s\|kubernetes\|helm' || exit 10
    exit 0
    ;;
  run)
    if command -v helm >/dev/null 2>&1 && [ -d "$ROOT/charts" ]; then
      find "$ROOT/charts" -maxdepth 2 -name Chart.yaml -print | while read -r chart; do
        chart_dir="$(dirname "$chart")"
        helm template smoke "$chart_dir" >/dev/null || exit 30
      done
    fi

    if command -v kubectl >/dev/null 2>&1 && [ -d "$ROOT/k8s" ]; then
      find "$ROOT/k8s" -type f \( -name '*.yaml' -o -name '*.yml' \) -print | while read -r f; do
        kubectl apply --dry-run=client -f "$f" >/dev/null || exit 30
      done
    fi

    echo "SMOKE_RESULT status=PASS module=kubernetes message=\"kubernetes manifests passed local dry-run/template checks where tools were available\""
    exit 0
    ;;
  describe)
    echo "Kubernetes local dry-run/template check. Never applies manifests."
    exit 0
    ;;
  *)
    echo "usage: $0 detect|run|describe"
    exit 40
    ;;
esac
```

---

## 14. Minimal Terraform module

Save as:

```text
/workspace/tests/smoke.d/50-terraform.smoke.sh
```

```bash
#!/usr/bin/env bash
set -u

cmd="${1:-}"
phase="${2:-current-state}"
report_dir="${3:-/tmp}"
ROOT="${WORKSPACE_ROOT:-/workspace}"

case "$cmd" in
  detect)
    find "$ROOT" -maxdepth 5 -name '*.tf' 2>/dev/null | head -n 1 | grep -q . || exit 10
    exit 0
    ;;
  run)
    command -v terraform >/dev/null 2>&1 || {
      echo "SMOKE_RESULT status=WARN module=terraform message=\"terraform files exist but terraform command is not installed\""
      exit 20
    }

    find "$ROOT" -type f -name '*.tf' -printf '%h\n' 2>/dev/null | sort -u | while read -r dir; do
      (cd "$dir" && terraform fmt -check -recursive >/dev/null) || exit 30
      if [ -d "$dir/.terraform" ]; then
        (cd "$dir" && terraform validate >/dev/null) || exit 30
      fi
    done

    echo "SMOKE_RESULT status=PASS module=terraform message=\"terraform fmt passed; validate run only where initialized\""
    exit 0
    ;;
  describe)
    echo "Terraform fmt/validate check. Never runs apply."
    exit 0
    ;;
  *)
    echo "usage: $0 detect|run|describe"
    exit 40
    ;;
esac
```

---

## 15. Minimal GRN module

Save as:

```text
/workspace/tests/smoke.d/80-grn.smoke.sh
```

```bash
#!/usr/bin/env bash
set -u

cmd="${1:-}"
phase="${2:-current-state}"
report_dir="${3:-/tmp}"
ROOT="${WORKSPACE_ROOT:-/workspace}"

case "$cmd" in
  detect)
    find "$ROOT" -maxdepth 6 \( -iname '*grn*' -o -iname '*gene*' \) 2>/dev/null | head -n 1 | grep -q . || exit 10
    exit 0
    ;;
  run)
    command -v python >/dev/null 2>&1 || {
      echo "SMOKE_RESULT status=BLOCKED module=grn message=\"python not found\""
      exit 40
    }

    python - <<'PY'
import json
payload = {"smoke": "grn", "status": "import-placeholder-ok"}
print(json.dumps(payload))
PY

    echo "SMOKE_RESULT status=PASS module=grn message=\"GRN placeholder/import-level smoke passed; replace with project-specific DSL/simulator smoke when available\""
    exit 0
    ;;
  describe)
    echo "GRN local parse/import/tiny deterministic dry-run check."
    exit 0
    ;;
  *)
    echo "usage: $0 detect|run|describe"
    exit 40
    ;;
esac
```

---

## 16. How future batches extend the smoke system

Every future skeleton, organ, platform, or config integration batch that adds a new testable domain should create or update exactly one smoke module under:

```text
/workspace/tests/smoke.d/<domain>.smoke.sh
```

The batch should also write its evidence into:

```text
/mnt/egress/dev-recordings/skeleton/<batch-slug>/INTEGRATION_REQUEST.md
/mnt/egress/organs/dev-recordings/organs/<batch-slug>/INTEGRATION_REQUEST.md
```

The `INTEGRATION_REQUEST.md` should include:

| Field | Meaning |
|---|---|
| Smoke module path | The module created or updated by the batch. |
| Smoke phase | Which phase should run it. |
| Safe command | The exact command the smoke module runs. |
| Expected output | Files or status it should produce. |
| Forbidden actions | Live/deploy/apply/spend/mutate actions it must not run. |

---

## 17. Prompt to Codex when adding a smoke module

Use this as the short Codex instruction. Do not paste the whole smoke spec unless Codex lacks access to it.

```text
Read /workspace/docs/IDEMPOTENT_SMOKETEST.md.
Create or update the smoke module for this batch under /workspace/tests/smoke.d/.
The module must implement detect and run.
It must be idempotent, local-first, non-destructive, and phase-aware.
It must not deploy, apply, mutate live infrastructure, start live organs, spend external credits, or edit config.
After updating the module, run:

BATCH_SLUG="<batch-slug>" bash /workspace/scripts/smoke_current_state.sh <phase>

Write the resulting SMOKE_REPORT.md path into the batch POSTCHECK.md.
```

---

## 18. PASS/WARN/FAIL interpretation

| Overall | Meaning | Next action |
|---|---|---|
| PASS | All applicable checks passed. | Continue. |
| WARN | Something optional or not-yet-ready is missing. | Continue only if expected and documented. |
| FAIL | A required safe check failed. | Fix before next batch. |
| BLOCKED | Required file, tool, permission, or evidence is missing. | Provide/fix the missing item; do not guess. |

---

## 19. Important correction

The smoke test is dynamic. It should consume platform-specific smoke modules, not hard-code only skeleton or organ checks.

Correct model:

```text
IDEMPOTENT_SMOKETEST.md
-> defines the smoke module protocol

/workspace/tests/smoke.d/*.smoke.sh
-> contains current platform/domain checks

/workspace/scripts/smoke_current_state.sh
-> discovers and runs applicable modules

/workspace/runs/smoke/.../SMOKE_REPORT.md
-> records state-specific result
```

