<!-- G21/G22 registry-routing update -->
Active routing is registry-driven: concrete skeleton and organ IDs are examples unless explicitly labeled historical. Ordinary lanes do not edit CLI_EXTRACTION_NOTES.md; reusable friction routes through 0C/public maintenance.

# InfraCTL Prompt-Only Flow README

This README explains how to use `infractl.zip` as a prompt-instruction library in a fresh ChatGPT or Codex chat.

The current `infractl.zip` should have this shape at the zip root. Do **not** expect an extra nested `infractl/` directory around the DOT router tree. The `infractl/` folder inside the zip is the Python package, not the DOT root.

```text
infractl.zip
├── README.md
├── infractl.md
├── prompt_guide.md
├── workflow.md
├── pyproject.toml
├── infractl/
│   ├── cli.py
│   ├── project.py
│   ├── pack.py
│   ├── evidence.py
│   ├── profiles.py
│   └── render.py
├── dots/
│   ├── infractl_merged_cheatsheet_flow_numbered_cli_extraction.dot
│   ├── zero-abc/
│   │   ├── 0A_public_private_contract_infractl_prompts_only.dot
│   │   ├── 0A_public_private_contract_infractl_prompts_only.png
│   │   ├── 0B_expansion_lane_infractl_prompts_only.dot
│   │   ├── 0B_expansion_lane_infractl_prompts_only.png
│   │   ├── 0C_cli_extraction_feedback_infractl_prompts_only.dot
│   │   └── 0C_cli_extraction_feedback_infractl_prompts_only.png
│   ├── request-create-skeleton/
│   ├── request-update-skeleton/
│   ├── request-create-organs/
│   ├── request-update-organs/
│   └── config-infra/
│       ├── CIP01_source_intake_and_suitability_determination_infractl_prompts_only.dot
│       ├── CIP02_rich_integration_request_generation_infractl_prompts_only.dot
│       ├── CIP03_manifest_aggregation_and_approval_infractl_prompts_only.dot
│       ├── CIP04_live_config_state_resolution_infractl_prompts_only.dot
│       ├── CIP05_config_implementation_planning_infractl_prompts_only.dot
│       └── CIP06_idempotent_application_and_closeout_infractl_prompts_only.dot
├── schemas/
├── scripts/
├── templates/
└── examples/
```

The main DOT is `dots/infractl_merged_cheatsheet_flow_numbered_cli_extraction.dot`. The phase/router DOTs live under `dots/...`.

## Repo-local DOT rule

When operating inside `/workspace/repos/infractl-public`, read DOT files from:

```text
dots/
```

Use repo-local `dots/...` paths for Codex/WSL/local instructions. Keep `infractl.zip` upload wording for fresh webchat sessions, but do not point local operators at `infractl/<lane>/...`.

Zip-tree verification note:

```text
Correct P-lane path: dots/request-create-skeleton/P4_package_to_codex_lane_infractl_prompts_only.dot
Correct 0-lane path: dots/zero-abc/0A_public_private_contract_infractl_prompts_only.dot
Correct CIP path: dots/config-infra/CIP03_manifest_aggregation_and_approval_infractl_prompts_only.dot
Incorrect for the current zip: infractl/request-create-skeleton/P4_package_to_codex_lane_infractl_prompts_only.dot
Incorrect for the current zip: infractl/zero-abc/0A_public_private_contract_infractl_prompts_only.dot
Incorrect for the current zip: infractl/config-infra/CIP03_manifest_aggregation_and_approval_infractl_prompts_only.dot
```

## Zero and Config-Infra path verification

The current `infractl.zip` contains Zero and Config-Infra DOTs directly under `dots/`, not under the Python package folder. Use these exact paths when prompting ChatGPT, Codex, or a WSL/operator session.

For lane-wide public-bundle, `README.md`, `prompt_guide.md`, DOT-path, strict-prompt, guardrail, or two-root-contract maintenance, route through `0B` first. If `HOOK_public_bundle_lane_update_method` matches the task, then consult `CLI_EXTRACTION_NOTES.md` and use the `0B -> G21/G22` maintenance pattern; ordinary lanes do not read that file by default.

Zero lanes:

```text
dots/zero-abc/0A_public_private_contract_infractl_prompts_only.dot
dots/zero-abc/0B_expansion_lane_infractl_prompts_only.dot
dots/zero-abc/0C_cli_extraction_feedback_infractl_prompts_only.dot
```

Config-Infra CIP lanes:

```text
dots/config-infra/CIP01_source_intake_and_suitability_determination_infractl_prompts_only.dot
dots/config-infra/CIP02_rich_integration_request_generation_infractl_prompts_only.dot
dots/config-infra/CIP03_manifest_aggregation_and_approval_infractl_prompts_only.dot
dots/config-infra/CIP04_live_config_state_resolution_infractl_prompts_only.dot
dots/config-infra/CIP05_config_implementation_planning_infractl_prompts_only.dot
dots/config-infra/CIP06_idempotent_application_and_closeout_infractl_prompts_only.dot
```

Do not use these stale nested forms with the current zip:

```text
infractl/zero-abc/...
infractl/config-infra/...
infractl/request-create-skeleton/...
infractl/request-update-skeleton/...
infractl/request-create-organs/...
infractl/request-update-organs/...
```

The only `infractl/` directory in the current zip is the Python package (`infractl/cli.py`, `infractl/project.py`, etc.). It is not the DOT router root.

## General rule

In a fresh chat, upload:

```text
1. infractl.zip
2. infractl.md
3. the actual input files needed for the route
```

Then tell the model which route to run.

Always tell the model:

```text
Suggest the variable block first.
Ask me to confirm or correct it.
Do not execute until I confirm.
```

The model should read:

```text
1. infractl.md
2. dots/infractl_merged_cheatsheet_flow_numbered_cli_extraction.dot
3. the selected prompt-only DOT for the route and phase, or the selected CIP DOT from `dots/config-infra/`
```

---

# 0A / 0B / 0C setup routes

Use these before or beside the normal P1-P6 routes. For 0B, the dedicated canonical master template below overrides every older or mixed zero-lane template in this guide.

## 0A — public/private contract preflight

Use this when you want to check that the public tool and private bundle layout are valid before starting a batch route.

Upload:

```text
infractl.zip
infractl.md
public_infra-skeleton-tools_v0.zip OR public repo access
<private-project-bundle-or-root>
```

Say:

```text
Use infractl.md and infractl.zip.
Run 0A public/private contract preflight.

Read infractl.md first.
Read the root main v7 DOT next.
Then use the 0A DOT from dots/zero-abc/.

Suggest the variable block first.
Ask me to confirm or correct it.
Do not execute until I confirm.
```

Use DOT:

```text
dots/zero-abc/0A_public_private_contract_infractl_prompts_only.dot
```

## 0B — expansion lane (canonical master template)

Use this lane when new background material, specifications, annexes, papers, workflow notes, source packages, legacy implementations, or design changes must be reconciled with the current private system before a create, update, Config-Infra, public-bundle maintenance, or implementation route.

**Canonical-template rule:** every request to create a 0B prompt must use the master template below. Fill its placeholders from the current task; do not fall back to the shorter mixed zero-lane templates later in this guide. The master template deliberately separates current-system truth, the primary synthesized change source, original-design verification evidence, and conditional supporting evidence.

Recommended uploads:

```text
infractl.md
infractl.zip or current public InfraCTL repository/bundle
latest private project bundle or workspace snapshot
primary synthesized change packet, when available
original or legacy sources needed for verification
conditional local or external primary sources needed only for targeted verification
```

When no synthesized change packet exists, use the same template with:

```text
PRIMARY_CHANGE_SOURCE_MODE=raw-source-set-requiring-synthesis
```

The 0B run must then create `PRIMARY_CHANGE_SYNTHESIS.md` in the sandbox before performing the design-delta and routing analysis.

Use DOT:

```text
dots/zero-abc/0B_expansion_lane_infractl_prompts_only.dot
```

### Canonical generic 0B prompt

````text
Use the latest uploaded public InfraCTL files, the latest current private project bundle, the primary synthesized change source, and the verification materials named below.

# Task

Run InfraCTL zero lane **0B expansion-routing** for `<ZERO_TOPIC>` before beginning any create, update, Config-Infra, public-bundle maintenance, or implementation lane.

This run must maximize routing quality by separating:

```text
current private-system truth
proposed design change
original-design verification evidence
conditional technical verification evidence
```

Do not redesign the target scope from scratch when a synthesized change packet already exists. Use 0B to validate, normalize, classify, and route that synthesis against the current private contract.

If no synthesized change packet exists, do not treat a loose collection of raw sources as already normalized. First create a compact `PRIMARY_CHANGE_SYNTHESIS.md` in the sandbox, then use that synthesis as the Tier 2 source for the remaining 0B analysis.

The purpose of this run is to determine the **smallest coherent canonical change set** without starting implementation or silently mutating current contracts.

# Route

```text
MODE=zero
TRACK=0B-expansion
ZERO_LANE=0B
PHASE=expansion-routing
TARGET_SCOPE_KIND=<layer | batch | organ | spec | hook | workflow | public-bundle | config-infra | cross-cutting>
TARGET_LAYER=<layer-id | n/a>
TARGET_TRACK=<skeleton | organ | cip | zero | public-tool | n/a>
TARGET_BATCH_NUMBER=<batch-number | n/a>
TARGET_BATCH_SLUG=<batch-slug | n/a>
TARGET_ORGAN_RUN=<organ-run-id | n/a>
TARGET_SCOPE_ID=<stable target identifier>
TARGET_TOPIC=<stable topic slug>
INTENDED_ROUTE=<expected canonical destinations and ownership>
EXPECTED_FOLLOW_ON_ROUTE=<request-create | request-update | config-infra | 0C | public-bundle-maintenance | stop | unknown>
EVIDENCE_REQUIRED=<yes | no | conditional>
PROFILE=webchat-sandbox
OUTPUT_ROOT=/mnt/data/generated_real_v0
ALLOW_OVERWRITE=no
ALLOW_CODE_OR_EVIDENCE_MUTATION=no
CLI_EXTRACTION_ALLOWED=yes-for-ledger-drafting-only
```

# Input hierarchy

Use the most current available versions of the following inputs, but do not treat every input as an equal source.

## Tier 1 — execution and current-system truth

These are mandatory and authoritative for routing, ownership, filenames, current state, and safety:

```text
infractl.md
infractl.zip or the latest current public InfraCTL bundle
<latest private project bundle or private workspace snapshot>
```

## Tier 2 — primary synthesized change source

Read this source completely. It is the primary source of the proposed design or workflow delta:

```text
<PRIMARY_CHANGE_SOURCE>
```

Set:

```text
PRIMARY_CHANGE_SOURCE_MODE=<synthesized-packet | raw-source-set-requiring-synthesis>
```

When the mode is `synthesized-packet`, treat its internal filenames as candidate source names, not automatically approved canonical private filenames.

When the mode is `raw-source-set-requiring-synthesis`, first produce:

```text
PRIMARY_CHANGE_SYNTHESIS.md
```

The synthesis must normalize the proposal, identify its assumptions, separate settled decisions from open questions, and cite the raw inputs used. After that, use the synthesis—not the raw repetition—as the Tier 2 change source.

## Tier 3 — original-design verification sources

Use these only to verify preservation of current or original intentions and to test whether the Tier 2 synthesis mischaracterized legacy behavior:

```text
<ORIGINAL_VERIFICATION_SOURCE_1>
<ORIGINAL_VERIFICATION_SOURCE_2>
<additional original or legacy sources, if any>
```

Do not independently re-derive the full architecture from Tier 3 when Tier 2 already contains a supported synthesis.

## Tier 4 — conditional supporting sources

Read these only when needed to resolve a specific uncertainty, contradiction, missing technical detail, capability claim, or ownership question:

```text
<CONDITIONAL_LOCAL_SOURCE_1>
<CONDITIONAL_LOCAL_SOURCE_2>
<PRIMARY_EXTERNAL_SOURCE_URL_1>
<PRIMARY_EXTERNAL_SOURCE_URL_2>
```

Prefer original repositories, specifications, documentation, papers, official product pages, and supplied source bundles over secondary summaries.

If web access is unavailable, do not fail automatically. Use Tier 2 and available local verification sources, record the limitation, and stop only when an unresolved external claim materially affects ownership, acceptance criteria, safety, or routing.

# Source-use rules

Apply all of these rules:

```text
1. Read the primary synthesized change source completely.
2. Use the private bundle to determine current truth and canonical ownership.
3. Use original or legacy sources only to test preservation and migration claims.
4. Use conditional sources only for targeted verification.
5. Do not count repeated statements across multiple sources as independent evidence.
6. Do not reopen a settled design decision unless private-system truth contradicts it or verification evidence exposes a material error.
7. Do not reward verbosity or repetition with higher confidence.
8. Prefer direct evidence over summaries when resolving a conflict.
9. Preserve uncertainty explicitly when a claim cannot be verified.
10. Route only the accepted delta, not every note, example, or idea found in the sources.
11. Do not include raw verification sources in a later lane merely because they were uploaded.
12. Keep current-state description and proposed-delta description separate in every artifact.
```

# Deduplication and normalization rule

When the same proposition appears in multiple inputs, normalize it into one claim.

For every normalized claim, record:

```text
claim ID
claim summary
primary supporting source
secondary verification source, if used
current private-system conflict, if any
confidence: confirmed | supported | tentative | rejected
routing consequence
```

Do not create duplicate requirements, annexes, hooks, or route entries from duplicated prose.

# Required read order

1. Read `infractl.md`.

2. Inspect the current public InfraCTL bundle.

   Use `dots/` as the DOT root. Do not use stale nested DOT paths.

3. Read the canonical main DOT:

   ```text
   dots/infractl_merged_cheatsheet_flow_numbered_cli_extraction.dot
   ```

4. Read exactly this zero-lane DOT:

   ```text
   dots/zero-abc/0B_expansion_lane_infractl_prompts_only.dot
   ```

5. Read the current private project contracts, where present:

   ```text
   project.yaml
   batches.yaml
   files.yaml
   hooks.yaml
   layers.yaml
   <additional registries named by the private contract>
   ```

