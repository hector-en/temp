# Companion — 01 Runtime Substrate and Remote Model Dummy Client

Canonical intended path: `/mnt/ingress/infra/skeleton/companion/skeleton/01-runtime-substrate/COMPANION.md`

Generation note: the canonical ingress companion tree was not writable in this sandbox, so this file was generated as a downloadable artifact instead. No canonical companion file was modified here.

## 1. Short run overview

Batch 01 was supposed to build the first runtime substrate slice: generic `/workspace` roots, runtime layout and policy markers, safe local readiness checks, and a thin offline remote-model dummy client/router contract.

The checked implementation evidence says Codex actually created the runtime contracts under `/workspace/runtime`, runtime check scripts under `/workspace/scripts/runtime_checks`, and the dummy `research-assistant` contract under `/workspace/repos/research-assistant`.

The Batch 01 implementation postcheck status is `PASS`. The later dynamic smoke reports for `BATCH_SLUG="01-runtime-substrate"` have overall status `WARN`, not because the core runtime failed, but because optional host/provider readiness was incomplete: Docker, Terraform, and Runpod were absent; endpoint environment variables were not fully configured; and OpenCode config paths were absent.

The checked state is therefore:

```text
implementation: PASS
dynamic smoke: WARN
core runtime contract: PASS
research-assistant offline helper: WARN at smoke level, but helper itself passed offline
config integration: deferred
```

Important gap: the companion could not be written to the canonical ingress path from this runtime because `/mnt/ingress/infra/skeleton/companion` was not writable here. The generated Markdown content is provided as an artifact instead.

## 2. How this fits into the skeleton

Batch 01 sits in:

```text
Layer 1 — Runtime substrate
Bundle 1 — Runpod portable runtime base
Bundle 7 — Remote model brain endpoint
Master order range: 1-14
Batch slug: 01-runtime-substrate
```

It is the foundation batch. It prepares shared runtime layout and local readiness checks before later batches create research, Agentfield, Paperclip, OpenClaw, PKM, or publishing-specific workspaces.

The upstream dependency is only a usable `/workspace` tree. Downstream batches can rely on these roots:

```text
/workspace/repos
/workspace/envs
/workspace/data
/workspace/runs
/workspace/artifacts
/workspace/models
/workspace/checkpoints
/workspace/logs
```

The implementation intentionally did not create `/workspace/repos/nca-art-grn`. That remains a later Batch 02 responsibility.

## 3. Files and folders created or changed

### `/workspace/runtime/README.md`

Purpose: identifies `/workspace/runtime` as the home for Batch 01 runtime substrate marker and policy files.

Why it exists: gives future developers a short warning that this layer is skeleton-first and non-live.

Main content: states that these files do not launch Docker, Terraform, Kubernetes, Runpod, or model providers, and that project-specific namespaces are created by later batches.

Future transition: later runtime batches may replace marker text with richer runtime policy metadata, but should keep the boundary that checks do not launch jobs by default.

### `/workspace/runtime/volume_layout.md`

Purpose: records the generic workspace volume layout.

Why it exists: makes the storage root contract explicit before project-specific repos and artifacts appear.

Main content: documents responsibilities for repos, envs, data, runs, artifacts, models, checkpoints, and logs.

Consumer: `10-core-layout.smoke.sh` checks that this file exists when Batch 01 is active.

Future transition: can be extended with free-space, mount, and persistence expectations, but not converted into a live setup script.

### `/workspace/runtime/docker_policy.yaml`

Purpose: Docker runtime policy marker.

Why it exists: defines that Batch 01 has no live Docker execution.

Main content: marks Docker live execution disabled, states that images and persistent volumes are later operator-side concerns, and says secrets must not live in images, Dockerfiles, or committed runtime markers.

Consumer: smoke checks expect this file as part of the Batch 01 runtime contract.

Future transition: may become a real Docker/Runpod container readiness policy, but image pulls/builds must remain explicit.

### `/workspace/runtime/compute_profiles.yaml`

Purpose: placeholder compute-profile source.

Why it exists: gives later orchestration layers a stable place to look for local, Runpod, serverless, and Kubernetes execution profile names.

