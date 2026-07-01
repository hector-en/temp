21.06.26, 19:10

vmuser - Milestone Creation for Codex

give a very short oveview how this repo works with the rest of the
platform folders like grn-...data/ and the normal workspace/data same
fo rartifacts, runs, notebooks,scripts, tests etc, whats the relationship
with the folders created by prepare_runpod_workspace, also how would
the platform actually use this folder? stay brief i want to move on to the
second layer.

`prepare_runpod_workspace` creates the platform-level storage layout.

`prepare_nca_art_workspace` creates one research code repository inside that platform.

```text
/workspace/
  repos/
    nca-art-grn/          # code repo created by prepare_nca_art_workspace
  data/                   # shared datasets, candidate libraries, imported inputs
  runs/                   # platform-level experiment run outputs
  artifacts/              # reusable outputs, reports, figures, models
  models/                 # model weights / local model caches
  checkpoints/            # training checkpoints
```

Inside `nca-art-grn/`, folders are mostly project-local views of that work:

```text
nca-art-grn/
  src/                    # actual Python package: simulator, DSL, ART, NCA, search
  configs/                # experiment configs that point to /workspace/data and /workspace/runs
  notebooks/              # exploration and paper figures
  scripts/                # developer entrypoints for local runs
  tests/                  # repo validation
  data/                   # small examples, schemas, tiny fixtures, not big datasets
  runs/                   # local/dev smoke runs only
  artifacts/              # repo-local generated examples only
```

So the rule should be:

```text
small example data lives in repo/data
real research data lives in /workspace/data

local smoke outputs live in repo/runs
real experiment outputs live in /workspace/runs

example/demo artifacts live in repo/artifacts
important reusable results live in /workspace/artifacts

source code, configs, tests, notebooks, scripts live in repo
```

The platform uses the repo like this:

```text
config prepares the repo, env, paths, and packages
researchscientist runs code from nca-art-grn/
Runpod jobs mount /workspace and execute repo scripts/configs
Agentfield later submits experiments that call this repo's CLI/modules
Paperclip later shows those Agentfield runs, status, artifacts, and results
```

In short:

```text
/workspace = shared platform state
/workspace/repos/nca-art-grn = research engine source code
Agentfield = orchestrates this engine later
Paperclip = makes those orchestrated runs visible and controllable
```