6. Resolve and read the current canonical artifacts relevant to the target scope:

   ```text
   <CURRENT_ARTIFACT_SEARCH_SCOPE>
   ```

   Resolve canonical paths through registries, directory inspection, and content search before declaring a file missing. Do not infer filenames solely from titles or prior chat summaries.

7. Read Tier 2 completely. If Tier 2 is raw, produce `PRIMARY_CHANGE_SYNTHESIS.md` before continuing.

8. Build a preliminary delta inventory from Tier 2 before reading Tier 3 or Tier 4.

9. Read Tier 3 only to test preservation, omissions, distortions, and legacy-migration claims.

10. Read Tier 4 only when a specific delta remains materially uncertain.

11. Inspect existing generated outputs for the same target scope, topic, and candidate artifacts before drafting anything.

# Source-of-truth order

Use this precedence:

1. Selected 0B DOT as the lane-specific execution contract.
2. Canonical main DOT as the overall routing frame only.
3. Current private registries and existing canonical private artifacts.
4. Tier 2 synthesized change source.
5. Tier 3 original-design verification evidence.
6. Tier 4 targeted supporting evidence.
7. Prior chat summaries only as advisory context.

Tier 2 does not override current private-system truth. Tier 3 and Tier 4 do not override Tier 2 merely because they are older, longer, or more numerous.

If sources conflict, classify the conflict as one of:

```text
private-contract conflict
synthesis error
original-intent preservation gap
legacy-migration conflict
external capability conflict
naming or ownership conflict
security or safety conflict
non-material wording difference
```

For every material conflict, identify:

```text
the current invariant
the proposed additive or replacement delta
the conflicting claim
the strongest supporting evidence
the correct owning artifact
the correct owning layer, batch, organ, CIP phase, or public-tool area
the safe resolution or STOP reason
```

# Quality protocol

Follow this sequence after reading the required sources.

## Q1 — reconstruct current canonical state

From the private bundle, summarize only the currently registered contracts relevant to this task.

Do not mix proposed Tier 2 content into the current-state summary.

## Q2 — extract the proposed delta

From Tier 2, extract normalized proposed changes under task-appropriate headings.

At minimum include:

```text
architecture or workflow change
schema or metadata change
source or evidence change
hook or automation change
prompt or operator-flow change
acceptance criteria and validation fixtures
cross-layer, cross-batch, cross-organ, CIP, or public-tool ownership
safety, mutation, and rollback implications
```

## Q3 — verify only high-value or high-risk claims

Use Tier 3 and Tier 4 only where verification can change one of:

```text
acceptance or rejection of a design element
canonical ownership
required filename, schema, or registry entry
external tool or dependency capability assumption
migration feasibility
security, privacy, or mutation boundary
cross-route ownership
acceptance criteria
```

Do not verify low-impact restatements that cannot affect routing.

## Q4 — create a design-delta matrix

For every normalized delta, classify:

```text
KEEP — already correctly represented in the private system
EXTEND — existing artifact needs an additive update
REPLACE — existing contract is materially superseded and replacement is justified
NEW — no current canonical owner exists
DEFER — valid but belongs to a later route or owner
REJECT — conflicts with project invariants or adds unjustified complexity
VERIFY-LATER — non-blocking uncertainty remains
STOP — ownership, safety, or evidence cannot be resolved
```

Each row must include:

```text
delta ID
current owner
current-state evidence
proposed change
verification evidence used
classification
recommended target artifact
reason
```

## Q5 — select the smallest coherent change set

Do not create one canonical artifact for every Tier 2 file.

Choose the smallest registry-consistent set that:

```text
preserves accepted current invariants
captures all accepted additions or justified replacements
minimizes duplicated contracts
keeps implementation ownership in the correct routes
reduces future execution friction
supports deterministic generation of the next workflow prompt
```

## Q6 — route only accepted deltas

Produce exact target ownership, candidate filenames, registry changes, hook changes, downstream context, and accepted `EXTRA_SOURCES` for the next lane.

# Task-specific interpretation block

Treat the following as design intentions to test against current private truth, not as permission to create canonical files blindly.

## Current invariants to preserve

```text
<CURRENT_INVARIANT_1>
<CURRENT_INVARIANT_2>
<CURRENT_INVARIANT_3>
```

## Proposed additive deltas

```text
<PROPOSED_ADDITIVE_DELTA_1>
<PROPOSED_ADDITIVE_DELTA_2>
<PROPOSED_ADDITIVE_DELTA_3>
```

## Candidate replacements requiring explicit justification

```text
<CANDIDATE_REPLACEMENT_1>
<CANDIDATE_REPLACEMENT_2>
```

## Downstream ownership expectations

```text
<DOWNSTREAM_OWNER_OR_ROUTE_1>
<DOWNSTREAM_OWNER_OR_ROUTE_2>
```

## Forbidden scope expansions

```text
<FORBIDDEN_SCOPE_EXPANSION_1>
<FORBIDDEN_SCOPE_EXPANSION_2>
```

## Optimization priorities

Use this default priority order unless the private contract or operator explicitly changes it:

```text
correctness and safety
canonical ownership clarity
speed of execution
effectiveness for the intended workflow
minimal operator friction
minimal duplicated artifacts
future maintainability
```

# First response required

Before writing files, creating patches, or changing private sources, return only:

1. Selected route
2. Selected main DOT
3. Selected zero DOT
4. Addressed agent
5. Proposed variable block, with every value labeled:
   - user-provided
   - inferred
   - default-safe
   - unknown
6. Source-tier availability table
7. Planned source-use strategy: complete-read, verification-only, conditional, or unavailable
8. Missing or unreadable prerequisites
9. Current related SPEC, ANX, hook, prompt, companion, registry, evidence, and generated artifacts
10. Preliminary Tier 2-to-current-state delta inventory
11. Proposed high-value verification questions, if any
12. Proposed canonical target ownership
13. Idempotency decision
14. Whether 0C is needed, with reason
15. Confirmation question

End the first response with:

```text
Confirm these variables, source-use strategy, and proposed routing, or provide corrections. I will not write or overwrite private-system artifacts until confirmed.
```

Do not execute until I explicitly confirm or say:

```text
go with the suggested values
```

# Required variable block

Propose and label at least:

```text
CANONICAL_DOT_PATH=dots/infractl_merged_cheatsheet_flow_numbered_cli_extraction.dot

PRIMARY_CHANGE_SOURCE=<resolved Tier 2 path or raw source set>

PRIMARY_CHANGE_SOURCE_MODE=<synthesized-packet | raw-source-set-requiring-synthesis>

ORIGINAL_VERIFICATION_SOURCES=<resolved Tier 3 paths or none>

CONDITIONAL_SUPPORTING_SOURCES=<resolved Tier 4 paths and URLs or none>

SOURCE_USE_POLICY=tier2-complete; tier3-verification-only; tier4-targeted-only

SOURCE_SUMMARY=<one-sentence normalized summary of the proposed change>

CURRENT_ARTIFACT_SEARCH_SCOPE=<registries, directories, and canonical artifacts to inspect>

PUBLIC_TOOL_ROOT=<resolved sandbox public-tool root>

PRIVATE_PROJECT_ROOT=<resolved sandbox private-project root>

PRIVATE_BUNDLE_SOURCE=<most current private bundle>

TARGET_SCOPE_KIND=<confirmed scope kind>

TARGET_LAYER=<confirmed layer or n/a>

TARGET_TRACK=<confirmed track or n/a>

TARGET_BATCH_NUMBER=<confirmed batch number or n/a>

TARGET_BATCH_SLUG=<confirmed batch slug or n/a>

TARGET_ORGAN_RUN=<confirmed organ run or n/a>

TARGET_SCOPE_ID=<confirmed stable identifier>

TARGET_TOPIC=<confirmed topic slug>

INTENDED_ROUTE=<confirmed canonical destinations and ownership>

EXPECTED_FOLLOW_ON_ROUTE=<confirmed next route or unknown>

EVIDENCE_REQUIRED=<yes | no | conditional>

EXTRA_SOURCES=<accepted normalized artifacts that should travel into the next lane>

PROFILE=webchat-sandbox

OUTPUT_ROOT=/mnt/data/generated_real_v0

ALLOW_OVERWRITE=no

ALLOW_CODE_OR_EVIDENCE_MUTATION=no

CLI_EXTRACTION_ALLOWED=yes-for-ledger-drafting-only
```

Do not silently infer values that determine:

```text
canonical ownership
canonical filenames
overwrite permission
evidence state
public-tool changes
whether raw verification sources must be read
whether external browsing is necessary
whether a proposed replacement is allowed
whether 0C is required
```

# Execution after confirmation

After confirmation, execute only 0B expansion routing.

## Validate route identity

Confirm the full route block exactly as approved.

Stop if the current private contract assigns the work elsewhere and the conflict cannot be reconciled safely.

## Perform idempotency and registry checks

Before drafting final files:

- inspect existing target SPEC, ANX, hook, prompt, companion, manifest, registry, evidence, and generated artifacts;
- inspect matching entries in `files.yaml`, `hooks.yaml`, and other applicable registries;
- inspect existing topic-specific create or update hooks;
- inspect generated artifacts for the same target and topic;
- compare content and responsibility, not only filenames.

Classify proposed outputs as:

```text
new artifact
append-only delta
update to an existing canonical artifact
already satisfied
superseded candidate source
future-context only
needs explicit replacement approval
ambiguous ownership -> STOP
```

Do not overwrite historical or canonical files when `ALLOW_OVERWRITE=no`.

## Classify every normalized source contribution

For every Tier 2 artifact and every material Tier 3 or Tier 4 contribution, choose one primary classification:

```text
SPEC update
SPEC annex
creation-hook delta
update hook
reusable prompt or workflow update
companion or downstream context
Config-Infra input or follow-on
public-tool or CLI extraction candidate
reference-only source
no change or superseded
```

Explain why and name the owning scope.

Do not classify duplicate restatements as separate contributions.

## Resolve the smallest coherent change set

Do not create multiple canonical artifacts merely because the source packet contains multiple files.

Determine whether the most effective result is:

```text
one existing SPEC update plus focused annexes
one umbrella annex plus narrower downstream companions
updates to existing annexes instead of new files
a create/update hook plus accepted source attachments
a Config-Infra handoff
a public-bundle maintenance route
or another registry-consistent arrangement
```

Prefer the smallest coherent change set that fully captures the accepted delta and reduces future execution friction.

# Required draft outputs

Create draft or downloadable artifacts only under the sandbox output root.

Do not mutate the real private workspace, public workspace, live configuration, or historical evidence.

Produce, as applicable:

```text
PRIMARY_CHANGE_SYNTHESIS.md                 # only when Tier 2 began as raw sources
SOURCE_USE_LEDGER.md
NORMALIZED_CLAIM_LEDGER.md
CURRENT_STATE_SUMMARY.md
DESIGN_DELTA_MATRIX.md
EXTRA_SOURCE_ROUTING.md
ROUTING_DECISION.md
proposed canonical artifact patch or replacement draft
proposed focused annex drafts
proposed create/update-hook draft or patch
proposed downstream companion or context drafts
registry patch proposals
CLI_EXTRACTION_NOTES.md entry only when 0C-worthy behavior exists
NEXT_WORKFLOW_DIRECTION.md
```

Every draft must state:

```text
status: proposed / not applied
source files used
source tiers used
canonical owner
relationship to existing artifacts
whether it keeps, extends, replaces, defers, rejects, or leaves unchanged the proposed delta
next lane required
```

# Exact next workflow direction

If 0B passes, produce the next route using only accepted and normalized source paths:

```yaml
WORKFLOW_DIRECTION:
  mode: <request-create | request-update | config-infra | zero | public-bundle-maintenance | stop>
  track: <skeleton | organ | cip | zero | public-tool | n/a>
  phase: <P1 | CIP01 | CIP02 | CIP03 | CIP04 | CIP05 | CIP06 | 0C | maintenance-phase | n/a>
  target_scope_kind: <scope kind>
  target_scope_id: <stable identifier>
  layer: <layer or n/a>
  batch: <batch number or n/a>
  batch_slug: <batch slug or n/a>
  organ_run: <organ run or n/a>
  topic: <topic slug>
  evidence_required: <yes | no | conditional>
  extra_sources:
    - <accepted canonical or normalized source artifact 1>
    - <accepted canonical or normalized source artifact 2>
```

Do not include Tier 3 or Tier 4 sources in `extra_sources` merely because they were uploaded. Include them only when the next lane genuinely needs them to resolve or implement an accepted requirement.

Do not execute the follow-on route in this session.

Also report separately any additional later routes required after the immediate next route.

# Safety boundaries

Allowed:

```text
inspect uploaded files
extract uploaded archives in the sandbox
read Markdown, YAML, JSON, code inventories, templates, and registries
compare existing and proposed contracts
browse primary sources only when targeted verification is necessary
produce routing analysis
produce draft Markdown files and patch proposals in /mnt/data
produce the next WORKFLOW_DIRECTION
```

Forbidden:

```text
mutating the real private workspace
mutating the public repository
mutating /mnt/egress
rewriting historical evidence
executing the follow-on P, CIP, organ, public-tool, or maintenance lane
running Codex or pretending to run Codex
applying implementation or configuration changes
installing dependencies or plugins
running live infrastructure or model APIs
performing broad smoke or live tests
silently changing canonical filenames or registries
re-deriving the full design from raw sources without a specific unresolved question
treating repeated source text as independent evidence
including every uploaded source in the next lane without routing justification
```

Ordinary 0B routing must not read `CLI_EXTRACTION_NOTES.md` by default.

Read or draft it only when the task actually matches a public-tool, helper, repeated-command, or CLI-extraction pattern.

# Main-DOT appreciation

For each major action after confirmation, report:

```text
Main-DOT node or section: P7 / G21 / G22 where applicable
Zero lane: 0B
Plain-English purpose
Selected 0B DOT instruction followed
Supporting source or file check
Source tier used
Result: PASS / WARN / STOP
```

Explicitly confirm:

- the main DOT was used only as the routing frame;
- the selected 0B DOT was used as the lane-specific contract;
- no P1-P6, organ, CIP, 0A, 0C, or public-tool maintenance lane was executed unless explicitly routed;
- Tier 2 was the primary synthesized change source;
- Tier 3 and Tier 4 were used only for targeted verification;
- duplicate claims were normalized rather than counted repeatedly;
- current state and proposed delta remained separate;
- no implementation, configuration, or evidence mutation occurred.