Main content: profiles for `local`, `runpod-pod`, `runpod-serverless`, and `kubernetes-dev`, all marked offline or placeholder.

Future transition: later batches can attach real profile fields such as GPU type, queue policy, cost policy, or endpoint target.

### `/workspace/runtime/terraform_policy.yaml`

Purpose: Terraform policy marker.

Why it exists: records that Batch 01 only documents inspection behavior.

Main content: allowed actions are file inspection and intent documentation; forbidden actions include `terraform init`, `terraform plan`, and `terraform apply`.

Future transition: real Terraform validation, if needed, should still avoid `apply` by default.

### `/workspace/scripts/runtime_checks/check_runpod_workspace.py`

Purpose: non-mutating workspace readiness check.

Why it exists: verifies that core runtime roots exist and are readable/writable where permissions allow.

Main functions:
- `describe(path)`: returns path, existence, owner UID, mode, readable, and writable status.
- `main()`: emits JSON containing root statuses and optional `/runpod-volume` marker presence.

Reads: filesystem metadata for Batch 01 generic roots.

Writes: stdout JSON only.

Future transition: can add free-space, mount type, and Runpod pod detection, but should not create experiments.

### `/workspace/scripts/runtime_checks/check_gpu_runtime.py`

Purpose: safe GPU presence check.

Why it exists: lets the operator inspect whether `nvidia-smi` is visible without making GPU work mandatory.

Behavior:
- If `nvidia-smi` is missing, returns JSON with `status: unavailable`.
- If present, runs `nvidia-smi --query-gpu=name --format=csv,noheader`.

Writes: stdout JSON only.

Future transition: can add richer GPU metadata, but should remain non-mutating.

### `/workspace/scripts/runtime_checks/check_cuda_torch_runtime.py`

Purpose: safe Torch/CUDA readiness check.

Why it exists: checks whether Torch exists without installing it.

Behavior:
- Uses `importlib.util.find_spec("torch")`.
- If Torch is absent, reports `status: unavailable`.
- If Torch is present, reports Torch version and `torch.cuda.is_available()`.

Writes: stdout JSON only.

Future transition: can add compatibility matrix checks, but should not install Torch from a check script.

### `/workspace/scripts/runtime_checks/check_docker_gpu_access.py`

Purpose: safe Docker/GPU capability inspection.

Why it exists: checks Docker command presence and static `--gpus` flag support.

Behavior:
- If Docker is absent, reports `status: unavailable`.
- If Docker exists, runs `docker run --help` and checks whether `--gpus` appears in help text.
- It does not start a container.

Future transition: a later operator/config batch may expose this as a health check.

### `/workspace/scripts/runtime_checks/check_kubernetes_context.py`

Purpose: safe Kubernetes context inspection.

Why it exists: detects whether `kubectl` exists and whether a current context is configured.

Behavior:
- If `kubectl` is absent, reports `status: unavailable`.
- If present, runs `kubectl config current-context`.
- It does not run `kubectl apply`.

Future transition: can add read-only validation, but apply/deploy stays out of this check.

### `/workspace/repos/research-assistant/README.md`

Purpose: explains the dummy remote-model contract.

Why it exists: makes clear that `research-assistant` is not the real paper-writing machine or final model integration yet.

Main content: default behavior is offline and deterministic; provider API calls are not made unless a future explicit live flag is added elsewhere; environment checks report only variable presence, never values.

Future transition: can evolve into a real local-code-to-remote-model client, but live calls must be guarded.

### `/workspace/repos/research-assistant/.env.example`

Purpose: documents expected environment variable names.

Fields:

```text
RUNPOD_API_KEY=
OPENROUTER_API_KEY=
RUNPOD_ENDPOINT_ID=
AI_MODEL=dummy-local-brain
```

It does not contain real secrets.

### `/workspace/repos/research-assistant/requirements.txt`

Purpose: records dependency policy for the skeleton client.

Current content: standard library only.

Future transition: if a real provider client is added later, dependency changes should be recorded in the integration request or a later package/env batch.

### `/workspace/repos/research-assistant/runpod_brain_client.py`

Purpose: deterministic dummy remote brain client.

