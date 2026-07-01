# New Chat Handoff — Batch-by-Batch `smoke.d` Module Creation

Purpose: use this file to continue creating or repairing individual dynamic smoke-test modules in a new ChatGPT chat.

You will provide the new chat with the most current codebase analysis for `/workspace`, the relevant skeleton/organ plan files, and batch evidence. The new chat should then help create **one small safe smoke module update at a time**.

---

## 1. Current agreed model

The smoke system is dynamic.

```text
/workspace/docs/IDEMPOTENT_SMOKETEST_DYNAMIC.md
    Defines the smoke-test contract and module protocol.

/workspace/docs/CREATE_SMOKE_MODULE_CODEX.md
    Tells Codex how to create a new smoke module safely.

/workspace/docs/REPAIR_SMOKE_MODULE_CODEX.md
    Tells Codex how to repair an existing smoke module safely.

/workspace/scripts/smoke_current_state.sh
    Dynamic smoke orchestrator. Discovers and runs modules.

/home/vmuser/.local/bin/smoke
    Optional PATH wrapper around /workspace/scripts/smoke_current_state.sh.

/workspace/tests/smoke.d/*.smoke.sh
    Domain-specific idempotent smoke modules.

/workspace/runs/smoke/<timestamp-phase>/SMOKE_REPORT.md
    Output report from each smoke run.
```

The command surface should be:

```bash
smoke current-state
BATCH_SLUG="01-runtime-substrate" smoke skeleton-progress
smoke skeleton-complete
BATCH_SLUG="R01-real-organ-foundation" smoke organ-progress
smoke organ-complete
smoke pre-config
smoke post-config
```

If the `smoke` wrapper is not available, use:

```bash
bash /workspace/scripts/smoke_current_state.sh current-state
BATCH_SLUG="01-runtime-substrate" bash /workspace/scripts/smoke_current_state.sh skeleton-progress
```

---

## 2. What to provide to the new ChatGPT chat

Upload or paste these files/context into the new chat.

### Always provide

| File/context | Why |
|---|---|
| Current `/workspace` codebase analysis output | Lets ChatGPT see current project layout, packages, CLIs, tests, scripts, and smoke modules. |
| `/workspace/docs/IDEMPOTENT_SMOKETEST_DYNAMIC.md` | Defines the module contract and allowed behavior. |
| `/workspace/docs/CREATE_SMOKE_MODULE_CODEX.md` | Used when creating a new module. |
| `/workspace/docs/REPAIR_SMOKE_MODULE_CODEX.md` | Used when repairing/updating an existing module. |
| Current list/content summary of `/workspace/tests/smoke.d/` | Prevents duplicate smoke modules and helps update the right one. |
| Current `smoke_current_state.sh` or codebase snippet showing it | Ensures module interface matches the orchestrator. |

### For a skeleton batch

| File/context | Required? | Path pattern |
|---|---:|---|
| Skeleton batch `POSTCHECK.md` | yes | `/mnt/egress/dev-recordings/skeleton/<batch-slug>/POSTCHECK.md` |
| Skeleton batch `INTEGRATION_REQUEST.md` | yes | `/mnt/egress/dev-recordings/skeleton/<batch-slug>/INTEGRATION_REQUEST.md` |
| Skeleton batch `SPEC.md` | recommended | from generated batch zip or batch folder |
| Skeleton batch `RUN_INSTRUCTIONS.md` | recommended | from generated batch zip or batch folder |
| Existing skeleton companion or contract summary | recommended | `/mnt/ingress/infra/skeleton/companion/<batch-slug>/COMPANION.md` or latest relevant companion |
| Latest smoke report after prior batch | recommended | `/workspace/runs/smoke/.../SMOKE_REPORT.md` |

### For an organ batch

| File/context | Required? | Path pattern |
|---|---:|---|
| Organ batch `POSTCHECK.md` | yes | `/mnt/egress/organs/dev-recordings/organs/<batch-slug>/POSTCHECK.md` |
| Organ batch `INTEGRATION_REQUEST.md` | yes | `/mnt/egress/organs/dev-recordings/organs/<batch-slug>/INTEGRATION_REQUEST.md` |
| Organ batch `SPEC.md` | recommended | from generated batch zip or batch folder |
| Organ batch `RUN_INSTRUCTIONS.md` | recommended | from generated batch zip or batch folder |
| Relevant skeleton contract summary | yes | latest skeleton companion/contract that organ must preserve |
| Existing organ companion | recommended | `/mnt/ingress/infra/organs/companion/<batch-slug>/COMPANION.md` or latest relevant companion |
| Latest smoke report after prior batch | recommended | `/workspace/runs/smoke/.../SMOKE_REPORT.md` |