# Required final response order

After confirmed execution, return:

1. Selected route
2. Selected main DOT
3. Selected zero DOT
4. Addressed agent
5. Confirmed variable block
6. Source-tier availability and actual use
7. Source-use ledger
8. Source-of-truth files read
9. Current canonical state
10. Normalized proposed delta
11. Targeted verification performed and why
12. Material conflicts and resolutions
13. Existing related artifacts and registry entries
14. Main-DOT position: P7 / G21 / G22
15. Idempotency decision
16. Design-delta matrix
17. Accepted reconciliation
18. Smallest coherent canonical change set
19. Canonical target files and owners
20. Draft artifacts and sandbox paths
21. Missing, rejected, superseded, deferred, or verify-later items
22. 0C decision
23. Exact `WORKFLOW_DIRECTION`
24. Additional downstream-route decisions
25. Recommended next action
26. PASS / WARN / STOP

# Decision rules

Return `PASS` only when:

- required Tier 1 inputs are readable;
- Tier 2 is readable or a normalized synthesis was successfully created from the confirmed raw source set;
- Tier 3 and Tier 4 were used only as needed;
- target ownership is clear;
- current state and proposed delta were kept separate;
- duplicate claims were normalized;
- material claims were verified where necessary;
- existing artifacts and registries were checked;
- the smallest coherent change set was identified;
- idempotency was satisfied;
- drafts are marked as proposed and not applied;
- an exact next workflow direction was produced;
- no forbidden action occurred.

Return `WARN` only when:

- ownership and routing remain safe and unambiguous;
- required drafts can still be produced;
- a non-blocking verification limitation is documented;
- unresolved items are explicitly classified as `VERIFY-LATER` or downstream context.

Return `STOP` when:

- a required Tier 1 input is missing or unreadable;
- Tier 2 cannot be read or safely synthesized;
- target identity is contradicted;
- target ownership is ambiguous;
- a material claim conflicts with private-system truth and cannot be safely resolved;
- an existing artifact would be overwritten without permission;
- the request jumps into implementation, mutation, live testing, or another lane;
- the wrong agent is addressed;
- the main DOT and selected 0B DOT conflict materially;
- the variable block, source-use policy, and routing have not been confirmed.

After `PASS`, recommend only the confirmed immediate next route from `WORKFLOW_DIRECTION`.

Stop after 0B. Do not begin the follow-on route.
````

## 0C — CLI extraction feedback

Use this when a repeated manual step, helper script, Codex friction, or workflow gap should be captured for possible public-tool or CLI promotion.

Upload:

```text
infractl.zip
infractl.md
helper script, logs, notes, or description of the repeated manual step
```

Say:

```text
Use infractl.md and infractl.zip.
Run 0C CLI extraction feedback for this helper/script/workflow issue.

Read infractl.md first.
Read the root main v7 DOT next.
Then use the 0C DOT from dots/zero-abc/.

Suggest the extraction note first.
Ask me to confirm or correct it.
Do not execute until I confirm.
```

Use DOT:

```text
dots/zero-abc/0C_cli_extraction_feedback_infractl_prompts_only.dot
```

---

# Config-Infra CIP routes

Use these routes when a batch or organ workflow needs structured config/lv/environment integration instead of an ad hoc handoff.

The real uploaded `infractl.zip` includes this folder under `dots/` at the zip root:

```text
dots/config-infra/
  CIP01_source_intake_and_suitability_determination_infractl_prompts_only.dot
  CIP02_rich_integration_request_generation_infractl_prompts_only.dot
  CIP03_manifest_aggregation_and_approval_infractl_prompts_only.dot
  CIP04_live_config_state_resolution_infractl_prompts_only.dot
  CIP05_config_implementation_planning_infractl_prompts_only.dot
  CIP06_idempotent_application_and_closeout_infractl_prompts_only.dot
```

## When to use CIP

Normal create/update routes can emit a rich `INTEGRATION_REQUEST.md`. CIP is the follow-on route family for deciding what to do with those requests.

```text
CIP01 = source intake and suitability determination
CIP02 = rich integration request generation or retrofit
CIP03 = manifest aggregation and approval
CIP04 = live config-state resolution
CIP05 = config implementation planning
CIP06 = idempotent application and closeout
```

Typical workflow alignment:

```text
Normal batch create/update
  -> rich INTEGRATION_REQUEST.md

S-T8 / O-T8
  -> CIP03 manifest aggregation and approval

S-T9 / O-T9
  -> CIP04 live config-state resolution
  -> CIP05 config implementation planning
  -> CIP06 manifest-approved application and closeout
```

Safety model:

```text
CIP01-CIP05 are read-only / planning-only.
CIP06 defaults to no mutation.
CIP06 may apply changes only with manifest approval, live config-state snapshot,
implementation plan, exact file touch set, explicit confirmation, and passing safety gates.
```

## Config-Infra CIP output root rule

For every CIP run, use:

```text
/workspace/runs/cip/<slug-title>/<cip-phase>/
```

where `<slug-title>` is the CIP topic/run slug and `<cip-phase>` is lowercase `cip01`, `cip02`, `cip03`, `cip04`, `cip05`, or `cip06`.

Examples:

```text
/workspace/runs/cip/batch01_config_infra_cip_alignment_manifest/cip03/INTEGRATION_MANIFEST.md
/workspace/runs/cip/batch01_config_infra_cip_alignment_manifest/cip04/CONFIG_STATE_SNAPSHOT.md
/workspace/runs/cip/batch01_config_infra_cip_alignment_manifest/cip05/CONFIG_INTEGRATION_PLAN.md
/workspace/runs/cip/batch01_config_infra_cip_alignment_manifest/cip06/CONFIG_INTEGRATION_CLOSEOUT_REPORT.md
```

Preferred variables:

```text
CIP_RUN_SLUG=<slug-title>
CIP_PHASE_DIR=cip04
CIP_RUN_ROOT=/workspace/runs/cip/${CIP_RUN_SLUG}
OUTPUT_ROOT=${CIP_RUN_ROOT}/${CIP_PHASE_DIR}
```

Phase mapping:

```text
CIP01 -> /workspace/runs/cip/<slug-title>/cip01/
CIP02 -> /workspace/runs/cip/<slug-title>/cip02/
CIP03 -> /workspace/runs/cip/<slug-title>/cip03/
CIP04 -> /workspace/runs/cip/<slug-title>/cip04/
CIP05 -> /workspace/runs/cip/<slug-title>/cip05/
CIP06 -> /workspace/runs/cip/<slug-title>/cip06/
```

Legacy handling:

```text
Legacy CIP outputs may exist under /workspace/cipXX/<topic>/ or /workspace/runs/cip/cipXX/<topic>/. New runs, addendums, and future phases must write under /workspace/runs/cip/<slug-title>/cipXX/. Read legacy paths as inputs only when needed. Do not move or overwrite them unless an explicit migration task is approved.
```

## Config-Infra filename contract

```text
Do not infer CIP source-contract filenames from phase titles.
Use the hardcoded CIP source-contract map and registry lookup.
If a mapped file is missing, search hooks.yaml / files.yaml / candidate filenames before declaring it missing.
Do not invent alternate filenames.
```

Compact canonical map:

```text
CIP01:
  spec_annex: SPEC_config_infra_integration_pipeline-ANX01_config_infra_suitability_determiner.md
  hook: HOOK_config_infra_suitability_assessment.md
  outputs: CONFIG_INFRA_SUITABILITY_DECISION.md, CONFIG_INFRA_SUITABILITY_DECISION.json

CIP02:
  spec_annex: SPEC_config_infra_integration_pipeline-ANX02_integration_request_schema.md
  hook: HOOK_config_infra_rich_integration_request.md
  outputs: INTEGRATION_REQUEST.md, INTEGRATION_REQUEST.json

CIP03:
  spec_annex: SPEC_config_infra_integration_pipeline-ANX03_integration_manifest_schema.md
  hook: HOOK_config_infra_manifest_gate.md
  outputs: INTEGRATION_MANIFEST.md, INTEGRATION_MANIFEST.json

CIP04:
  spec_annex: SPEC_config_infra_integration_pipeline-ANX04_config_state_snapshot_schema.md
  hook: HOOK_config_infra_live_resolution_gate.md
  outputs: CONFIG_STATE_SNAPSHOT.md, CONFIG_STATE_SNAPSHOT.json, CIP04_POSTCHECK.md

CIP05:
  spec_annex: SPEC_config_infra_integration_pipeline-ANX05_config_integration_plan_schema.md
  supporting_annex: SPEC_config_infra_integration_pipeline-ANX06_config_patch_classes.md
  hook: HOOK_config_infra_implementation_plan_gate.md
  outputs: CONFIG_INTEGRATION_PLAN.md, CONFIG_INTEGRATION_PLAN.json, CIP05_POSTCHECK.md

CIP06:
  spec_annex: SPEC_config_infra_integration_pipeline-ANX06_config_patch_classes.md
  supporting_annex:
    SPEC_config_infra_integration_pipeline-ANX07_config_integration_implementer_spec.md
    SPEC_config_infra_integration_pipeline-ANX08_config_integration_implementer_runbook.md
    SPEC_config_infra_integration_pipeline-ANX09_codex_pack_template_config_integration.md
  hook: HOOK_config_infra_closeout_snapshot_companion.md
  outputs: CONFIG_INTEGRATION_CLOSEOUT_REPORT.md, CONFIG_INTEGRATION_CLOSEOUT_REPORT.json, CIP06_POSTCHECK.md
```

## CIP router prompt

Use this when you are not sure which CIP phase to run next:

```text
Use infractl.md and infractl.zip.
I need help deciding which Config-Infra CIP phase to use for this request.
Given my current artifacts, tell me whether I should run CIP01, CIP02, CIP03, CIP04, CIP05, or CIP06 next.
Do not execute yet. First return the recommended phase, required files, missing prerequisites, and variable block.
```

## CIP01 — source intake and suitability determination

Use this for raw source material, a new environment/config idea, or an unclear request where you first need to decide whether it belongs in Config-Infra.

Upload:

```text
infractl.zip
infractl.md
raw source files / notes / config requirement / workflow requirement
```

Say:

```text
Use infractl.md and infractl.zip.
Run Config-Infra CIP01 source intake and suitability determination.

Read infractl.md first.
Read the root main v7 DOT next.
Then use the CIP01 DOT from dots/config-infra/.

Suggest the variable block first.
Ask me to confirm or correct it.
Do not execute until I confirm.
```

Use DOT:

```text
dots/config-infra/CIP01_source_intake_and_suitability_determination_infractl_prompts_only.dot
```

## CIP02 — rich integration request generation

Use this to generate or retrofit a rich `INTEGRATION_REQUEST.md` after suitability has been determined.

Upload:

```text
infractl.zip
infractl.md
CIP01 suitability decision if available
source files / notes / existing thin integration request if retrofitting
```

Say:

```text
Use infractl.md and infractl.zip.
Run Config-Infra CIP02 rich integration request generation.

Read infractl.md first.
Read the root main v7 DOT next.
Then use the CIP02 DOT from dots/config-infra/.

Suggest the variable block first.
Ask me to confirm or correct it.
Do not execute until I confirm.
```

Use DOT:

```text
dots/config-infra/CIP02_rich_integration_request_generation_infractl_prompts_only.dot
```

## CIP03 — manifest aggregation and approval

Use this at S-T8 or O-T8 to aggregate one or more integration requests into a manifest and decide what is approved, deferred, blocked, duplicate, or already covered.

Upload:

```text
infractl.zip
infractl.md
one or more INTEGRATION_REQUEST.md files
batch/organ evidence and context if available
```

Say:

```text
Use infractl.md and infractl.zip.
Run Config-Infra CIP03 manifest aggregation and approval.

Read infractl.md first.
Read the root main v7 DOT next.
Then use the CIP03 DOT from dots/config-infra/.

Suggest the variable block first.
Ask me to confirm or correct it.
Do not execute until I confirm.
```

Use DOT:

```text
dots/config-infra/CIP03_manifest_aggregation_and_approval_infractl_prompts_only.dot
```

## CIP04 — live config-state resolution

Use this after CIP03 to inspect the current real config/tooling state in read-only mode. CIP04 resolves what exists now; it does not apply changes.

```text
CIP04 naming guardrail:
The phase title is "Live config-state resolution", but the canonical ANX file is SPEC_config_infra_integration_pipeline-ANX04_config_state_snapshot_schema.md.
The canonical hook is HOOK_config_infra_live_resolution_gate.md.
The canonical outputs are CONFIG_STATE_SNAPSHOT.md, CONFIG_STATE_SNAPSHOT.json, and CIP04_POSTCHECK.md.
Do not use LIVE_CONFIG_STATE_SNAPSHOT.* or HOOK_config_infra_live_state_resolution.md unless a future registry explicitly changes the contract.
```

Upload:

```text
infractl.zip
infractl.md
CIP03 INTEGRATION_MANIFEST.md / .json
current config/tooling context or access to the target workspace when running in Codex/WSL
```

Say:

```text
Use infractl.md and infractl.zip.
Run Config-Infra CIP04 live config-state resolution.

Read infractl.md first.
Read the root main v7 DOT next.
Then use the CIP04 DOT from dots/config-infra/.

Suggest the variable block first.
Ask me to confirm or correct it.
Do not execute until I confirm.
```

Use DOT:

```text
dots/config-infra/CIP04_live_config_state_resolution_infractl_prompts_only.dot
```

## CIP05 — config implementation planning

Use this after CIP04 to produce the implementation plan and select patch/application classes. CIP05 plans only; it does not apply changes.

Upload:

```text
infractl.zip
infractl.md
CIP03 INTEGRATION_MANIFEST.md / .json
CIP04 CONFIG_STATE_SNAPSHOT.md / .json
```

Say:

```text
Use infractl.md and infractl.zip.
Run Config-Infra CIP05 config implementation planning.

Read infractl.md first.
Read the root main v7 DOT next.
Then use the CIP05 DOT from dots/config-infra/.

Suggest the variable block first.
Ask me to confirm or correct it.
Do not execute until I confirm.
```

Use DOT:

```text
dots/config-infra/CIP05_config_implementation_planning_infractl_prompts_only.dot
```

## CIP06 — idempotent application and closeout