Main class:
- `RunpodBrainClient`

Main behavior:
- `live_enabled` defaults to `False`.
- `invoke(task, mode="execute")` returns dummy JSON when live mode is disabled.
- If `live_enabled` is true, it raises `RuntimeError("Live provider calls are disabled in Batch 01.")`.

Consumers:
- `brain_router.py`
- `smoke_test.py` through `brain_router`

Future transition: replace dummy response internals with a real provider call behind explicit live flags and cost/secret guardrails.

### `/workspace/repos/research-assistant/brain_router.py`

Purpose: stable routing interface over the dummy client.

Functions:
- `execute(task)`
- `analyze(task)`
- `summarize(task)`
- `triage_failure(task)`
- `rank_hypothesis(task)`
- `draft_section(task)`

All functions call the same `RunpodBrainClient` instance with a different mode.

Consumers:
- `smoke_test.py`
- future OpenClaw/Agentfield/Paperclip layers may use this interface as the stable shape for model-backed tasks.

### `/workspace/repos/research-assistant/prompts.py`

Purpose: small prompt label dictionary for the router modes.

Current behavior: defines static text for execute, analyze, summarize, triage failure, rank hypothesis, and draft section.

No evidence shows it is imported by the current dummy router. It exists as a contract placeholder.

### `/workspace/repos/research-assistant/smoke_test.py`

Purpose: repo-local helper smoke for the dummy router/client contract.

Behavior:
- Imports `brain_router`.
- Calls all six router functions with `"test-task"`.
- Prints a JSON object containing the six dummy responses.
- Returns exit code 0.

Safety: evidence says this was confirmed local/offline by inspection; it uses `RunpodBrainClient` with live behavior disabled.

### `/workspace/repos/research-assistant/check_runpod_brain_endpoint.py`

Purpose: environment readiness check for future remote model endpoint configuration.

Behavior:
- Reports boolean presence for `RUNPOD_API_KEY`, `OPENROUTER_API_KEY`, `RUNPOD_ENDPOINT_ID`, and `AI_MODEL`.
- Does not print variable values.
- Does not call a remote endpoint.

Future transition: a live endpoint health check should be separate and explicitly guarded.

### `/workspace/repos/research-assistant/check_opencode_remote_model_config.py`

Purpose: non-overwriting local editor/model-alias config check.

Behavior:
- Checks candidate config paths `/home/vmuser/.config/opencode` and `/home/vmuser/.config/openai`.
- Reports present/missing paths and whether `AI_MODEL` is set.
- Does not overwrite editor config.

Future transition: may be expanded once exact OpenCode config format is known.

### `/workspace/scripts/smoke.sh`

Purpose: current dynamic smoke runner.

Actual interface in checked codebase: the runner discovers executable `*.smoke.sh` scripts and executes each module directly, classifying output by first-line prefixes such as `PASS:`, `WARN:`, `SKIP:`, and `FAIL:`. This is the actual checked behavior, even though some docs describe a detect/run style module contract.

Writes: timestamped smoke reports under `/workspace/runs/smoke/<timestamp>-<phase>/SMOKE_REPORT.md`.

### `/workspace/tests/smoke.d/10-core-layout.smoke.sh`

Purpose: core layout and Batch 01 contract smoke module.

Behavior:
- Always checks base workspace and smoke docs.
- When `SMOKE_BATCH_SLUG=01-runtime-substrate` or the phase is `skeleton-complete`/`full`, it activates Batch 01 checks.
- Checks runtime root paths, runtime contract files, policy files, runtime check scripts, research-assistant contract files, and Batch 01 evidence files.
- Runs `py_compile` against existing runtime and research-assistant Python files.

Current checked result: `PASS` for core layout and Batch 01 runtime substrate contracts.

### `/workspace/tests/smoke.d/90-research-assistant.smoke.sh`

Purpose: official dynamic smoke wrapper for the `research-assistant` repo-local helper.

Behavior:
- Applies to `skeleton-progress`, `skeleton-complete`, `full`, or empty phase.
- Checks expected research-assistant files.
- Uses `PYTHONPYCACHEPREFIX=/tmp python3 -m py_compile` for Python files.
- Runs the repo-local `smoke_test.py` only after local/offline safety was verified by the smoke follow-up evidence.
- Warns when endpoint env vars are not fully configured or OpenCode config paths are absent.