---

## 3. First message to use in the new ChatGPT chat

Copy this into the new chat after uploading the current codebase analysis and relevant plan/evidence files.

```text
We are continuing the dynamic smoke.d test creation workflow.

Goal:
Create or repair one safe idempotent smoke.d module for the next skeleton/organ batch.

Use the project model below:
- /workspace is the shared project root.
- /workspace/docs/IDEMPOTENT_SMOKETEST_DYNAMIC.md is the smoke contract.
- /workspace/docs/CREATE_SMOKE_MODULE_CODEX.md is the creation instruction doc.
- /workspace/docs/REPAIR_SMOKE_MODULE_CODEX.md is the repair instruction doc.
- /workspace/scripts/smoke_current_state.sh is the orchestrator.
- /workspace/tests/smoke.d/*.smoke.sh are the dynamic modules.
- smoke reports are written under /workspace/runs/smoke/.../SMOKE_REPORT.md.

Important rules:
- Do not create a new smoke file per batch unless the batch introduces a new domain.
- Prefer updating the smallest existing matching module.
- Smoke modules must be idempotent, local-first, non-destructive, and phase-aware.
- Smoke modules must not install packages.
- Smoke modules must not edit config.
- Smoke modules must not deploy/apply infrastructure.
- Smoke modules must not run live organs.
- Missing dependencies should return WARN or BLOCKED with exact missing paths/commands.
- The module must implement: detect and run <phase> <report_dir>.
- The module should print a final SMOKE_RESULT line.

I have uploaded/provided:
- current workspace codebase analysis
- relevant plan files
- relevant POSTCHECK.md / INTEGRATION_REQUEST.md evidence
- current smoke.d state if available

Please inspect the evidence and tell me:
1. Which smoke module should be created or updated.
2. Why that module is the right target.
3. The exact Codex prompt to run for this batch.
4. The exact command to run after Codex updates the module.
5. What files Codex is allowed to create/update.
6. What files Codex must not create/update.

Use the Field | Exact content style where useful.
Do not invent missing evidence. If required files are missing, list the exact missing paths.
```

---

## 4. Batch-by-batch workflow

Use this loop for every batch.

| Step | Owner | Action |
|---|---|---|
| 1 | You | Upload current codebase analysis + batch evidence to ChatGPT. |
| 2 | ChatGPT | Decide which `smoke.d` module should be created/updated. |
| 3 | ChatGPT | Produce a short Codex prompt naming exact files to read. |
| 4 | Codex | Read named files only; create/update one module. |
| 5 | Codex | Run `smoke` for the correct phase and batch slug. |
| 6 | Codex | Update the batch `POSTCHECK.md` with smoke result path and status. |
| 7 | You | Review PASS/WARN/FAIL/BLOCKED. |
| 8 | If needed | Use `REPAIR_SMOKE_MODULE_CODEX.md` to fix only the failing module. |

---

## 5. Module selection rule

Do not create one smoke module per batch by default. Select by domain.

| Batch/domain change | Prefer module |
|---|---|
| Project root, basic folder, Python availability | `/workspace/tests/smoke.d/00-core.smoke.sh` |
| Skeleton CLI/output contract/evidence | `/workspace/tests/smoke.d/10-skeleton.smoke.sh` |
| Organ dry-run/output contract/evidence | `/workspace/tests/smoke.d/20-organs.smoke.sh` |
| Config/lv/operator wrapper/status checks | `/workspace/tests/smoke.d/30-config.smoke.sh` |
| Kubernetes manifests, Helm charts | `/workspace/tests/smoke.d/40-kubernetes.smoke.sh` |
| Terraform modules/plans | `/workspace/tests/smoke.d/50-terraform.smoke.sh` |
| AgentField planning/modules/configs | `/workspace/tests/smoke.d/60-agentfield.smoke.sh` |
| RunPod templates/scripts/payloads | `/workspace/tests/smoke.d/70-runpod.smoke.sh` |
| GRN DSL/simulator/science dry-run | `/workspace/tests/smoke.d/80-grn.smoke.sh` |
| New isolated future domain | `/workspace/tests/smoke.d/<NN>-<domain>.smoke.sh` |