Use this only after CIP03, CIP04, and CIP05 have passed and the operator explicitly confirms the approved touch set. CIP06 is mutation-default-no and must stop if approval or evidence is missing.

Upload:

```text
infractl.zip
infractl.md
CIP03 INTEGRATION_MANIFEST.md / .json
CIP04 CONFIG_STATE_SNAPSHOT.md / .json
CIP05 CONFIG_INTEGRATION_PLAN.md / .json
approved exact file touch set / confirmation context
```

Say:

```text
Use infractl.md and infractl.zip.
Run Config-Infra CIP06 idempotent application and closeout.

Read infractl.md first.
Read the root main v7 DOT next.
Then use the CIP06 DOT from dots/config-infra/.

Suggest the variable block first.
Ask me to confirm or correct it.
Do not execute until I confirm.
```

Use DOT:

```text
dots/config-infra/CIP06_idempotent_application_and_closeout_infractl_prompts_only.dot
```

---

# Route 1 — create skeleton batch

Use this to create a new skeleton batch request and carry it through P1-P6.

Example: create skeleton batch 02.

## P1 — request-create skeleton

Upload:

```text
infractl.zip
infractl.md
public_infra-skeleton-tools_v0.zip OR public repo access
<private-project-bundle-or-root>
any extra source files needed for this batch
```

Say:

```text
Use infractl.md and infractl.zip.

Task:
Create skeleton batch 02.

Route:
MODE=request-create
TRACK=skeleton
PHASE=P1
BATCH_NUMBER=02

Read infractl.md first.
Read the root main v7 DOT next.
Then use the P1 DOT from dots/request-create-skeleton/.

Suggest the full variable block first.
Ask me to confirm or correct it.
Do not execute until I confirm.
```

Use DOT:

```text
dots/request-create-skeleton/P1_request_create_skeleton_infractl_prompts_only.dot
```

## P2 — create-writing skeleton

Upload:

```text
infractl.zip
infractl.md
P1 request folder generated from the previous step
```

Say:

```text
Use infractl.md and infractl.zip.
Continue create skeleton batch 02 from P1 output.

Route:
MODE=request-create
TRACK=skeleton
PHASE=P2
BATCH_NUMBER=02

Read infractl.md first.
Read the root main v7 DOT next.
Then use the P2 DOT from dots/request-create-skeleton/.

Suggest the variable block first.
Ask me to confirm or correct it.
Do not execute until I confirm.
```

Use DOT:

```text
dots/request-create-skeleton/P2_create_writing_lane_infractl_prompts_only.dot
```

## P3 — create-package skeleton

Upload:

```text
infractl.zip
infractl.md
P2 create-writing files
```

Say:

```text
Use infractl.md and infractl.zip.
Package the create-writing files for skeleton batch 02.

Route:
MODE=request-create
TRACK=skeleton
PHASE=P3
BATCH_NUMBER=02

Read infractl.md first.
Read the root main v7 DOT next.
Then use the P3 DOT from dots/request-create-skeleton/.

Suggest the variable block first.
Ask me to confirm or correct it.
Do not execute until I confirm.
```

Use DOT:

```text
dots/request-create-skeleton/P3_create_package_lane_infractl_prompts_only.dot
```

## P4 — package-to-Codex skeleton create

Upload:

```text
infractl.zip
infractl.md
P3 Codex create pack zip
```

Say:

```text
Use infractl.md and infractl.zip.
Consume the Codex create pack for skeleton batch 02.

Route:
MODE=request-create
TRACK=skeleton
PHASE=P4
BATCH_NUMBER=02

Read infractl.md first.
Read the root main v7 DOT next.
Then use the P4 DOT from dots/request-create-skeleton/.

Suggest the variable block first.
Ask me to confirm or correct it.
Do not execute until I confirm.
```

Use DOT:

```text
dots/request-create-skeleton/P4_package_to_codex_lane_infractl_prompts_only.dot
```

## P5 — evidence-return skeleton create

Upload:

```text
infractl.zip
infractl.md
Codex execution output/evidence
smoke report if produced
```

Say:

```text
Use infractl.md and infractl.zip.
Return and snapshot evidence for skeleton batch 02.

Route:
MODE=request-create
TRACK=skeleton
PHASE=P5
BATCH_NUMBER=02

Read infractl.md first.
Read the root main v7 DOT next.
Then use the P5 DOT from dots/request-create-skeleton/.

Suggest the variable block first.
Ask me to confirm or correct it.
Do not execute until I confirm.
```

Use DOT:

```text
dots/request-create-skeleton/P5_evidence_return_lane_infractl_prompts_only.dot
```

## P6 — next-cycle skeleton create

Upload:

```text
infractl.zip
infractl.md
P5/G17 decision text
updated private bundle export if available
```

Say:

```text
Use infractl.md and infractl.zip.
Choose the next cycle after creating skeleton batch 02.

Route:
MODE=request-create
TRACK=skeleton
PHASE=P6
BATCH_NUMBER=02

Read infractl.md first.
Read the root main v7 DOT next.
Then use the P6 DOT from dots/request-create-skeleton/.

Suggest the next route first.
Ask me to confirm or correct it.
Do not execute until I confirm.
```

Use DOT:

```text
dots/request-create-skeleton/P6_next_cycle_lane_infractl_prompts_only.dot
```

---

# Route 2 — update skeleton batch

Use this to update an already-run skeleton batch. This route requires existing evidence.

Example: update skeleton batch 01 for topic `workflow_smoke_automation`.

## P1 — request-update skeleton

Upload:

```text
infractl.zip
infractl.md
public_infra-skeleton-tools_v0.zip OR public repo access
<private-project-bundle-or-root>
existing skeleton evidence for the batch:
  POSTCHECK.md
  INTEGRATION_REQUEST.md
  SMOKE_REPORT.md
optional extra source files for the update topic
```

Say:

```text
Use infractl.md and infractl.zip.

Task:
Update skeleton batch 01 for topic workflow_smoke_automation.

Route:
MODE=request-update
TRACK=skeleton
PHASE=P1
BATCH_NUMBER=01
TOPIC=workflow_smoke_automation
EVIDENCE_REQUIRED=yes

Read infractl.md first.
Read the root main v7 DOT next.
Then use the P1 DOT from dots/request-update-skeleton/.

Suggest the full variable block first.
Ask me to confirm or correct it.
Do not execute until I confirm.
```

Use DOT:

```text
dots/request-update-skeleton/P1_request_update_skeleton_infractl_prompts_only.dot
```

## P2 — update-writing skeleton

Upload:

```text
infractl.zip
infractl.md
P1 request-update folder
existing evidence check file from P1
```

Say:

```text
Use infractl.md and infractl.zip.
Continue update skeleton batch 01 for topic workflow_smoke_automation.

Route:
MODE=request-update
TRACK=skeleton
PHASE=P2
BATCH_NUMBER=01
TOPIC=workflow_smoke_automation

Read infractl.md first.
Read the root main v7 DOT next.
Then use the P2 DOT from dots/request-update-skeleton/.

Suggest the variable block first.
Ask me to confirm or correct it.
Do not execute until I confirm.
```

Use DOT:

```text
dots/request-update-skeleton/P2_update_writing_lane_infractl_prompts_only.dot
```

## P3 — update-package skeleton

Upload:

```text
infractl.zip
infractl.md
P2 update-writing files
```

Say:

```text
Use infractl.md and infractl.zip.
Package the update-writing files for skeleton batch 01 topic workflow_smoke_automation.

Route:
MODE=request-update
TRACK=skeleton
PHASE=P3
BATCH_NUMBER=01
TOPIC=workflow_smoke_automation

Read infractl.md first.
Read the root main v7 DOT next.
Then use the P3 DOT from dots/request-update-skeleton/.

Suggest the variable block first.
Ask me to confirm or correct it.
Do not execute until I confirm.
```

Use DOT:

```text
dots/request-update-skeleton/P3_update_package_lane_infractl_prompts_only.dot
```

## P4 — package-to-Codex skeleton update

Upload:

```text
infractl.zip
infractl.md
P3 Codex update pack zip
```

Say:

```text
Use infractl.md and infractl.zip.
Consume the Codex update pack for skeleton batch 01 topic workflow_smoke_automation.

Route:
MODE=request-update
TRACK=skeleton
PHASE=P4
BATCH_NUMBER=01
TOPIC=workflow_smoke_automation

Read infractl.md first.
Read the root main v7 DOT next.
Then use the P4 DOT from dots/request-update-skeleton/.

Suggest the variable block first.
Ask me to confirm or correct it.
Do not execute until I confirm.
```

Use DOT:

```text
dots/request-update-skeleton/P4_package_to_codex_update_skeleton_lane_infractl_prompts_only.dot
```

## P5 — evidence-return skeleton update

Upload:

```text
infractl.zip
infractl.md
Codex update evidence output
existing or new smoke report
```

Say:

```text
Use infractl.md and infractl.zip.
Return and snapshot evidence for skeleton batch 01 topic workflow_smoke_automation.

Route:
MODE=request-update
TRACK=skeleton
PHASE=P5
BATCH_NUMBER=01
TOPIC=workflow_smoke_automation

Read infractl.md first.
Read the root main v7 DOT next.
Then use the P5 DOT from dots/request-update-skeleton/.

Suggest the variable block first.
Ask me to confirm or correct it.
Do not execute until I confirm.
```

Use DOT:

```text
dots/request-update-skeleton/P5_evidence_return_update_skeleton_lane_infractl_prompts_only.dot
```

## P6 — next-cycle skeleton update

Upload:

```text
infractl.zip
infractl.md
P5/G17 decision text
updated private bundle export if available
```

Say:

```text
Use infractl.md and infractl.zip.
Choose the next cycle after updating skeleton batch 01 topic workflow_smoke_automation.

Route:
MODE=request-update
TRACK=skeleton
PHASE=P6
BATCH_NUMBER=01
TOPIC=workflow_smoke_automation

Read infractl.md first.
Read the root main v7 DOT next.
Then use the P6 DOT from dots/request-update-skeleton/.

Suggest the next route first.
Ask me to confirm or correct it.
Do not execute until I confirm.
```

Use DOT:

```text
dots/request-update-skeleton/P6_next_cycle_update_skeleton_lane_infractl_prompts_only.dot
```

---

# Route 3 — create organ scaffold

Use this to create the first organ route. Organ creation starts at R01 and must not reuse skeleton batch numbering by accident.

## P1 — request-create organ

Upload:

```text
infractl.zip
infractl.md
public_infra-skeleton-tools_v0.zip OR public repo access
<private-project-bundle-or-root>
organ transition files if not already in the bundle:
  01_B0_transition_to_real_organs_master_v2.md
  01_B1_transition_real_organs_codex_batch_plan_v2.md
  day_to_day_organs_run.md
```

Say:

```text
Use infractl.md and infractl.zip.

Task:
Create registered organ run (R01 initial-scaffold example).

Route:
MODE=request-create
TRACK=organ
PHASE=P1
ORGAN_RUN=R01

Read infractl.md first.
Read the root main v7 DOT next.
Then use the P1 DOT from dots/request-create-organs/.

Suggest the full variable block first.
Ask me to confirm or correct it.
Do not execute until I confirm.
```

Use DOT:

```text
dots/request-create-organs/P1_request_create_organ_infractl_prompts_only.dot
```

## P2 — create-writing organ

Upload:

```text
infractl.zip
infractl.md
P1 organ request folder
organ transition files if requested
```

Say:

```text
Use infractl.md and infractl.zip.
Continue registered organ run (R01 initial-scaffold example) from P1 output.

Route:
MODE=request-create
TRACK=organ
PHASE=P2
ORGAN_RUN=R01

Read infractl.md first.
Read the root main v7 DOT next.
Then use the P2 DOT from dots/request-create-organs/.

Suggest the variable block first.
Ask me to confirm or correct it.
Do not execute until I confirm.
```

Use DOT:

```text
dots/request-create-organs/P2_create_writing_organ_lane_infractl_prompts_only.dot
```

## P3 — create-package organ

Upload:

```text
infractl.zip
infractl.md
P2 organ create-writing files
```

Say:

```text
Use infractl.md and infractl.zip.
Package the organ R01 create-writing files.

Route:
MODE=request-create
TRACK=organ
PHASE=P3
ORGAN_RUN=R01

Read infractl.md first.
Read the root main v7 DOT next.
Then use the P3 DOT from dots/request-create-organs/.

Suggest the variable block first.
Ask me to confirm or correct it.
Do not execute until I confirm.
```

Use DOT:

```text
dots/request-create-organs/P3_create_package_organ_lane_infractl_prompts_only.dot
```

## P4 — package-to-Codex organ create

Upload:

```text
infractl.zip
infractl.md
P3 organ Codex create pack zip
```

Say:

```text
Use infractl.md and infractl.zip.
Consume the Codex create pack for organ R01.

Route:
MODE=request-create
TRACK=organ
PHASE=P4
ORGAN_RUN=R01

Read infractl.md first.
Read the root main v7 DOT next.
Then use the P4 DOT from dots/request-create-organs/.

Suggest the variable block first.
Ask me to confirm or correct it.
Do not execute until I confirm.
```

Use DOT:

```text
dots/request-create-organs/P4_package_to_codex_organ_lane_infractl_prompts_only.dot
```

## P5 — evidence-return organ create

Upload:

```text
infractl.zip
infractl.md
Codex organ execution output/evidence
organ smoke/evidence report if produced
```

Say:

```text
Use infractl.md and infractl.zip.
Return and snapshot evidence for organ R01.

Route:
MODE=request-create
TRACK=organ
PHASE=P5
ORGAN_RUN=R01

Read infractl.md first.
Read the root main v7 DOT next.
Then use the P5 DOT from dots/request-create-organs/.

Suggest the variable block first.
Ask me to confirm or correct it.
Do not execute until I confirm.
```

Use DOT:

```text
dots/request-create-organs/P5_evidence_return_organ_lane_infractl_prompts_only.dot
```

## P6 — next-cycle organ create

Upload:

```text
infractl.zip
infractl.md
P5/G17 organ decision text
updated private bundle export if available
```

Say:

```text
Use infractl.md and infractl.zip.
Choose the next cycle after registered organ run (R01 initial-scaffold example).

Route:
MODE=request-create
TRACK=organ
PHASE=P6
ORGAN_RUN=R01

Read infractl.md first.
Read the root main v7 DOT next.
Then use the P6 DOT from dots/request-create-organs/.

Suggest the next route first.
Ask me to confirm or correct it.
Do not execute until I confirm.
```