Current checked result: `WARN` because optional endpoint env vars and OpenCode config paths are absent, while the offline helper itself passed.

## 4. Runtime or CLI behavior

### Runtime checks

```bash
python3 /workspace/scripts/runtime_checks/check_runpod_workspace.py
```

Reads: `/workspace/repos`, `/workspace/envs`, `/workspace/data`, `/workspace/runs`, `/workspace/artifacts`, `/workspace/models`, `/workspace/checkpoints`, `/workspace/logs`, and optional `/runpod-volume`.

Writes: stdout JSON.

Skeleton or real: skeleton readiness check.

Expected success: JSON with `status: ok` and per-root metadata.

Expected failure: no evidence of a planned failure mode in uploaded code analysis, except Python/runtime errors if paths are unexpectedly inaccessible.

```bash
python3 /workspace/scripts/runtime_checks/check_gpu_runtime.py
```

Reads: command availability for `nvidia-smi`.

Writes: stdout JSON.

Skeleton or real: safe skeleton host check.

Expected success: either unavailable JSON if `nvidia-smi` is missing or GPU detection JSON if present.

Expected failure: no live workload is launched.

```bash
python3 /workspace/scripts/runtime_checks/check_cuda_torch_runtime.py
```

Reads: Python import availability for `torch`.

Writes: stdout JSON.

Skeleton or real: safe skeleton host check.

Expected success: unavailable JSON if Torch is absent, or Torch/CUDA status if present.

Expected failure: import/runtime exception only if installed Torch itself errors.

```bash
python3 /workspace/scripts/runtime_checks/check_docker_gpu_access.py
```

Reads: `docker` command availability and `docker run --help`.

Writes: stdout JSON.

Skeleton or real: safe skeleton host check.

Expected success: unavailable JSON if Docker is absent, or static GPU flag status if present.

Expected failure: no Docker container is run.

```bash
python3 /workspace/scripts/runtime_checks/check_kubernetes_context.py
```

Reads: `kubectl` command availability and current context.

Writes: stdout JSON.

Skeleton or real: safe skeleton host check.

Expected success: unavailable JSON if `kubectl` is absent, or current context presence if present.

Expected failure: no cluster mutation is performed.

### Research-assistant commands

```bash
python3 /workspace/repos/research-assistant/smoke_test.py
```

Reads: `brain_router.py`, `runpod_brain_client.py`.

Writes: dummy JSON to stdout.

Skeleton or real: skeleton dummy local/offline helper.

Expected success: JSON with six keys: `execute`, `analyze`, `summarize`, `triage_failure`, `rank_hypothesis`, and `draft_section`, each with `status: dummy`.

Expected failure: Python import failure or a future accidental live-mode change.

```bash
python3 /workspace/repos/research-assistant/check_runpod_brain_endpoint.py
```

Reads: environment variable presence only.

Writes: JSON booleans; does not print secret values.

Skeleton or real: skeleton config readiness check.

Expected success: JSON with `_set` booleans for known env names.

Expected failure: no evidence of expected nonzero failure; missing env vars are reported safely.

```bash
python3 /workspace/repos/research-assistant/check_opencode_remote_model_config.py
```

Reads: presence of two config directories and `AI_MODEL` presence.

Writes: JSON with config path presence/missing and `AI_MODEL_set`.

Skeleton or real: skeleton config-alignment check.

Expected success: JSON status even if paths are absent.

Expected failure: no evidence of expected nonzero failure.

### Dynamic smoke commands

```bash
BATCH_SLUG="01-runtime-substrate" bash /workspace/scripts/smoke.sh skeleton-progress
```

Reads: smoke modules under `/workspace/tests/smoke.d/*.smoke.sh`, Batch 01 evidence files, and runtime/research-assistant contracts.

Writes: `/workspace/runs/smoke/<timestamp>-skeleton-progress/SMOKE_REPORT.md`.

Skeleton or real: dynamic smoke runner.

