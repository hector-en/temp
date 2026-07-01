# vmuser / Agentfield GRN Platform — Transition-to-Real-Organs Master

**Updated basis:** this version is aligned to `Corrected_Smoke_d_Batch_Mapping_Report_Skeleton_Batches_01_24_proper.md`.

**Purpose:** this file contains only the transition work required after the corrected skeleton-dummy implementation is running. It is the bridge from fake organs to real science, real platform APIs, real RunPod execution, real Agentfield integration, and real Paperclip persistence.

**Use this after:** the relevant corrected skeleton batch or logical skeleton group has reached checked state with `POSTCHECK.md`, `INTEGRATION_REQUEST.md`, and acceptable dynamic smoke result. Full end-to-end transition work should wait until the corrected skeleton 01–24 baseline is stable.

**Transition rule:** replace implementation internals, but keep the skeleton output contracts stable unless a deliberate versioned contract migration is created.

**Corrected skeleton authority rule:** Layer PDFs are background semantics, not batch slices. The corrected skeleton batch plan remains the 01–24 slicing authority. Real-organ work must map back to corrected skeleton batch slugs, output contracts, and smoke domains.

**Smoke rule:** smoke proves file/contract/readiness shape, not scientific truth, live orchestration, or live infrastructure. Real-organ batches may add real local/deterministic internals, but live provider, RunPod, Kubernetes, Terraform, Agentfield, Paperclip, or model actions remain guarded by explicit flags and human/operator approval.

**External help rule:** when a transition needs external platform code, ask the relevant source before coding:

- **RunPod:** use RunPod docs and the RunPod AI-powered developer chat for API, job, volume, checkpoint, and result-pullback code.
- **Agentfield:** use the Agentfield GitHub/developer docs and ask the developer for controller, reasoner, async execution, and status semantics.
- **Paperclip:** ask the Paperclip developer or inspect the Paperclip schema/API before writing real job/database integration.
- **OpenClaw/model providers:** use OpenClaw docs/code and provider docs for real reasoning/model calls.

---

## Corrected skeleton contract map used by this transition

| Corrected skeleton group | Skeleton batches | Slugs | Real-organ transition meaning |
|---|---|---|---|
| Runtime substrate and remote-model dummy contract | 01 | `01-runtime-substrate` | Real runtime readiness, RunPod/GPU/container policy, remote-model client health, but no live launch by default. |
| Research workspace | 02 | `02-research-workspace` | Real NCA-ART-GRN workspace and package/env path, replacing dummy science CLI internals while keeping paths and outputs stable. |
| AI Engineer workspaces | 03 | `03-ai-engineer-workspaces` | Real Agentfield/OpenClaw/adapter development roots and package readiness, without starting live platforms by default. |
| PKM skeleton | 04 | `04-pkm-skeleton` | Real vault binding and safe selected-context access; no whole-vault indexing or note overwrite by default. |
| Publisher LaTeX | 05 | `05-publisher-latex` | Real LaTeX/notebook export tooling and true labreport/IBA assets, but no PDF build or manuscript overwrite by default. |
| NCA-ART-GRN science contracts | 06–09 | `06-nca-art-base`, `07-dummy-science-organs`, `08-mechanism-reporting`, `09-local-smoke` | Real DSL, mechanism hypotheses, simulator, NCA, ART2/ARTMAP, perturbation, prototype-to-DSL, mechanism reporting, and local smoke internals. |
| Search contracts | 10–12 | `10-search-templates`, `11-search-scoring`, `12-search-smoke` | Real local search drivers, scoring, ranking, robustness/perturbation sweeps, and tiny local search smoke. |
| RunPod dry-run | 13 | `13-runpod-dryrun` | Real RunPod job specs/client wrappers; live submit/pullback/resume remains explicit and guarded. |
| OpenClaw/PKM reasoning access | 14–15 | `14-openclaw-indexes`, `15-openclaw-reasoners` | Real selected artifact/PKM indexing and reasoning wrappers; no paid/remote calls or vault writes by default. |
| Agentfield POC | 16–18 | `16-agentfield-poc`, `17-agentfield-reasoners`, `18-agentfield-hardening-stubs` | Real modular Agentfield experiment lifecycle/controller bridge and status/artifact mapping. |
| Paperclip adapter | 19–20 | `19-paperclip-adapter-core`, `20-paperclip-review-dryrun` | Real request/status/review/action mapping behind mock/dry-run defaults and guarded live write boundary. |
| Campaign orchestration | 21–24 | `21-campaign-core`, `22-campaign-agents`, `23-campaign-review-smoke`, `24-campaign-guarded-stubs` | Real resumable campaign execution pipeline, human review payloads, retry/resume/comparison, and guarded future live submit. |