---

## 6. Skeleton batch Codex prompt template

Replace `<batch-slug>` and module path after ChatGPT decides the correct module.

```text
Read these files:

/workspace/docs/IDEMPOTENT_SMOKETEST_DYNAMIC.md
/workspace/docs/CREATE_SMOKE_MODULE_CODEX.md
/workspace/scripts/smoke_current_state.sh
/workspace/tests/smoke.d/
/mnt/egress/dev-recordings/skeleton/<batch-slug>/POSTCHECK.md
/mnt/egress/dev-recordings/skeleton/<batch-slug>/INTEGRATION_REQUEST.md

Also inspect the current project code under:

/workspace

Create or update the smallest safe idempotent smoke module for skeleton batch <batch-slug>.

Target module:
/workspace/tests/smoke.d/<chosen-module>.smoke.sh

Rules:
- implement or preserve detect and run
- keep the module phase-aware
- run safe local checks only
- do not edit config
- do not run real organs
- do not deploy/apply infrastructure
- do not install packages
- do not delete prior smoke reports
- if required evidence or commands are missing, return WARN or BLOCKED with exact missing paths
- preserve compatibility with /workspace/scripts/smoke_current_state.sh

After updating the module, run:

BATCH_SLUG="<batch-slug>" smoke skeleton-progress

If the smoke wrapper is unavailable, run:

BATCH_SLUG="<batch-slug>" bash /workspace/scripts/smoke_current_state.sh skeleton-progress

Then update:

/mnt/egress/dev-recordings/skeleton/<batch-slug>/POSTCHECK.md

with:
- smoke module path
- command run
- SMOKE_REPORT.md path
- PASS/WARN/FAIL/BLOCKED result
- any missing files or follow-up fixes

Output:
Changed files:
Tests run:
Smoke report:
Notes:
```

---

## 7. Organ batch Codex prompt template

Replace `<batch-slug>` and module path after ChatGPT decides the correct module.

```text
Read these files:

/workspace/docs/IDEMPOTENT_SMOKETEST_DYNAMIC.md
/workspace/docs/CREATE_SMOKE_MODULE_CODEX.md
/workspace/scripts/smoke_current_state.sh
/workspace/tests/smoke.d/
/mnt/egress/organs/dev-recordings/organs/<batch-slug>/POSTCHECK.md
/mnt/egress/organs/dev-recordings/organs/<batch-slug>/INTEGRATION_REQUEST.md

Also inspect the current project code under:

/workspace

Also read the relevant skeleton contract or companion summary if available:

/mnt/ingress/infra/skeleton/companion/<relevant-skeleton-slug>/COMPANION.md

Create or update the smallest safe idempotent smoke module for organ batch <batch-slug>.

Target module:
/workspace/tests/smoke.d/<chosen-module>.smoke.sh

Rules:
- implement or preserve detect and run
- keep the module phase-aware
- preserve skeleton output contracts
- use dry-run/local checks only
- do not run live organs
- do not edit config
- do not deploy/apply infrastructure
- do not install packages
- do not delete prior smoke reports
- if required evidence or commands are missing, return WARN or BLOCKED with exact missing paths
- preserve compatibility with /workspace/scripts/smoke_current_state.sh

After updating the module, run:

BATCH_SLUG="<batch-slug>" smoke organ-progress

If the smoke wrapper is unavailable, run:

BATCH_SLUG="<batch-slug>" bash /workspace/scripts/smoke_current_state.sh organ-progress

Then update:

/mnt/egress/organs/dev-recordings/organs/<batch-slug>/POSTCHECK.md

with:
- smoke module path
- command run
- SMOKE_REPORT.md path
- PASS/WARN/FAIL/BLOCKED result
- any missing files or follow-up fixes

Output:
Changed files:
Tests run:
Smoke report:
Notes:
```

---

## 8. Repair prompt template

Use this when a smoke module already exists but failed or gave an unexpected warning.