Expected success: overall `WARN` in the current checked state, with core runtime PASS and optional environment/tool warnings.

Expected failure: FAIL if required Batch 01 artifacts disappear or Python files no longer compile.

```bash
BATCH_SLUG="01-runtime-substrate" /workspace/tests/smoke.d/90-research-assistant.smoke.sh skeleton-progress /tmp
```

Reads: research-assistant files.

Writes: smoke output to stdout; no evidence file mutation.

Skeleton or real: direct smoke module run.

Expected success: `WARN` in current checked state if optional endpoint env/OpenCode config is incomplete; would be PASS if optional config is present and all helper checks pass.

## 5. Data contracts and artifacts

### Runtime root contract

Producer: Batch 01 implementation.

Consumer: later skeleton batches, smoke modules, operator/config integration.

Required fields/files:
- `/workspace/repos`
- `/workspace/envs`
- `/workspace/data`
- `/workspace/runs`
- `/workspace/artifacts`
- `/workspace/models`
- `/workspace/checkpoints`
- `/workspace/logs`

Dummy fields: none; these are real directories but generic.

Real-organ replacement expectations: later batches add project namespaces under these roots, not inside Batch 01.

### Runtime policy artifacts

Producer: Batch 01 implementation.

Consumer: developers, smoke, future operator/config pass.

Files:
- `/workspace/runtime/volume_layout.md`
- `/workspace/runtime/docker_policy.yaml`
- `/workspace/runtime/compute_profiles.yaml`
- `/workspace/runtime/terraform_policy.yaml`

Required fields: policy names, skeleton/non-live mode, and forbidden live actions where applicable.

Dummy fields: compute profiles are placeholders.

Real-organ replacement expectations: profiles and policies can become richer but should preserve default non-live behavior.

### Runtime readiness JSON

Producer:
- `check_runpod_workspace.py`
- `check_gpu_runtime.py`
- `check_cuda_torch_runtime.py`
- `check_docker_gpu_access.py`
- `check_kubernetes_context.py`

Consumer: humans now; later config health checks or launchers.

Required fields: not formally schema-versioned yet. Current outputs are JSON dictionaries with `status` or path metadata.

Dummy fields: unavailable statuses are expected on local hosts without optional tools.

Real-organ replacement expectations: convert to stable schemas if operator/config health checks begin parsing them.

### Remote model dummy response

Producer: `RunpodBrainClient.invoke`.

Consumer: `brain_router.py` and `smoke_test.py`.

Required fields currently returned:
- `status`
- `mode`
- `task`
- `response`

Dummy fields:
- `status: dummy`
- `response: dummy-<mode>-response`

Real-organ replacement expectations: later live client should keep a stable response envelope or version the contract.

### Endpoint readiness JSON

Producer: `check_runpod_brain_endpoint.py`.

Consumer: humans and future config checks.

Required fields:
- `RUNPOD_API_KEY_set`
- `OPENROUTER_API_KEY_set`
- `RUNPOD_ENDPOINT_ID_set`
- `AI_MODEL_set`

Dummy fields: booleans only; no secret values.

Real-organ replacement expectations: live endpoint health should be separate and guarded.

### Smoke reports

Producer: `/workspace/scripts/smoke.sh`.

Consumer: operator, companion generator, future batch prompts.

Checked reports:
- `/workspace/runs/smoke/20260626T191556Z-skeleton-progress/SMOKE_REPORT.md`
- `/workspace/runs/smoke/20260626T193435Z-skeleton-progress/SMOKE_REPORT.md`

Current overall status: `WARN`.

Known WARN causes:
- missing optional Docker/Terraform/Runpod tools
- endpoint env vars not fully configured
- OpenCode config paths absent

### Postcheck evidence

Producer: Batch 01 implementation run.

File:
- `/mnt/egress/dev-recordings/skeleton/01-runtime-substrate/POSTCHECK.md`

Checked status: `PASS`.

Consumer: smoke modules, companion generator, later config integration planning.

### Integration request evidence

Producer: Batch 01 implementation run.

File:
- `/mnt/egress/dev-recordings/skeleton/01-runtime-substrate/INTEGRATION_REQUEST.md`