---

## Corrected smoke domains that real-organ work must preserve or extend

| Smoke domain | Module | Real-organ implication |
|---|---|---|
| Core runtime/layout | `10-core-layout.smoke.sh` | Real runtime checks must not break `/workspace` roots or report layout. |
| Python package/import | `20-python-package.smoke.sh` | Real packages must compile/import or warn only for optional missing env pieces. |
| Skeleton evidence | `30-skeleton-evidence.smoke.sh` | Skeleton evidence remains the baseline contract for organ transition. |
| Config boundary | `50-config-boundary.smoke.sh` | Real-organ implementation batches still must not edit config internals. |
| Infra tools | `60-infra-tools.smoke.sh` | Real infra checks are command/readiness checks only unless explicitly gated. |
| GRN/NCA/ART contracts | `70-grn-contract.smoke.sh`, possible later split | Real science organs must preserve output filenames/schema shapes or add versioned contract migration. |
| Research assistant | `90-research-assistant.smoke.sh` | Remote-model client transition must preserve guarded dummy/local path and avoid live calls by default. |
| RunPod dry-run | future `75-runpod-dryrun.smoke.sh` | Real RunPod wrappers default to dry-run/no-pod-launch. |
| PKM/OpenClaw | future `80-openclaw-pkm.smoke.sh` | Real indexing/reasoning remains selected-context, no whole-vault/default live call. |
| Publisher/LaTeX | future `82-publisher-latex.smoke.sh` | Real publisher tooling must keep no-build-by-default and no manuscript overwrite. |
| Agentfield | future `85-agentfield.smoke.sh` | Real controller/agent integration remains dry-run/local unless explicitly live-gated. |
| Paperclip adapter | future `86-paperclip-adapter.smoke.sh` | Real adapter defaults to mock/dry-run and no live DB/API writes. |
| Campaign orchestration | future `88-agentfield-campaign.smoke.sh` | Real campaign pipeline remains reviewable, resumable, guarded, and non-autonomous by default. |

---

## Transition changes only