Use DOT:

```text
dots/request-create-organs/P6_next_cycle_organ_lane_infractl_prompts_only.dot
```

---

# Route 4 — update organ scaffold

Use this only after organ R01 or another organ route already exists and has real organ evidence. Do not use this route for skeleton evidence.

## P1 — request-update organ

Upload:

```text
infractl.zip
infractl.md
public_infra-skeleton-tools_v0.zip OR public repo access
<private-project-bundle-or-root>
prior selected-organ evidence
organ transition files if requested
optional extra source files for the update topic
```

Say:

```text
Use infractl.md and infractl.zip.

Task:
Update organ R01 for topic <TOPIC>.

Route:
MODE=request-update
TRACK=organ
PHASE=P1
ORGAN_RUN=R01
TOPIC=<TOPIC>
EVIDENCE_REQUIRED=yes

Read infractl.md first.
Read the root main v7 DOT next.
Then use the P1 DOT from dots/request-update-organs/.

Suggest the full variable block first.
Ask me to confirm or correct it.
Do not execute until I confirm.
```

Use DOT:

```text
dots/request-update-organs/P1_request_update_organ_infractl_prompts_only.dot
```

## P2 — update-writing organ

Upload:

```text
infractl.zip
infractl.md
P1 organ request-update folder
prior organ evidence check output
```

Say:

```text
Use infractl.md and infractl.zip.
Continue organ R01 update for topic <TOPIC>.

Route:
MODE=request-update
TRACK=organ
PHASE=P2
ORGAN_RUN=R01
TOPIC=<TOPIC>

Read infractl.md first.
Read the root main v7 DOT next.
Then use the P2 DOT from dots/request-update-organs/.

Suggest the variable block first.
Ask me to confirm or correct it.
Do not execute until I confirm.
```

Use DOT:

```text
dots/request-update-organs/P2_update_writing_organ_lane_infractl_prompts_only.dot
```

## P3 — update-package organ

Upload:

```text
infractl.zip
infractl.md
P2 organ update-writing files
```

Say:

```text
Use infractl.md and infractl.zip.
Package the organ R01 update-writing files for topic <TOPIC>.

Route:
MODE=request-update
TRACK=organ
PHASE=P3
ORGAN_RUN=R01
TOPIC=<TOPIC>

Read infractl.md first.
Read the root main v7 DOT next.
Then use the P3 DOT from dots/request-update-organs/.

Suggest the variable block first.
Ask me to confirm or correct it.
Do not execute until I confirm.
```

Use DOT:

```text
dots/request-update-organs/P3_update_package_organ_lane_infractl_prompts_only.dot
```

## P4 — package-to-Codex organ update

Upload:

```text
infractl.zip
infractl.md
P3 organ Codex update pack zip
```

Say:

```text
Use infractl.md and infractl.zip.
Consume the Codex update pack for organ R01 topic <TOPIC>.

Route:
MODE=request-update
TRACK=organ
PHASE=P4
ORGAN_RUN=R01
TOPIC=<TOPIC>

Read infractl.md first.
Read the root main v7 DOT next.
Then use the P4 DOT from dots/request-update-organs/.

Suggest the variable block first.
Ask me to confirm or correct it.
Do not execute until I confirm.
```

Use DOT:

```text
dots/request-update-organs/P4_package_to_codex_update_organ_lane_infractl_prompts_only.dot
```

## P5 — evidence-return organ update

Upload:

```text
infractl.zip
infractl.md
Codex organ update evidence output
organ smoke/evidence report if produced or reused
```

Say:

```text
Use infractl.md and infractl.zip.
Return and snapshot evidence for organ R01 topic <TOPIC>.

Route:
MODE=request-update
TRACK=organ
PHASE=P5
ORGAN_RUN=R01
TOPIC=<TOPIC>

Read infractl.md first.
Read the root main v7 DOT next.
Then use the P5 DOT from dots/request-update-organs/.

Suggest the variable block first.
Ask me to confirm or correct it.
Do not execute until I confirm.
```

Use DOT:

```text
dots/request-update-organs/P5_evidence_return_update_organ_lane_infractl_prompts_only.dot
```

## P6 — next-cycle organ update

Upload:

```text
infractl.zip
infractl.md
P5/G17 organ update decision text
updated private bundle export if available
```

Say:

```text
Use infractl.md and infractl.zip.
Choose the next cycle after organ R01 update topic <TOPIC>.

Route:
MODE=request-update
TRACK=organ
PHASE=P6
ORGAN_RUN=R01
TOPIC=<TOPIC>

Read infractl.md first.
Read the root main v7 DOT next.
Then use the P6 DOT from dots/request-update-organs/.

Suggest the next route first.
Ask me to confirm or correct it.
Do not execute until I confirm.
```

Use DOT:

```text
dots/request-update-organs/P6_next_cycle_update_organ_lane_infractl_prompts_only.dot
```

---

# Current real-zip note

This guide preserves the original 0A/0B/0C and P1-P6 route instructions and adds the `config-infra/` CIP route family found in the current real `infractl.zip`.

Use the updated public export pair together:

```text
infractl.md
infractl.zip
```

For Config-Infra work, start with the CIP router prompt unless you already know the exact CIP phase.

---

# Generic precise P1-P6 InfraCTL prompt template

Use this reusable template for any normal InfraCTL P1-P6 phase across create/update, skeleton/organ, and webchat/Codex contexts.

```text
Use the uploaded public InfraCTL files, uploaded private project bundle, and any phase-specific input artifacts.

Task:
Run InfraCTL phase <PHASE> for <TRACK> <BATCH_OR_RUN>.

Route:
MODE=<request-create | request-update>
TRACK=<skeleton | organ>
PHASE=<P1 | P2 | P3 | P4 | P5 | P6>
BATCH_NUMBER=<registered skeleton id> or ORGAN_RUN=<registered organ run>
BATCH_SLUG=<batch-or-run-slug>
TOPIC=<topic-or-run-purpose>
PROFILE=<webchat-sandbox | real-workspace | codex-pack>
ALLOW_OVERWRITE=<yes | no>

Input from previous phase:
Use the completed <PREVIOUS_PHASE> output:

<PATH_OR_FILENAME_OF_PREVIOUS_PHASE_OUTPUT>

Expected previous-phase contents include:

* <required-file-1>
* <required-file-2>
* <required-file-3>
* <optional-file-if-present>

Also use:

* public InfraCTL files / public bundle / public code-analysis output
* private project bundle:
  <PRIVATE_BUNDLE_FILENAME_OR_PATH>
* relevant evidence package, if this is P5 or later:
  <EVIDENCE_PACKAGE_FILENAME_OR_PATH>

Important distinction:
Main DOT = overall graph/router frame, e.g. G1, G2, G6, G7, G9, G11, G15, G16, G17.
Individual Pn DOT = exact phase contract, gates, inputs, outputs, stop rules, and addressed agent.

Required read order:

1. Read infractl.md first.

2. Inspect the uploaded public InfraCTL files or the public repo/bundle.

3. Read the canonical main DOT next:

dots/infractl_merged_cheatsheet_flow_numbered_cli_extraction.dot

4. Then read exactly this selected phase DOT:

<SELECTED_PHASE_DOT_PATH>

Examples:

P1 create skeleton:
dots/request-create-skeleton/P1_request_create_skeleton_infractl_prompts_only.dot

P2 create skeleton:
dots/request-create-skeleton/P2_create_writing_lane_infractl_prompts_only.dot

P3 create skeleton:
dots/request-create-skeleton/P3_create_package_lane_infractl_prompts_only.dot

P4 create skeleton:
dots/request-create-skeleton/P4_package_to_codex_lane_infractl_prompts_only.dot

P5 create skeleton:
dots/request-create-skeleton/P5_evidence_return_lane_infractl_prompts_only.dot

P6 create skeleton:
dots/request-create-skeleton/P6_next_cycle_lane_infractl_prompts_only.dot

P1 update skeleton:
dots/request-update-skeleton/P1_request_update_skeleton_infractl_prompts_only.dot

P2 update skeleton:
dots/request-update-skeleton/P2_update_writing_lane_infractl_prompts_only.dot

P3 update skeleton:
dots/request-update-skeleton/P3_update_package_lane_infractl_prompts_only.dot

P4 update skeleton:
dots/request-update-skeleton/P4_package_to_codex_update_skeleton_lane_infractl_prompts_only.dot

P5 update skeleton:
dots/request-update-skeleton/P5_evidence_return_update_skeleton_lane_infractl_prompts_only.dot

P6 update skeleton:
dots/request-update-skeleton/P6_next_cycle_update_skeleton_lane_infractl_prompts_only.dot

P1 create organ:
dots/request-create-organs/P1_request_create_organ_infractl_prompts_only.dot

P2 create organ:
dots/request-create-organs/P2_create_writing_organ_lane_infractl_prompts_only.dot

P3 create organ:
dots/request-create-organs/P3_create_package_organ_lane_infractl_prompts_only.dot

P4 create organ:
dots/request-create-organs/P4_package_to_codex_organ_lane_infractl_prompts_only.dot

P5 create organ:
dots/request-create-organs/P5_evidence_return_organ_lane_infractl_prompts_only.dot

P6 create organ:
dots/request-create-organs/P6_next_cycle_organ_lane_infractl_prompts_only.dot

P1 update organ:
dots/request-update-organs/P1_request_update_organ_infractl_prompts_only.dot

P2 update organ:
dots/request-update-organs/P2_update_writing_organ_lane_infractl_prompts_only.dot

P3 update organ:
dots/request-update-organs/P3_update_package_organ_lane_infractl_prompts_only.dot

P4 update organ:
dots/request-update-organs/P4_package_to_codex_update_organ_lane_infractl_prompts_only.dot

P5 update organ:
dots/request-update-organs/P5_evidence_return_update_organ_lane_infractl_prompts_only.dot

P6 update organ:
dots/request-update-organs/P6_next_cycle_update_organ_lane_infractl_prompts_only.dot

5. Read the private project-contract files before producing phase output:

* project.yaml
* batches.yaml
* files.yaml
* hooks.yaml
* layers.yaml, if relevant
* relevant generated/evidence snapshot structure for the selected batch/run, if present

6. Read the previous-phase output or evidence package before producing phase output.

Execution discipline / guardrails:

* Do not invent missing requirements, filenames, phase meanings, evidence, paths, commands, test results, or outputs.
* Do not improvise around the DOT files.
* Do not skip gates, validation steps, stop conditions, PASS/WARN/STOP reporting, or required handoffs.
* Do not merge this with a different track, mode, zero lane, or CIP route unless the selected phase DOT explicitly routes there.
* Do not treat one batch as another batch.
* Do not continue to the next phase unless the current phase reaches its PASS/WARN condition and I explicitly confirm the next phase.
* Do not overwrite anything silently. ALLOW_OVERWRITE=yes permits draft overwrite only after you show the exact target outputs and I confirm the variable block.
* If a required input is missing, stop and report exactly what is missing. Do not fabricate placeholder evidence.
* If the main DOT and selected Pn DOT appear to conflict, stop and report the conflict instead of choosing silently.
* If the selected Pn DOT says the addressed agent is Codex or WSL/operator, do not pretend to execute Codex from ChatGPT. Produce the exact Codex or WSL handoff prompt and stop.
* Do not run smoke, mutate the private workspace, mutate `/mnt/egress`, or apply changes unless the selected Pn DOT explicitly addresses the correct agent and all required confirmations are present.
* Do not use `/mnt/ingress` as an active validation root unless the current selected DOT explicitly says it is authoritative for this run.
* Treat earlier phase outputs as evidence inputs only, not as permission to skip current-phase gates.

Source-of-truth order:

1. The selected Pn DOT is the phase-specific execution contract.
2. The main DOT is the overall graph/router frame only.
3. The current phase input package/evidence is the phase-input source of truth.
4. The uploaded private project bundle is the project-contract source of truth.
5. The uploaded public InfraCTL files are the router/tooling source of truth.
6. Prior chat summaries are advisory only and must not override files.

Main-DOT appreciation requirement:
While executing this phase, explicitly show where we are in the overall main DOT flow.

For each major step, report:

* Main phase / graph node, for example G.. if present in the main DOT
* Lane phase: <PHASE>
* What that phase does in plain English
* Which specific selected Pn DOT instruction you are following
* What input artifact, evidence, or file check supports the action
* Result: PASS, WARN, or STOP

DOT adherence requirement:
You must explicitly confirm that:

* The main DOT was used only as the routing frame.
* The selected Pn DOT was used as the phase-specific execution contract.
* No other Pn, organ, skeleton, update, create, zero, or CIP DOT was executed unless the selected DOT explicitly routed there.
* Previous phase outputs were treated as evidence inputs only, not as permission to skip current-phase gates.

Phase expected behavior:

For P1:
* Validate route identity.
* Propose/request the correct batch/update/organ variables.
* Confirm prerequisites.
* Produce the request/create/update direction artifact required by the selected P1 DOT.
* Stop after P1 unless I confirm P2.

For P2:
* Validate P1 output.
* Read required private sources and hooks.
* Produce writing-lane artifacts required by the selected P2 DOT.
* Preserve route identity.
* Stop after P2 unless I confirm P3.

For P3:
* Validate P2 writing artifacts.
* Package the Codex/create/update handoff according to the selected P3 DOT.
* Include all required manifests, requirement files, and handoff prompts.
* Stop after P3 unless I confirm P4.

For P4:
* Validate the P3 handoff pack.
* Validate the embedded Codex implementation pack.
* Validate public/private layout gates.
* Confirm route identity and package completeness.
* Produce the exact Codex/WSL execution handoff prompt if P4 is a handoff phase.
* Stop after P4. Do not run Codex unless the selected P4 DOT explicitly addresses this session as Codex.

For P5:
* Validate returned implementation evidence.
* Confirm required evidence exists.
* Confirm evidence identity matches the route.
* Confirm implementation stayed within scope.
* Confirm no forbidden actions occurred.
* Classify smoke as PASS/WARN/STOP according to the selected P5 DOT.
* Consider G16 snapshot/import only according to the selected P5 DOT and addressed agent.
* Produce P5 evidence-return closeout content.
* Stop after P5 unless I confirm P6.

For P6:
* Validate P5/G17 decision.
* Determine the next route.
* Recommend whether to continue to the next batch, update current batch, generate/update a companion, run CIP, run 0C, or stop.
* Do not start the next route unless I explicitly confirm.

Route identity to validate:

MODE=<request-create | request-update>
TRACK=<skeleton | organ>
PHASE=<P1 | P2 | P3 | P4 | P5 | P6>
BATCH_NUMBER=<batch-number-or-run-id>
BATCH_SLUG=<batch-slug>
TOPIC=<topic>
PROFILE=<webchat-sandbox | real-workspace | codex-pack>

Allowed actions in ChatGPT/webchat:

* inspect uploaded files
* extract uploaded zips in the sandbox if needed
* read relevant Markdown/JSON/YAML/text files
* produce phase report text
* produce draft closeout artifact text in the answer
* classify PASS/WARN/STOP from evidence
* prepare Codex/WSL/operator prompts when the selected DOT addresses another agent

Forbidden actions in ChatGPT/webchat:

* mutate the real workspace
* mutate `/mnt/egress`
* mutate public/private source repos
* run implementation
* run new smoke against the real workspace
* import snapshots into the real private bundle
* continue to the next phase without confirmation
* rewrite evidence as if it were canonical
* silently repair evidence
* invent missing files or test results

Idempotency:

* If equivalent phase closeout artifacts already exist in the uploaded private bundle, compare and report whether they are consistent.
* Do not overwrite them in webchat.
* If producing draft artifact text, label it as draft/proposed, not applied.
* Same inputs must produce the same PASS/WARN/STOP classification.
* If ALLOW_OVERWRITE=no and target outputs exist, STOP unless the selected DOT provides an alternate versioned-output rule.

Expected output:
Produce the phase closeout content in chat only unless the selected DOT and addressed agent allow file creation.

Use this deterministic final section order:

1. Selected route
2. Selected main DOT
3. Selected phase DOT
4. Addressed agent
5. Proposed/confirmed variable block
6. Source-of-truth files read
7. Phase input files read
8. Main-DOT position / graph appreciation
9. Required input checklist
10. Route identity validation
11. Phase-specific validation
12. Scope and safety validation
13. Missing / rejected / deferred items
14. Draft phase artifacts or handoff prompt
15. Snapshot/import decision, if applicable
16. G17 / next-phase decision, if applicable
17. Recommended next action
18. PASS / WARN / STOP

Decision rules:

* PASS only if required inputs exist, identity matches, phase gates pass, scope is clean, and no forbidden action occurred.
* WARN only if required inputs exist, identity matches, scope is clean, no forbidden action occurred, and warnings are documented/accepted by the selected DOT.
* STOP if required input is missing, identity is contradicted, required validation fails, scope expanded, forbidden action occurred, evidence is contradictory, or addressed-agent authority is wrong.

First response required:
Before doing any execution, return only:

1. Selected route
2. Selected main DOT
3. Selected phase DOT
4. Addressed agent
5. Proposed variable block with every variable labeled as:
   - user-provided
   - inferred
   - default-safe
   - unknown
6. Missing prerequisites, if any
7. Confirmation question

Do not execute until I confirm.
```