Purpose: later operator/config handoff only.

Status: config integration deferred.

## 6. Developer walkthrough

Suggested reading order:

```text
1. Start at /workspace/runtime/volume_layout.md
2. Read /workspace/runtime/docker_policy.yaml
3. Read /workspace/runtime/compute_profiles.yaml
4. Read /workspace/runtime/terraform_policy.yaml
5. Read /workspace/scripts/runtime_checks/check_runpod_workspace.py
6. Read the remaining runtime check scripts in /workspace/scripts/runtime_checks/
7. Read /workspace/repos/research-assistant/README.md
8. Read /workspace/repos/research-assistant/runpod_brain_client.py
9. Read /workspace/repos/research-assistant/brain_router.py
10. Run python3 /workspace/repos/research-assistant/smoke_test.py
11. Read /workspace/scripts/smoke.sh
12. Read /workspace/tests/smoke.d/10-core-layout.smoke.sh
13. Read /workspace/tests/smoke.d/90-research-assistant.smoke.sh
14. Run BATCH_SLUG="01-runtime-substrate" bash /workspace/scripts/smoke.sh skeleton-progress
15. Inspect the generated SMOKE_REPORT.md
```

The fastest way to understand the dummy model path is:

```text
runpod_brain_client.py
-> brain_router.py
-> smoke_test.py
-> 90-research-assistant.smoke.sh
```

The fastest way to understand the runtime substrate path is:

```text
volume_layout.md
-> runtime policy YAML files
-> runtime_checks/*.py
-> 10-core-layout.smoke.sh
```

## 7. Important design decisions

Batch 01 stays generic. It creates `/workspace` storage roots but does not create NCA-ART-GRN, Agentfield, Paperclip, OpenClaw, PKM, or LaTeX project namespaces.

The remote model client is deliberately offline by default. `live_enabled=True` raises an error instead of making a provider call. This keeps later model integration from accidentally spending money or leaking credentials.

Endpoint checks report only whether env vars are set, not their values. This preserves a useful readiness signal without exposing secrets.

Smoke is domain-based, not one smoke module per batch. In the checked state, core runtime layout belongs to `10-core-layout.smoke.sh`; optional host tool presence belongs to `60-infra-tools.smoke.sh`; the remote-model dummy client has an official wrapper in `90-research-assistant.smoke.sh`.

The checked smoke runner uses simple script output prefixes, not the detect/run interface described in some smoke documentation. Companion readers should trust the actual runner and module files for current behavior.

`PYTHONPYCACHEPREFIX=/tmp` is used in smoke follow-up evidence because the checked environment may not allow writing `__pycache__` under `/workspace`.

## 8. Safety and boundaries

Do not edit config internals from this batch or companion:

```text
/home/vmuser/.local/bin/config.sh
/home/vmuser/.local/lib/config-sh/installers.sh
/home/vmuser/.local/etc/config-sh
```

Do not run broad bootstrap, install, mount, pull, push, account mutation, Docker build, Kubernetes apply, Terraform init/plan/apply, Runpod jobs, OpenClaw agents, training, inference, Agentfield server runs, Paperclip writes, or live model/provider calls from this skeleton state.

Do not print secrets, private notes, vault contents, datasets, API keys, or manuscript text.

Do not create `/workspace/repos/nca-art-grn` as part of Batch 01.

Do not treat optional readiness WARNs as proof of failure. The current checked WARNs are expected skeleton-progress gaps for optional tooling and endpoint/editor configuration.

## 9. Gaps, TODOs, and transition hooks

### Gaps

- Companion output could not be written to `/mnt/ingress/infra/skeleton/companion/skeleton/01-runtime-substrate/COMPANION.md` from this sandbox because the path was not writable.
- Dynamic smoke overall status remains `WARN`.
- Docker, Terraform, and Runpod commands are absent in the checked environment.
- Endpoint env vars are not fully configured.
- OpenCode config paths are absent.
- Runtime JSON outputs are not yet formal versioned schemas.
- Some smoke documentation describes a detect/run module interface, while the actual checked runner executes simple scripts and classifies `PASS:`, `WARN:`, `SKIP:`, and `FAIL:` prefixes.