| Order | Corrected skeleton source | Area | Transition change | Real output/behavior | External code/help | Guardrail |
|---:|---|---|---|---|---|---|
| 1 | Batch 01 `01-runtime-substrate` | Runtime checks | Replace stub workspace checks with real permission, volume, free-space, RunPod detection, and GPU/CUDA/Torch compatibility checks. | Reliable machine/runtime readiness before expensive runs. | RunPod docs/dev chat; PyTorch CUDA docs. | Still no job launch from checks. |
| 2 | Batch 01 `01-runtime-substrate` | Docker/remote compute | Convert Docker GPU and compute-profile policy from documentation stubs into tested local/RunPod container readiness checks. | Accurate compute profile selected for local vs RunPod. | RunPod dev chat; Docker docs. | No image pull/build unless explicit. |
| 3 | Batch 01 `01-runtime-substrate` | Terraform/Kubernetes | If needed, replace policy-only checks with real read-only context validation and later explicit apply workflows. | Cluster/provisioning readiness without accidental mutation. | Terraform/Kubernetes docs; Agentfield deployment docs. | No apply by default. |
| 4 | Batch 01 `01-runtime-substrate` | Remote model client | Replace dummy model response with real local/remote model client and health/smoke calls behind explicit flags. | Stable local code -> remote model -> response path. | RunPod AI dev chat; OpenRouter/provider docs. | Never print API keys; cost guardrails required. |
| 5 | Batch 02 `02-research-workspace` | Research packages | Turn dry-run package policy into real environment installs using managed target Python env resolver. | `researchscientist` env has needed packages. | Conda/PyPI/PyTorch docs; existing lv/config env policy. | Do not install into operator/root env. |
| 6 | Batch 02 `02-research-workspace` | NCA-ART-GRN repo | Replace skeleton files with real implementation modules while keeping repo/output paths stable. | Real research engine source code. | Science notes, DSL/NCA/ART/ARTMAP docs, developer review. | Do not create `prepare_grn_workspace` duplicate. |
| 7 | Batch 03 `03-ai-engineer-workspaces` | AI platform packages | Turn dry-run package policies into real AI Engineer packages and version pins. | `aiengineer` env can run Agentfield/OpenClaw/adapter code. | Agentfield GitHub/docs/developer; OpenClaw docs; model provider docs. | Keep platform deps out of `researchscientist` unless needed. |
| 8 | Batch 04 `04-pkm-skeleton` | Real vault binding | Bind the real Obsidian/Atomic Zettelkasten vault and refine templates after use. | Real PKM vault usable for research/publishing. | Zettelkasten rules; Obsidian sync/mount details. | No automatic overwrite or indexing of whole vault. |
| 9 | Batch 05 `05-publisher-latex` | LaTeX toolchain | Install real LaTeX/notebook export tools and copy true labreport/IBA assets. | GRN paper project can compile when explicitly requested. | Distro package docs; LaTeX project assets. | No manuscript overwrite; build explicit. |
| 10 | Batch 05 `05-publisher-latex` | Manuscript bridge | Replace placeholder section/bridge files with real selected alloy-note, figure, BibTeX, and notebook export integration. | Paper sections can be generated/updated under human control. | Pandoc/nbconvert/LaTeX docs; paper style. | No auto-convert whole vault. |
| 11 | Batch 06 `06-nca-art-base` | DSL organ | Replace dummy/stub behavior with real 5-node GRN DSL with topology, signs, matrices, reaction/diffusion params, motif provenance, observables, perturbables. | Real 5-node GRN DSL. | DSL design docs; mathematical biology review. | Keep same filenames and schemas used by skeleton unless versioned migration is created. |
| 12 | Batch 06 `06-nca-art-base` | Mechanism hypothesis organ | Replace dummy/stub behavior with real mechanism classes, parameter constraints, dynamics predictions, perturbation predictions, falsification criteria. | Real mechanism hypotheses. | Hiscock/Megason paper; domain advisor feedback. | Keep same filenames and schemas used by skeleton unless versioned migration is created. |
| 13 | Batch 07 `07-dummy-science-organs` | PDE/ODE simulator organ | Replace dummy/stub behavior with real reaction-diffusion simulator with time series, boundary/initial conditions, perturbations, metrics. | Real simulator outputs. | Scientific literature; numerical methods review. | Keep same filenames and schemas used by skeleton unless versioned migration is created. |
| 14 | Batch 07 `07-dummy-science-organs` | NCA organ | Replace dummy/stub behavior with real NCA local update/training/rollout and simulator-to-NCA dataset writer. | Real NCA local update/training/rollout and dataset writer. | NCA references; PyTorch/JAX docs. | Keep same filenames and schemas used by skeleton unless versioned migration is created. |
| 15 | Batch 07 and 08 | ART2 organ | Replace dummy/stub behavior with real continuous-state ART2 prototypes with metadata and stability/support. | Real ART2 prototypes. | ART2 source material; algorithm references. | Keep same filenames and schemas used by skeleton unless versioned migration is created. |
| 16 | Batch 07 and 08 | ARTMAP organ | Replace dummy/stub behavior with real ARTMAP/regression transition learning and transition graphs. | Real transition graphs. | ARTMAP docs/papers; algorithm references. | Keep same filenames and schemas used by skeleton unless versioned migration is created. |
| 17 | Batch 07 | Pattern dynamics organ | Replace dummy/stub behavior with real wavelength/mode growth/dispersion/K(x) metrics. | Real pattern dynamics metrics. | Hiscock/Megason; signal processing/numerics references. | Keep same filenames and schemas used by skeleton unless versioned migration is created. |
| 18 | Batch 07 | Perturbation organ | Replace dummy/stub behavior with real perturbation configs and simulations for diffusion, boundary, initial-condition, local-ablation, NCA replay. | Real perturbation outputs. | Domain advisor/science literature. | Keep same filenames and schemas used by skeleton unless versioned migration is created. |
| 19 | Batch 08 | Prototype-to-DSL organ | Replace dummy/stub behavior with real inverse mapping/sparse regression/sign constraints/motif reduction to DSL candidates. | Real prototype-to-DSL candidates. | Optimization/sparse regression references. | Keep same filenames and schemas used by skeleton unless versioned migration is created. |
| 20 | Batch 08 and 09 | Mechanism report organ | Replace dummy/stub behavior with real evidence report that names falsification and next experiment. | Real mechanism report. | Writing/paper standards; Hiscock/Megason guardrail. | Keep same filenames and schemas used by skeleton unless versioned migration is created. |
| 21 | Batch 10 | Search algorithms | Replace placeholder search pieces with real random/grid/LHS/evolutionary/Bayesian/active-learning samplers. | Real search samplers. | Optimization package docs; parameter-search learning resources. | Do not optimize only final pattern score. |
| 22 | Batch 11 | Mechanism scoring | Replace placeholder search pieces with real multi-objective scoring across dynamics, NCA agreement, ART2 quality, ARTMAP consistency, perturbation response, DSL recoverability. | Real multi-objective scoring. | Scientific validation decisions. | Do not optimize only final pattern score. |
| 23 | Batch 11 and 12 | Ranking/comparison | Replace placeholder search pieces with real comparison reports, Pareto fronts, robustness-first and experiment-design-first rankings. | Real comparison/ranking reports. | Stats/visualization docs. | Do not optimize only final pattern score. |
| 24 | Batch 11 and 12 | Robustness/perturbation search | Replace placeholder search pieces with real robustness and perturbation sweeps. | Real robustness/perturbation sweeps. | Domain and numerical testing guidance. | Do not optimize only final pattern score. |
| 25 | Batch 13 `13-runpod-dryrun` | RunPod live submit | Implement explicit live RunPod job submission from manifest. | `submit_runpod_training_job`. | RunPod AI-powered dev chat/API docs. | Live submit requires explicit flag and cost guardrail. |
| 26 | Batch 13 `13-runpod-dryrun` | RunPod result pullback | Implement result collection/promotion according to result return policy. | `pull_runpod_results`. | RunPod storage/API docs. | Never delete remote results by default. |
| 27 | Batch 13 `13-runpod-dryrun` | RunPod resume | Implement checkpoint resume and failed-run recovery. | `resume_runpod_checkpoint`. | RunPod/PyTorch checkpoint details. | Resume only from explicit checkpoint path. |
| 28 | Batch 15 `15-openclaw-reasoners` | OpenClaw real jobs | Replace mock OpenClaw/reasoning jobs with real OpenClaw or model-backed reasoner runs. | Real reasoning outputs over selected context. | OpenClaw docs/code; model provider docs. | No vault write without approval. |
| 29 | Batch 14 `14-openclaw-indexes` | PKM/research indexing | Implement safe incremental indexes over selected notes and artifacts. | Queryable selected context packs. | Obsidian/PKM tooling; OpenClaw docs. | Do not index all private notes by default. |
| 30 | Batch 16 `16-agentfield-poc` | Agentfield POC to modules | Convert imported single-file POC into real modules while preserving execute behavior. | Modular Agentfield controller foundation. | Agentfield GitHub/docs/developer. | POC smoke must still pass. |
| 31 | Batch 18 `18-agentfield-hardening-stubs` | Agentfield to NCA-ART bridge | Connect Agentfield stages/status to real `nca-art-grn` CLI outputs and artifact refs. | Agentfield status links real mechanism evidence. | Agentfield developer; `nca-art-grn` CLI contracts. | Do not duplicate science in Agentfield. |
| 32 | Batch 18 `18-agentfield-hardening-stubs` | Agentfield RunPod target | Implement real reserved RunPod execution target. | Agentfield can target RunPod manifests safely. | Agentfield developer; RunPod dev chat. | Live RunPod execution explicit and reviewed. |
| 33 | Batch 19 and 20 | Live Agentfield adapter | Turn adapter live smoke into stable Agentfield client with polling/async support. | Adapter calls live Agentfield reliably when explicitly gated. | Agentfield API docs/developer. | No Paperclip DB writes yet unless explicit. |
| 34 | Batch 19 and 20 | Paperclip production job submit | Implement `submit_real_paperclip_job` to send/receive real Paperclip job data. | Real Paperclip job submit path. | Paperclip developer/schema/API required. | Requires mock-to-prod switch and audit logging. |
| 35 | Batch 20 | Paperclip database write | Implement `write_to_paperclip_database` for status/card/review records. | Real Paperclip persistence path. | Paperclip database schema/developer help required. | No direct DB writes until schema confirmed and backup exists. |
| 36 | Batch 20 and 24 | Launch RunPod from Paperclip | Implement `launch_runpod_from_paperclip` via adapter -> Agentfield -> RunPod manifest path. | Guarded launch path. | Paperclip developer + Agentfield developer + RunPod dev chat. | Must require approval/cost guardrail. |
| 37 | Batch 20 and 23 | Auto-approve next experiment | Implement `auto_approve_next_experiment` only as policy-controlled workflow. | Policy-controlled review automation. | Paperclip policy/developer input required. | Default false; never bypass human review for costly/publication actions. |
| 38 | Batch 24 `24-campaign-guarded-stubs` | RunPod campaign executor | Replace skeleton campaign capability with real campaign executor that writes/submits RunPod manifests and tracks status. | Real campaign executor. | RunPod AI dev chat; Agentfield developer. | Cost guardrail and human approval required. |
| 39 | Batch 24 `24-campaign-guarded-stubs` | Async campaign resume | Replace skeleton campaign capability with real async state reload, polling, resume, partial completion handling. | Real async campaign resume. | Agentfield docs/developer. | Must be idempotent. |
| 40 | Batch 24 `24-campaign-guarded-stubs` | Campaign retry policy | Replace skeleton campaign capability with real retry implementation for platform failures only. | Real retry behavior. | Agentfield/reliability guidance. | Do not retry scientific failures blindly. |
| 41 | Batch 24 `24-campaign-guarded-stubs` | Multi-campaign comparison | Replace skeleton campaign capability with real comparison across campaign outputs and evidence quality. | Real campaign comparison. | Stats/visualization docs. | Separate platform completion from scientific strength. |
| 42 | Batch 24 `24-campaign-guarded-stubs` | Paperclip campaign live submit | Replace skeleton campaign capability with real Paperclip campaign submit/review flow. | Real Paperclip campaign submit/review path. | Paperclip developer/API. | Requires human review state and audit trail. |
| 43 | Batches 21–23 | Agentic campaign organs | Replace skeleton campaign capability with agents that call real Bundle 3/4/5/8 functionality and produce reviewable outputs. | Reviewable agentic campaign outputs. | Agentfield developer; domain science review. | No autonomous truth claims; review required. |

---

## Contract migration policy

If a real implementation needs to change a skeleton contract:

1. Create `contract_version` in the output JSON/YAML.
2. Keep the old filename for at least one compatibility pass.
3. Update Agentfield artifact/status mapping first.
4. Update Paperclip artifact/card mapping second.
5. Update OpenClaw context indexes third.
6. Only then remove old fields.

## Real-organ readiness checklist

A skeleton step is ready to become a real organ only when:

- Its dummy output is already consumed by another layer.
- The real code can write the same output filename or a versioned replacement.
- The relevant external API/platform details have been confirmed.
- There is a smoke test for success and failure.
- There is a human review or explicit live flag for any costly, mutating, or publication-relevant action.
- The corrected smoke domain for that skeleton source remains PASS, SKIP, or accepted WARN.

## Special live-action names

These are intentionally transition-only and must not be silently enabled in the skeleton pass:

```text
submit_runpod_training_job
pull_runpod_results
resume_runpod_checkpoint
submit_real_paperclip_job
write_to_paperclip_database
launch_runpod_from_paperclip
auto_approve_next_experiment
```

Alias note: if old notes contain `auto_approve_next_experimen`, treat it as a typo for `auto_approve_next_experiment`.