---

## Generic precise prompt template for Config-Infra CIP01-CIP06

Use this template for Config-Infra Pipeline phases CIP01 through CIP06. Fill only the route block, selected CIP DOT path, current input artifacts, and expected files.

```text
Use the uploaded public InfraCTL files, uploaded private project bundle, and any CIP phase-specific input artifacts.

Task:
Run InfraCTL Config-Infra phase <CIP_PHASE> for <CIP_TOPIC>.

Route:
MODE=config-infra
TRACK=cip
PHASE=<CIP01 | CIP02 | CIP03 | CIP04 | CIP05 | CIP06>
CIP_RUN_SLUG=<stable-cip-run-slug>
CIP_TOPIC=<topic-or-manifest-name>
PROFILE=<webchat-sandbox | real-workspace | codex-pack>
ALLOW_OVERWRITE=<yes | no>
ALLOW_CONFIG_MUTATION=<no | yes-only-for-CIP06-after-confirmation>

Input from previous phase:
Use the completed <PREVIOUS_CIP_PHASE> output:

<PATH_OR_FILENAME_OF_PREVIOUS_CIP_OUTPUT>

Expected previous-phase contents include:

* <required-file-1>
* <required-file-2>
* <required-file-3>
* <optional-file-if-present>

Also use:

* public InfraCTL files / public bundle / public code-analysis output
* private project bundle:
  <PRIVATE_BUNDLE_FILENAME_OR_PATH>
* relevant batch/organ evidence, integration requests, manifests, snapshots, plans, or closeout files, if this CIP phase requires them:
  <CIP_INPUT_PACKAGE_OR_EVIDENCE_PATH>

Important distinction:
Main DOT = overall graph/router frame, e.g. G1, G2, G6, G7, G9, G11, G15, G16, G17.
Individual CIP DOT = exact CIP phase contract, gates, inputs, outputs, stop rules, and addressed agent.

Required read order:

1. Read infractl.md first.

2. Inspect the uploaded public InfraCTL files or the public repo/bundle.

3. Read the canonical main DOT next:

dots/infractl_merged_cheatsheet_flow_numbered_cli_extraction.dot

4. Then read exactly this selected CIP DOT:

<SELECTED_CIP_DOT_PATH>

Examples:

CIP01:
dots/config-infra/CIP01_source_intake_and_suitability_determination_infractl_prompts_only.dot

CIP02:
dots/config-infra/CIP02_rich_integration_request_generation_infractl_prompts_only.dot

CIP03:
dots/config-infra/CIP03_manifest_aggregation_and_approval_infractl_prompts_only.dot

CIP04:
dots/config-infra/CIP04_live_config_state_resolution_infractl_prompts_only.dot

CIP05:
dots/config-infra/CIP05_config_implementation_planning_infractl_prompts_only.dot

CIP06:
dots/config-infra/CIP06_idempotent_application_and_closeout_infractl_prompts_only.dot

5. Read the private project-contract files before producing CIP output:

* project.yaml
* batches.yaml
* files.yaml
* hooks.yaml
* layers.yaml, if relevant
* sources/specifications/annex/SPEC_config_infra_integration_pipeline-ANX*.md files required by the selected CIP DOT, if present
* sources/implementation/HOOKS/HOOK_config_infra_*.md file required by the selected CIP DOT, if present
* relevant generated/evidence snapshot structure for the selected run, if present

6. Read the CIP input artifacts before producing CIP output.

Execution discipline / guardrails:

* Do not invent missing requirements, filenames, phase meanings, evidence, paths, commands, test results, live-state facts, approvals, or outputs.
* Do not improvise around the DOT files.
* Do not skip gates, validation steps, stop conditions, PASS/WARN/STOP reporting, or required handoffs.
* Do not merge this with skeleton/organ P1-P6, zero lanes, or a different CIP phase unless the selected CIP DOT explicitly routes there.
* Do not continue to the next CIP phase unless the current CIP phase reaches its PASS/WARN condition and I explicitly confirm the next phase.
* Do not overwrite anything silently. ALLOW_OVERWRITE=yes permits draft overwrite only after you show the exact target outputs and I confirm the variable block.
* If a required input is missing, stop and report exactly what is missing. Do not fabricate placeholder evidence.
* If the main DOT and selected CIP DOT appear to conflict, stop and report the conflict instead of choosing silently.
* If the selected CIP DOT says the addressed agent is Codex or WSL/operator, do not pretend to execute Codex from ChatGPT. Produce the exact Codex or WSL handoff prompt and stop.
* CIP01-CIP05 are read-only / planning-only by default.
* CIP06 is mutation-default-no and may mutate only after manifest approval, live-state snapshot, implementation plan, exact touch set, selected CIP06 DOT, and explicit operator confirmation.
* Do not run bootstrap, mount, pull, push, package installs, Docker, RunPod, paid APIs, broad smoke, live infra, or destructive account actions unless the selected CIP06 DOT explicitly permits the exact action after confirmation.
* Do not read or print credential contents.
* Do not claim live config truth unless CIP04 has produced or supplied a live config-state snapshot.

Source-of-truth order:

1. The selected CIP DOT is the CIP phase-specific execution contract.
2. The main DOT is the overall graph/router frame only.
3. The current CIP input artifacts are the phase-input source of truth.
4. The uploaded private project bundle is the project-contract source of truth.
5. The uploaded public InfraCTL files are the router/tooling source of truth.
6. Prior chat summaries are advisory only and must not override files.

Main-DOT appreciation requirement:
While executing this CIP phase, explicitly show where we are in the overall main DOT flow.

For each major step, report:

* Main phase / graph node, for example G.. if present in the main DOT
* CIP phase: <CIP_PHASE>
* What that CIP phase does in plain English
* Which specific selected CIP DOT instruction you are following
* What input artifact, evidence, or file check supports the action
* Result: PASS, WARN, or STOP

DOT adherence requirement:
You must explicitly confirm that:

* The main DOT was used only as the routing frame.
* The selected CIP DOT was used as the phase-specific execution contract.
* No skeleton/organ Pn, zero, or other CIP DOT was executed unless the selected DOT explicitly routed there.
* Previous phase outputs were treated as evidence inputs only, not as permission to skip current CIP gates.

CIP phase expected behavior:

For CIP01:
* Perform source intake and suitability determination.
* Apply the config-infra suitability determiner.
* Produce or draft CONFIG_INFRA_SUITABILITY_DECISION.md/json.
* Do not generate INTEGRATION_REQUEST.md unless the selected DOT explicitly permits a combined route and I confirm.

For CIP02:
* Validate CIP01 decision input.
* Generate or retrofit a rich INTEGRATION_REQUEST.md/json according to the selected DOT and source contract.
* Preserve batch-time suitability truth.
* Do not claim live config truth.

For CIP03:
* Validate source INTEGRATION_REQUEST files.
* Aggregate requests into INTEGRATION_MANIFEST.md/json.
* Classify approved, deferred, blocked, duplicate, already covered, or rejected items.
* Do not resolve live config state.

For CIP04:
* Validate manifest context or explicit read-only live-state request.
* Resolve current live config/tooling state in read-only mode only.
* Produce CONFIG_STATE_SNAPSHOT.md/json and CIP04_POSTCHECK.md.
* Do not plan or apply changes.

For CIP05:
* Validate CIP03 manifest and CIP04 snapshot.
* Produce CONFIG_INTEGRATION_PLAN.md/json and CIP05_POSTCHECK.md.
* Select patch/application classes and exact proposed touch set.
* Do not apply changes.

For CIP06:
* Validate manifest approval, live-state snapshot, implementation plan, selected CIP06 DOT, and explicit operator confirmation.
* Apply only the approved exact touch set if the selected DOT and confirmation permit it.
* Produce CONFIG_INTEGRATION_CLOSEOUT_REPORT.md/json and CIP06_POSTCHECK.md.
* Stop on any missing approval, ambiguous touch set, secret/live/destructive risk, or validation failure.

Route identity to validate:

MODE=config-infra
TRACK=cip
PHASE=<CIP01 | CIP02 | CIP03 | CIP04 | CIP05 | CIP06>
CIP_RUN_SLUG=<stable-cip-run-slug>
CIP_TOPIC=<topic-or-manifest-name>
PROFILE=<webchat-sandbox | real-workspace | codex-pack>
ALLOW_OVERWRITE=<yes | no>
ALLOW_CONFIG_MUTATION=<no | yes-only-for-CIP06-after-confirmation>

Allowed actions in ChatGPT/webchat:

* inspect uploaded files
* extract uploaded zips in the sandbox if needed
* read relevant Markdown/JSON/YAML/text files
* produce CIP report text
* produce draft CIP artifact text in the answer
* classify PASS/WARN/STOP from evidence
* prepare Codex/WSL/operator prompts when the selected DOT addresses another agent

Forbidden actions in ChatGPT/webchat:

* mutate the real workspace
* mutate /mnt/egress
* mutate public/private source repos
* run bootstrap, mount, pull, push, package installs, Docker, RunPod, paid APIs, broad smoke, or live infra
* read or print credential contents
* apply config changes
* continue to the next CIP phase without confirmation
* rewrite evidence as if it were canonical
* silently repair evidence
* invent missing files, live-state facts, approvals, or test results

Idempotency:

* If equivalent CIP closeout artifacts already exist in the uploaded private bundle, compare and report whether they are consistent.
* Do not overwrite them in webchat.
* If producing draft artifact text, label it as draft/proposed, not applied.
* Same inputs must produce the same PASS/WARN/STOP classification.
* If ALLOW_OVERWRITE=no and target outputs exist, STOP unless the selected DOT provides an alternate versioned-output rule.

Expected output:
Produce the CIP closeout content in chat only unless the selected DOT and addressed agent allow file creation.

Use this deterministic final section order:

1. Selected route
2. Selected main DOT
3. Selected CIP DOT
4. Addressed agent
5. Proposed/confirmed variable block
6. Source-of-truth files read
7. CIP input files read
8. Main-DOT position / graph appreciation
9. Required input checklist
10. Route identity validation
11. CIP-specific validation
12. Config/live-state/safety validation
13. Missing / rejected / deferred items
14. Draft CIP artifacts or handoff prompt
15. Live-state / application decision, if applicable
16. Recommended next action
17. PASS / WARN / STOP

Decision rules:

* PASS only if required inputs exist, identity matches, CIP gates pass, scope is clean, and no forbidden action occurred.
* WARN only if required inputs exist, identity matches, scope is clean, no forbidden action occurred, and warnings are documented/accepted by the selected DOT.
* STOP if required input is missing, identity is contradicted, required validation fails, scope expanded, forbidden action occurred, evidence is contradictory, live-state truth is asserted without CIP04 evidence, or addressed-agent authority is wrong.

First response required:
Before doing any execution, return only:

1. Selected route
2. Selected main DOT
3. Selected CIP DOT
4. Addressed agent
5. Proposed variable block with every variable labeled as:
   - user-provided
   - inferred
   - default-safe
   - unknown
6. Missing prerequisites, if any
7. Confirmation question

Do not execute until I confirm.
```

---

## Generic precise prompt template for zero-abc lanes 0A/0C