```text
Read these files:

/workspace/docs/IDEMPOTENT_SMOKETEST_DYNAMIC.md
/workspace/docs/REPAIR_SMOKE_MODULE_CODEX.md
/workspace/scripts/smoke_current_state.sh
/workspace/tests/smoke.d/<failing-module>.smoke.sh
<path-to-latest-SMOKE_REPORT.md>
<path-to-raw-stdout-log-if-needed>
<path-to-raw-stderr-log-if-needed>
<batch-POSTCHECK.md>
<batch-INTEGRATION_REQUEST.md>

Repair only this smoke module:

/workspace/tests/smoke.d/<failing-module>.smoke.sh

Rules:
- do not rewrite unrelated modules
- do not weaken real failures into PASS
- only convert to WARN/SKIP if the domain is genuinely optional or not applicable for the phase
- do not install packages
- do not edit config
- do not run live/deploy/apply actions
- keep detect/run contract compatible with smoke_current_state.sh

After repair, rerun:

BATCH_SLUG="<batch-slug>" smoke <phase>

Then update the batch POSTCHECK.md with the new SMOKE_REPORT.md path and result.

Output:
Changed files:
Tests run:
Smoke report:
Notes:
```

---

## 9. Phase and command cheat sheet

| Situation | Command |
|---|---|
| After a skeleton batch | `BATCH_SLUG="<batch-slug>" smoke skeleton-progress` |
| After all skeleton batches | `smoke skeleton-complete` |
| After an organ batch | `BATCH_SLUG="<batch-slug>" smoke organ-progress` |
| After all organ batches | `smoke organ-complete` |
| Before config integration | `smoke pre-config` |
| After config integration | `smoke post-config` |
| Anytime current-state check | `smoke current-state` |

Fallback form:

```bash
BATCH_SLUG="<batch-slug>" bash /workspace/scripts/smoke_current_state.sh <phase>
```

---

## 10. Required result interpretation

| Result | Meaning | Action |
|---|---|---|
| PASS | Required applicable checks passed. | Continue. |
| WARN | Optional/not-yet-complete readiness issue. | Continue only if expected and documented in POSTCHECK. |
| FAIL | Required safe check failed. | Fix before next batch. |
| BLOCKED | Required file, permission, tool, or evidence missing. | Provide/fix exact missing item; do not guess. |
| SKIP | Domain not present or not applicable. | OK if expected for phase. |

---

## 11. What Codex may and must not do

### Codex may create/update

| Path | Purpose |
|---|---|
| `/workspace/tests/smoke.d/*.smoke.sh` | Smoke modules only. |
| `/workspace/runs/smoke/.../SMOKE_REPORT.md` | Smoke reports generated by orchestrator. |
| `/workspace/runs/smoke/.../raw/*` | Raw stdout/stderr logs. |
| Batch `POSTCHECK.md` | Append smoke result/path/status. |

### Codex must not create/update during batch smoke module work

| Path/action | Reason |
|---|---|
| `/workspace/docs/IDEMPOTENT_SMOKETEST_DYNAMIC.md` | ChatGPT/operator-authored spec. Treat as read-only. |
| `/workspace/docs/CREATE_SMOKE_MODULE_CODEX.md` | ChatGPT/operator-authored instruction. Treat as read-only. |
| `/workspace/docs/REPAIR_SMOKE_MODULE_CODEX.md` | ChatGPT/operator-authored instruction. Treat as read-only. |
| Config/lv/workflow files | Only config-integration batches may edit these. |
| Live organ execution | Forbidden in smoke. |
| `terraform apply`, `kubectl apply`, live RunPod creation | Forbidden in smoke. |
| Package installation | Smoke modules report missing dependencies; they do not install. |
| Deleting old reports | Reports are historical evidence. |

---

## 12. Final canonical roots

```text
Shared project workspace:
/workspace

Skeleton evidence:
/mnt/egress/dev-recordings/skeleton/<batch-slug>/

Organ evidence:
/mnt/egress/organs/dev-recordings/organs/<batch-slug>/

Skeleton companions:
/mnt/ingress/infra/skeleton/companion/<batch-slug>/COMPANION.md

Organ companions:
/mnt/ingress/infra/organs/companion/<batch-slug>/COMPANION.md
```

---

## 13. What the new chat should output before Codex runs

Ask the new chat to output this table for each batch.

```text
Batch:
Phase:
Chosen smoke module:
Reason:
Files to provide to Codex:
Files Codex may update:
Files Codex must not update:
Exact Codex prompt:
Exact smoke command:
Expected PASS/WARN/BLOCKED behavior:
```