### TODOs

- Later operator/config pass can decide whether to expose runtime checks as config health checks or launchers.
- Later remote-model transition can replace dummy responses with real provider calls behind explicit live flags.
- Later smoke repair may align documentation and actual smoke module interface if desired.
- Later batches should add project namespaces under the generic roots instead of changing Batch 01.

### Transition hooks

- Runtime checks can become config health checks.
- `RunpodBrainClient.invoke` can become the live client boundary.
- `brain_router.py` is the stable interface for later OpenClaw, Agentfield, and Paperclip use.
- `compute_profiles.yaml` can grow into real local/Runpod/Kubernetes execution policy.
- `/workspace/runs/smoke/.../SMOKE_REPORT.md` is the current evidence source for checked state.

## 10. Postcheck summary

Batch 01 implementation postcheck:

```text
Date: 2026-06-26
Status: PASS
Canonical path: /mnt/egress/dev-recordings/skeleton/01-runtime-substrate/POSTCHECK.md
```

Changed implementation files include:
- runtime contract and policy files under `/workspace/runtime`
- runtime checks under `/workspace/scripts/runtime_checks`
- dummy remote-model client/router files under `/workspace/repos/research-assistant`

Tasks executed:
- Generic runtime roots and volume layout
- Safe runtime policies and readiness checks
- Remote model dummy client and brain router contract

Tests run included:
- directory existence checks for generic `/workspace` roots
- file existence checks for runtime contracts
- `python3 -m py_compile` for runtime checks and research-assistant Python files
- no-arg runtime checks
- `python3 /workspace/repos/research-assistant/smoke_test.py`
- endpoint and OpenCode config checks
- `BATCH_SLUG="01-runtime-substrate" bash /workspace/scripts/smoke.sh skeleton-progress`

Result:
- implementation postcheck: `PASS`
- existing smoke runner result at implementation time: `WARN`
- later checked smoke reports: `WARN`

Known failures:
- none recorded in the Batch 01 implementation postcheck.

Known warnings:
- optional Docker/Terraform/Runpod tools absent
- endpoint env vars incomplete
- OpenCode config paths absent

Next recommended batch from the skeleton sequence:
- Batch 02 — Research Scientist workspace, unless the operator chooses to first run a config-integration or smoke cleanup pass.

## 11. Integration request summary

Batch 01 requested later operator/config consideration, not completed config integration.

Role owner:
- operator/config for `/workspace` roots and runtime checks
- aiengineer for `/workspace/repos/research-assistant`

Workspace roots:
- `/workspace`
- `/workspace/repos/research-assistant`

Commands requested for possible later exposure:
- `python3 /workspace/scripts/runtime_checks/check_runpod_workspace.py`
- `python3 /workspace/scripts/runtime_checks/check_gpu_runtime.py`
- `python3 /workspace/scripts/runtime_checks/check_cuda_torch_runtime.py`
- `python3 /workspace/scripts/runtime_checks/check_docker_gpu_access.py`
- `python3 /workspace/scripts/runtime_checks/check_kubernetes_context.py`
- `python3 /workspace/repos/research-assistant/smoke_test.py`

Python packages needed:
- standard library only in the checked skeleton state.

Suggested integration type:
- deferred
- likely workspace-root plus health-check or launcher exposure if approved by operator

Smoke checks to preserve:
- `BATCH_SLUG="01-runtime-substrate" bash /workspace/scripts/smoke.sh skeleton-progress`
- `python3 /workspace/repos/research-assistant/smoke_test.py`

Output contracts to preserve:
- generic runtime roots under `/workspace`
- runtime policy files under `/workspace/runtime`
- readiness check scripts under `/workspace/scripts/runtime_checks`
- dummy remote-model client/router under `/workspace/repos/research-assistant`

Safety boundaries:
- do not edit config internals from this implementation batch
- later operator-side work decides whether to create bootstrap/profile/alias exposure
- use `python3` as the available interpreter in this checked environment
- use `PYTHONPYCACHEPREFIX=/tmp` for compile validation where `/workspace` is not writable for `__pycache__`

No final config step names are decided in this companion.