This legacy general template is retained only for 0A setup and 0C tooling-feedback lanes. **Do not use it for 0B.** Every 0B prompt must use the canonical master template in `## 0B — expansion lane (canonical master template)` above.

```text
Use the uploaded public InfraCTL files, uploaded private project bundle, and any zero-lane-specific input artifacts.

0B exclusion: this template is invalid for `ZERO_LANE=0B`; use the canonical 0B master template above.

Task:
Run InfraCTL zero lane <ZERO_LANE> for <ZERO_TOPIC>.

Route:
ZERO_LANE=<0A | 0C>
PHASE=<public-private-contract-preflight | cli-extraction-feedback>
ZERO_TOPIC=<topic-or-issue>
PROFILE=<webchat-sandbox | real-workspace | codex-pack>
ALLOW_OVERWRITE=<yes | no>

Input artifacts:
Use these inputs:

* <public bundle or public repo/code-analysis>
* <private project bundle or private repo/code-analysis>
* <source files, notes, specs, annexes, evidence, helper scripts, bug reports, or workflow-friction artifacts>

Important distinction:
Main DOT = overall graph/router frame, e.g. G1, G2, G6, G7, G9, G11, G15, G16, G17.
Individual zero DOT = exact zero-lane contract, gates, inputs, outputs, stop rules, and addressed agent.

Required read order:

1. Read infractl.md first.

2. Inspect the uploaded public InfraCTL files or the public repo/bundle.

3. Read the canonical main DOT next:

dots/infractl_merged_cheatsheet_flow_numbered_cli_extraction.dot

4. Then read exactly this selected zero DOT:

<SELECTED_ZERO_DOT_PATH>

Examples:

0A:
dots/zero-abc/0A_public_private_contract_infractl_prompts_only.dot


0C:
dots/zero-abc/0C_cli_extraction_feedback_infractl_prompts_only.dot

5. Read the private project-contract files if relevant:

* project.yaml
* batches.yaml
* files.yaml
* hooks.yaml
* layers.yaml, if relevant
* relevant sources/generated/evidence snapshot structure if the selected zero DOT requires it

6. Read the zero-lane input artifacts before producing output.

Execution discipline / guardrails:

* Do not invent missing requirements, filenames, phase meanings, evidence, paths, commands, test results, roots, contracts, helper behavior, or outputs.
* Do not improvise around the DOT files.
* Do not skip gates, validation steps, stop conditions, PASS/WARN/STOP reporting, or required handoffs.
* Do not merge this with skeleton/organ P1-P6 or CIP routes unless the selected zero DOT explicitly routes there.
* Do not continue to any follow-up route unless the zero lane reaches its PASS/WARN condition and I explicitly confirm the next route.
* Do not overwrite anything silently. ALLOW_OVERWRITE=yes permits draft overwrite only after you show the exact target outputs and I confirm the variable block.
* If a required input is missing, stop and report exactly what is missing. Do not fabricate placeholder evidence.
* If the main DOT and selected zero DOT appear to conflict, stop and report the conflict instead of choosing silently.
* If the selected zero DOT says the addressed agent is Codex or WSL/operator, do not pretend to execute Codex from ChatGPT. Produce the exact Codex or WSL handoff prompt and stop.
* Do not run implementation, smoke, config mutation, batch creation/update, organ creation/update, or snapshot import unless the selected zero DOT explicitly permits it and addresses the correct agent.
* Do not use /mnt/ingress as an active validation root unless the current selected zero DOT explicitly says it is authoritative for this run.

Source-of-truth order:

1. The selected zero DOT is the zero-lane-specific execution contract.
2. The main DOT is the overall graph/router frame only.
3. The zero-lane input artifacts are the lane-input source of truth.
4. The uploaded private project bundle is the project-contract source of truth when applicable.
5. The uploaded public InfraCTL files are the router/tooling source of truth.
6. Prior chat summaries are advisory only and must not override files.

Main-DOT appreciation requirement:
While executing this zero lane, explicitly show where we are in the overall main DOT flow.

For each major step, report:

* Main phase / graph node, for example G.. if present in the main DOT
* Zero lane: <0A | 0C>
* What that zero lane does in plain English
* Which specific selected zero DOT instruction you are following
* What input artifact, evidence, or file check supports the action
* Result: PASS, WARN, or STOP

DOT adherence requirement:
You must explicitly confirm that:

* The main DOT was used only as the routing frame.
* The selected zero DOT was used as the lane-specific execution contract.
* No Pn, CIP, skeleton, organ, create, or update DOT was executed unless the selected zero DOT explicitly routed there.
* Prior outputs were treated as evidence inputs only, not as permission to skip current zero-lane gates.

Zero lane expected behavior:

For 0A:
* Validate public/private setup and contract roots.
* Distinguish public tool/router root from private project-contract root.
* Identify missing or contradictory files.
* Validate whether a normal P-lane or CIP route may proceed.
* Do not patch unless the selected 0A DOT explicitly permits a patch route and I confirm.


For 0C:
* Record reusable CLI/helper/workflow extraction opportunities.
* Identify repeated manual friction, helper candidates, router/DOT corrections, packaging helpers, validation helpers, or script candidates.
* Produce a precise extraction note, patch scope, or Codex/WSL prompt if appropriate.
* Do not implement broad CLI changes unless the selected 0C DOT and addressed agent permit it after confirmation.

Route identity to validate:

ZERO_LANE=<0A | 0C>
PHASE=<public-private-contract-preflight | cli-extraction-feedback>
ZERO_TOPIC=<topic-or-issue>
PROFILE=<webchat-sandbox | real-workspace | codex-pack>
ALLOW_OVERWRITE=<yes | no>

Allowed actions in ChatGPT/webchat:

* inspect uploaded files
* extract uploaded zips in the sandbox if needed
* read relevant Markdown/JSON/YAML/text files
* produce zero-lane report text
* produce draft artifacts or extraction notes in the answer
* classify PASS/WARN/STOP from files/evidence
* prepare Codex/WSL/operator prompts when the selected DOT addresses another agent

Forbidden actions in ChatGPT/webchat:

* mutate the real workspace
* mutate /mnt/egress
* mutate public/private source repos
* run implementation
* run smoke against the real workspace
* import snapshots into the real private bundle
* apply config changes
* continue to a P lane, CIP lane, or next zero route without confirmation
* rewrite evidence as if it were canonical
* silently repair evidence
* invent missing files, roots, contracts, helper behavior, or test results

Idempotency:

* If equivalent zero-lane outputs already exist in the uploaded private bundle, compare and report whether they are consistent.
* Do not overwrite them in webchat.
* If producing draft artifact text, label it as draft/proposed, not applied.
* Same inputs must produce the same PASS/WARN/STOP classification.
* If ALLOW_OVERWRITE=no and target outputs exist, STOP unless the selected DOT provides an alternate versioned-output rule.

Expected output:
Produce the zero-lane closeout content in chat only unless the selected DOT and addressed agent allow file creation.

Use this deterministic final section order:

1. Selected route
2. Selected main DOT
3. Selected zero DOT
4. Addressed agent
5. Proposed/confirmed variable block
6. Source-of-truth files read
7. Zero-lane input files read
8. Main-DOT position / graph appreciation
9. Required input checklist
10. Route identity validation
11. Zero-lane-specific validation
12. Scope and safety validation
13. Missing / rejected / deferred items
14. Draft zero-lane artifacts or handoff prompt
15. Recommended next route
16. PASS / WARN / STOP

Decision rules:

* PASS only if required inputs exist, identity matches, zero-lane gates pass, scope is clean, and no forbidden action occurred.
* WARN only if required inputs exist, identity matches, scope is clean, no forbidden action occurred, and warnings are documented/accepted by the selected DOT.
* STOP if required input is missing, identity is contradicted, required validation fails, scope expanded, forbidden action occurred, evidence is contradictory, roots/contracts cannot be trusted, or addressed-agent authority is wrong.

First response required:
Before doing any execution, return only:

1. Selected route
2. Selected main DOT
3. Selected zero DOT
4. Addressed agent
5. Proposed variable block with every variable labeled as:
   - user-provided
   - inferred
   - default-safe
   - unknown
6. Missing prerequisites, if any
7. Confirmation question

Do not execute until I confirm.
```

---

## Generic precise zero-lane prompt template — 0A / 0C

This template is retained only for 0A and 0C. **Do not use it for 0B.** Every 0B request must use the canonical master template in the dedicated 0B section above.

Use the uploaded public InfraCTL files, uploaded private project bundle, and any zero-lane-specific input artifacts.

Task:
Run InfraCTL zero lane <ZERO_LANE> for <ZERO_TASK>.

Route:
MODE=zero
TRACK=<0A-public-private-contract | 0C-cli-extraction>
ZERO_LANE=<0A | 0C>
PHASE=<zero-lane phase label>
TOPIC=<topic-or-run-purpose>
PROFILE=<webchat-sandbox | real-workspace | codex-pack>
ALLOW_OVERWRITE=<yes | no>

Input artifacts:
Use the following input files or folders:

<INPUT_PATH_OR_FILENAME_1>
<INPUT_PATH_OR_FILENAME_2>
<INPUT_PATH_OR_FILENAME_3>

Also use:

* public InfraCTL files / public bundle / public code-analysis output
* private project bundle:
  <PRIVATE_BUNDLE_FILENAME_OR_PATH>
* source/evidence/spec/workflow files relevant to the selected zero lane

Important distinction:
Main DOT = overall graph/router frame, e.g. G1, G2, G6, G7, G9, G11, G15, G16, G17.
Individual zero DOT = exact zero-lane contract, gates, inputs, outputs, stop rules, and addressed agent.

Required read order:

1. Read infractl.md first.

2. Inspect the uploaded public InfraCTL files or the public repo/bundle.

3. Read the canonical main DOT next:

dots/infractl_merged_cheatsheet_flow_numbered_cli_extraction.dot

4. Then read exactly this selected zero-lane DOT:

<SELECTED_ZERO_DOT_PATH>

Examples:

0A public/private contract:
dots/zero-abc/0A_public_private_contract_infractl_prompts_only.dot


0C CLI extraction feedback:
dots/zero-abc/0C_cli_extraction_feedback_infractl_prompts_only.dot

5. Read the private project-contract files before producing zero-lane output, when relevant:

* project.yaml
* batches.yaml
* files.yaml
* hooks.yaml
* layers.yaml, if relevant
* relevant source/evidence/generated structure, if present

6. Read only the source files, evidence files, specs, workflow notes, or artifacts named in the variable block.

Execution discipline / guardrails:

* Do not invent missing requirements, filenames, phase meanings, evidence, paths, commands, test results, or outputs.
* Do not improvise around the DOT files.
* Do not skip gates, validation steps, stop conditions, PASS/WARN/STOP reporting, or required handoffs.
* Do not merge this with a P1-P6 batch lane, organ lane, skeleton lane, update lane, create lane, or CIP route unless the selected zero DOT explicitly routes there.
* Do not continue into a batch phase unless this zero lane reaches its PASS/WARN condition and I explicitly confirm the next route.
* Do not overwrite anything silently. ALLOW_OVERWRITE=yes permits draft overwrite only after you show the exact target outputs and I confirm the variable block.
* If a required input is missing, stop and report exactly what is missing. Do not fabricate placeholder evidence.
* If the main DOT and selected zero DOT appear to conflict, stop and report the conflict instead of choosing silently.
* If the selected zero DOT says the addressed agent is Codex or WSL/operator, do not pretend to execute Codex from ChatGPT. Produce the exact Codex or WSL handoff prompt and stop.
* Do not run smoke, mutate the private workspace, mutate `/mnt/egress`, or apply changes unless the selected zero DOT explicitly addresses the correct agent and all required confirmations are present.
* Do not use `/mnt/ingress` as an active validation root unless the current selected DOT explicitly says it is authoritative for this run.
* Treat prior chat summaries as advisory only, not as source-of-truth evidence.

Source-of-truth order:

1. The selected zero DOT is the zero-lane execution contract.
2. The main DOT is the overall graph/router frame only.
3. The current zero-lane input artifacts are the task-input source of truth.
4. The uploaded private project bundle is the project-contract source of truth.
5. The uploaded public InfraCTL files are the router/tooling source of truth.
6. Prior chat summaries are advisory only and must not override files.

Main-DOT appreciation requirement:
While executing this zero lane, explicitly show where we are in the overall main DOT flow.

For each major step, report:

* Main phase / graph node, for example G.. if present in the main DOT
* Zero lane: <0A | 0C>
* What that zero lane does in plain English
* Which specific selected zero DOT instruction you are following
* What input artifact, evidence, or file check supports the action
* Result: PASS, WARN, or STOP

DOT adherence requirement:
You must explicitly confirm that:

* The main DOT was used only as the routing frame.
* The selected zero DOT was used as the zero-lane execution contract.
* No P1-P6, organ, skeleton, update, create, or CIP DOT was executed unless the selected zero DOT explicitly routed there.
* Any batch/evidence/source artifacts were treated as inputs only, not as permission to skip zero-lane gates.

Zero-lane expected behavior:

For 0A:
* Validate public/private setup.
* Confirm public tool root and private project root.
* Confirm expected public files, private project files, DOT tree, schemas, scripts, and source maps.
* Identify contract contradictions, missing paths, stale root assumptions, or unsafe routing conditions.
* Produce a public/private contract preflight report.
* Stop after 0A unless I confirm a follow-up lane.


For 0C:
* Record reusable tooling, helper, CLI extraction, workflow friction, repeated manual steps, or router issues.
* Decide whether the issue belongs in public CLI, public docs, DOTs, private workflow notes, CLI_EXTRACTION_NOTES, or a later scoped patch.
* Produce a CLI extraction feedback report or scoped patch prompt.
* Stop after 0C unless I confirm execution of the patch or next route.

Route identity to validate:

MODE=zero
TRACK=<0A-public-private-contract | 0C-cli-extraction>
ZERO_LANE=<0A | 0C>
PHASE=<zero-lane phase label>
TOPIC=<topic>
PROFILE=<webchat-sandbox | real-workspace | codex-pack>

Allowed actions in ChatGPT/webchat:

* inspect uploaded files
* extract uploaded zips in the sandbox if needed
* read relevant Markdown/JSON/YAML/text files
* produce zero-lane report text
* produce draft closeout artifact text in the answer
* classify PASS/WARN/STOP from evidence
* prepare Codex/WSL/operator prompts when the selected DOT addresses another agent

Forbidden actions in ChatGPT/webchat:

* mutate the real workspace
* mutate `/mnt/egress`
* mutate public/private source repos
* run implementation
* run new smoke against the real workspace
* import snapshots into the real private bundle
* continue to another lane without confirmation
* rewrite evidence as if it were canonical
* silently repair evidence
* invent missing files or test results

Idempotency:

* If equivalent zero-lane closeout artifacts already exist in the uploaded private bundle, compare and report whether they are consistent.
* Do not overwrite them in webchat.
* If producing draft artifact text, label it as draft/proposed, not applied.
* Same inputs must produce the same PASS/WARN/STOP classification.
* If ALLOW_OVERWRITE=no and target outputs exist, STOP unless the selected DOT provides an alternate versioned-output rule.

Expected output:
Produce the zero-lane closeout content in chat only unless the selected DOT and addressed agent allow file creation.

Use this deterministic final section order:

1. Selected route
2. Selected main DOT
3. Selected zero DOT
4. Addressed agent
5. Proposed/confirmed variable block
6. Source-of-truth files read
7. Zero-lane input files read
8. Main-DOT position / graph appreciation
9. Required input checklist
10. Route identity validation
11. Zero-lane-specific validation
12. Scope and safety validation
13. Missing / rejected / deferred items
14. Draft zero-lane artifacts or handoff prompt
15. Recommended next action
16. PASS / WARN / STOP

Decision rules:

* PASS only if required inputs exist, identity matches, zero-lane gates pass, scope is clean, and no forbidden action occurred.
* WARN only if required inputs exist, identity matches, scope is clean, no forbidden action occurred, and warnings are documented/accepted by the selected zero DOT.
* STOP if required input is missing, identity is contradicted, required validation fails, scope expanded, forbidden action occurred, evidence is contradictory, or addressed-agent authority is wrong.

First response required:
Before doing any execution, return only:

1. Selected route
2. Selected main DOT
3. Selected zero DOT
4. Addressed agent
5. Proposed variable block with every variable labeled as:
   - user-provided
   - inferred
   - default-safe
   - unknown
6. Missing prerequisites, if any
7. Confirmation question

Do not execute until I confirm.

---

## Generic precise Config-Infra CIP prompt template — CIP01 / CIP02 / CIP03 / CIP04 / CIP05 / CIP06

Use the uploaded public InfraCTL files, uploaded private project bundle, and any Config-Infra CIP input artifacts.

Task:
Run Config-Infra CIP phase <CIP_PHASE> for <CIP_TOPIC>.

Route:
MODE=config-infra
TRACK=cip
PHASE=<CIP01 | CIP02 | CIP03 | CIP04 | CIP05 | CIP06>
CIP_RUN_SLUG=<stable-cip-run-slug>
TOPIC=<topic-or-run-purpose>
PROFILE=<webchat-sandbox | real-workspace | codex-pack>
ALLOW_OVERWRITE=<yes | no>

Input from previous CIP phase or source:
Use the completed <PREVIOUS_CIP_PHASE_OR_SOURCE> artifact:

<PATH_OR_FILENAME_OF_INPUT_ARTIFACT>

Expected input contents include:

* <required-file-1>
* <required-file-2>
* <required-file-3>
* <optional-file-if-present>

Also use:

* public InfraCTL files / public bundle / public code-analysis output
* private project bundle:
  <PRIVATE_BUNDLE_FILENAME_OR_PATH>
* relevant batch evidence, integration requests, manifests, config snapshots, implementation plans, or operator notes

Important distinction:
Main DOT = overall graph/router frame, e.g. G1, G2, G6, G7, G9, G11, G15, G16, G17.
Individual CIP DOT = exact Config-Infra phase contract, gates, inputs, outputs, stop rules, and addressed agent.

Required read order:

1. Read infractl.md first.

2. Inspect the uploaded public InfraCTL files or the public repo/bundle.

3. Read the canonical main DOT next:

dots/infractl_merged_cheatsheet_flow_numbered_cli_extraction.dot

4. Then read exactly this selected CIP DOT:

<SELECTED_CIP_DOT_PATH>

Examples:

CIP01:
dots/config-infra/CIP01_source_intake_and_suitability_determination_infractl_prompts_only.dot

CIP02:
dots/config-infra/CIP02_rich_integration_request_generation_infractl_prompts_only.dot

CIP03:
dots/config-infra/CIP03_manifest_aggregation_and_approval_infractl_prompts_only.dot

CIP04:
dots/config-infra/CIP04_live_config_state_resolution_infractl_prompts_only.dot

CIP05:
dots/config-infra/CIP05_config_implementation_planning_infractl_prompts_only.dot

CIP06:
dots/config-infra/CIP06_idempotent_application_and_closeout_infractl_prompts_only.dot

5. Read the private project-contract files before producing CIP output:

* project.yaml
* batches.yaml
* files.yaml
* hooks.yaml
* layers.yaml, if relevant
* source/spec/hook registry entries relevant to the selected CIP phase

6. Read only the CIP input artifacts named in the variable block.

Execution discipline / guardrails:

* Do not invent missing requirements, filenames, phase meanings, evidence, paths, commands, test results, or outputs.
* Do not improvise around the DOT files.
* Do not skip gates, validation steps, stop conditions, PASS/WARN/STOP reporting, or required handoffs.
* Do not merge this with a P1-P6 batch lane, organ lane, skeleton lane, update lane, create lane, or zero route unless the selected CIP DOT explicitly routes there.
* Do not continue to the next CIP phase unless the current CIP phase reaches its PASS/WARN condition and I explicitly confirm the next phase.
* Do not overwrite anything silently. ALLOW_OVERWRITE=yes permits draft overwrite only after you show the exact target outputs and I confirm the variable block.
* If a required input is missing, stop and report exactly what is missing. Do not fabricate placeholder evidence.
* If the main DOT and selected CIP DOT appear to conflict, stop and report the conflict instead of choosing silently.
* If the selected CIP DOT says the addressed agent is Codex or WSL/operator, do not pretend to execute Codex from ChatGPT. Produce the exact Codex or WSL handoff prompt and stop.
* Do not run smoke, mutate the private workspace, mutate `/mnt/egress`, mutate live config, run bootstrap, mount, pull, push, install packages, run Docker, run RunPod, call paid APIs, or apply changes unless the selected CIP DOT explicitly addresses the correct agent and all required confirmations are present.
* CIP01-CIP05 are read-only / planning-only by default.
* CIP06 is mutation-default-no and may mutate only after manifest approval, live-state snapshot, implementation plan, exact touch set, selected CIP06 DOT, explicit confirmation, and passing safety gates.
* Do not use `/mnt/ingress` as an active validation root unless the current selected DOT explicitly says it is authoritative for this run.
* Treat earlier CIP or batch outputs as evidence inputs only, not as permission to skip current CIP gates.

Source-of-truth order:

1. The selected CIP DOT is the phase-specific execution contract.
2. The main DOT is the overall graph/router frame only.
3. The current CIP input artifact is the phase-input source of truth.
4. The uploaded private project bundle is the project-contract source of truth.
5. The uploaded public InfraCTL files are the router/tooling source of truth.
6. Prior chat summaries are advisory only and must not override files.

Main-DOT appreciation requirement:
While executing this CIP phase, explicitly show where we are in the overall main DOT flow.

For each major step, report:

* Main phase / graph node, for example G.. if present in the main DOT
* CIP phase: <CIP01 | CIP02 | CIP03 | CIP04 | CIP05 | CIP06>
* What that CIP phase does in plain English
* Which specific selected CIP DOT instruction you are following
* What input artifact, evidence, or file check supports the action
* Result: PASS, WARN, or STOP

DOT adherence requirement:
You must explicitly confirm that:

* The main DOT was used only as the routing frame.
* The selected CIP DOT was used as the Config-Infra phase-specific execution contract.
* No P1-P6, organ, skeleton, update, create, or zero DOT was executed unless the selected CIP DOT explicitly routed there.
* Previous CIP or batch outputs were treated as evidence inputs only, not as permission to skip current CIP gates.

CIP phase expected behavior:

For CIP01:
* Perform source intake and config-infra suitability determination.
* Apply the CONFIG_INFRA_SUITABILITY_DETERMINER.
* Classify evidence strength, recurrence, role fit, config impact, risk, fate, manifest eligibility, and recommended next route.
* Produce CONFIG_INFRA_SUITABILITY_DECISION.md and optional JSON.
* Do not generate INTEGRATION_REQUEST.md unless the selected CIP01 DOT explicitly permits it and I confirm.

For CIP02:
* Validate CIP01 decision.
* Generate or retrofit a rich INTEGRATION_REQUEST.md using the accepted config-infra schema.
* Preserve batch-time suitability truth.
* Do not approve config mutation or resolve live config state.
* Stop after CIP02 unless I confirm CIP03.

For CIP03:
* Aggregate one or more INTEGRATION_REQUEST artifacts.
* Produce INTEGRATION_MANIFEST.md / JSON.
* Classify items as approved, deferred, blocked, duplicate, already covered, or rejected.
* Do not resolve live config state.
* Stop after CIP03 unless I confirm CIP04.

For CIP04:
* Resolve current live config/tooling state in read-only mode.
* Produce CONFIG_STATE_SNAPSHOT.md / JSON and CIP04_POSTCHECK.md.
* Do not plan implementation or apply changes.
* Stop after CIP04 unless I confirm CIP05.

For CIP05:
* Produce CONFIG_INTEGRATION_PLAN.md / JSON and CIP05_POSTCHECK.md from approved manifest items and live config snapshot.
* Select patch classes, exact touch set, validation plan, rollback/deferral notes, and safety gates.
* Do not apply changes.
* Stop after CIP05 unless I confirm CIP06.

For CIP06:
* Apply only manifest-approved, planned, explicitly confirmed config changes.
* Enforce exact touch set and idempotency.
* Produce CONFIG_INTEGRATION_CLOSEOUT_REPORT.md / JSON, CIP06_POSTCHECK.md, and validation evidence.
* Stop after CIP06 unless I confirm any follow-up route.

Route identity to validate:

MODE=config-infra
TRACK=cip
PHASE=<CIP01 | CIP02 | CIP03 | CIP04 | CIP05 | CIP06>
CIP_RUN_SLUG=<stable-cip-run-slug>
TOPIC=<topic>
PROFILE=<webchat-sandbox | real-workspace | codex-pack>

CIP output root rule:

For real workspace runs, use:

/workspace/runs/cip/<CIP_RUN_SLUG>/<cip-phase>/

where <cip-phase> is:

* cip01
* cip02
* cip03
* cip04
* cip05
* cip06

For webchat runs, produce draft output content in chat or sandbox artifacts only. Do not claim real workspace mutation.

Canonical CIP output filenames:

CIP01:
* CONFIG_INFRA_SUITABILITY_DECISION.md
* CONFIG_INFRA_SUITABILITY_DECISION.json

CIP02:
* INTEGRATION_REQUEST.md
* INTEGRATION_REQUEST.json

CIP03:
* INTEGRATION_MANIFEST.md
* INTEGRATION_MANIFEST.json

CIP04:
* CONFIG_STATE_SNAPSHOT.md
* CONFIG_STATE_SNAPSHOT.json
* CIP04_POSTCHECK.md

CIP05:
* CONFIG_INTEGRATION_PLAN.md
* CONFIG_INTEGRATION_PLAN.json
* CIP05_POSTCHECK.md

CIP06:
* CONFIG_INTEGRATION_CLOSEOUT_REPORT.md
* CONFIG_INTEGRATION_CLOSEOUT_REPORT.json
* CIP06_POSTCHECK.md

Allowed actions in ChatGPT/webchat:

* inspect uploaded files
* extract uploaded zips in the sandbox if needed
* read relevant Markdown/JSON/YAML/text files
* produce CIP report text
* produce draft CIP artifact text in the answer
* classify PASS/WARN/STOP from evidence
* prepare Codex/WSL/operator prompts when the selected DOT addresses another agent

Forbidden actions in ChatGPT/webchat:

* mutate the real workspace
* mutate `/mnt/egress`
* mutate live config
* mutate public/private source repos
* run implementation
* run bootstrap, mount, pull, push, package installs, Docker, RunPod, paid APIs, or broad smoke
* read or print credential contents
* import snapshots into the real private bundle
* continue to the next CIP phase without confirmation
* rewrite evidence as if it were canonical
* silently repair evidence
* invent missing files or test results

Idempotency:

* If equivalent CIP artifacts already exist in the uploaded private bundle or provided CIP output folder, compare and report whether they are consistent.
* Do not overwrite them in webchat.
* If producing draft artifact text, label it as draft/proposed, not applied.
* Same inputs must produce the same PASS/WARN/STOP classification.
* If ALLOW_OVERWRITE=no and target outputs exist, STOP unless the selected CIP DOT provides an alternate versioned-output rule.

Expected output:
Produce the CIP closeout content in chat only unless the selected DOT and addressed agent allow file creation.

Use this deterministic final section order:

1. Selected route
2. Selected main DOT
3. Selected CIP DOT
4. Addressed agent
5. Proposed/confirmed variable block
6. Source-of-truth files read
7. CIP input files read
8. Main-DOT position / graph appreciation
9. Required input checklist
10. Route identity validation
11. CIP-specific validation
12. Scope and safety validation
13. Missing / rejected / deferred items
14. Draft CIP artifacts or handoff prompt
15. Recommended next action
16. PASS / WARN / STOP

Decision rules:

* PASS only if required inputs exist, identity matches, CIP gates pass, scope is clean, and no forbidden action occurred.
* WARN only if required inputs exist, identity matches, scope is clean, no forbidden action occurred, and warnings are documented/accepted by the selected CIP DOT.
* STOP if required input is missing, identity is contradicted, required validation fails, scope expanded, forbidden action occurred, evidence is contradictory, or addressed-agent authority is wrong.

First response required:
Before doing any execution, return only:

1. Selected route
2. Selected main DOT
3. Selected CIP DOT
4. Addressed agent
5. Proposed variable block with every variable labeled as:
   - user-provided
   - inferred
   - default-safe
   - unknown
6. Missing prerequisites, if any
7. Confirmation question

Do not execute until I confirm.
