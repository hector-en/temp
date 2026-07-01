21.06.26, 18:55

vmuser - Milestone Creation for Codex

before conituing check prepare_nca_art_workspace i believe
somewhere in the uploaded files there are initial suggestins for how the
project, domain specific language design work would look like and an
initial folder structure was given? once you find it add your current
understanding to it and try to create a more realistic full folder
structure for this step. output only that updated step.

Nachgedacht für 19s

# Updated step — `prepare_nca_art_workspace`

## Purpose.

Prepare the first realistic project skeleton for the NCA-ART-GRN research codebase. This step should not run simulations, train models, install packages, launch Runpod jobs, or generate results. It should only create the workspace where the later research code can live.

The workspace should reflect the actual architecture of the research idea:

```text
Symbolic DSL / motif library
 -> candidate 5-node GRNs
 -> PDE/ODE reaction-diffusion simulator
 -> generated cell-state trajectories
 -> NCA surrogate or alternate cell-rule model
 -> ART prototype and transition discovery
 -> prototype-to-DSL inverse mapping
 -> verification by Turing checks, sweeps, Bayesian or robustness tests
```

This matches the research direction in the uploaded notes: the simulator is the authoritative forward model; ART discovers prototypes and transition graphs from simulated cell states; NCA can act as a fast surrogate or alternate local update rule; and the DSL is needed for human-readable GRN topology, constraints, Turing analysis, and formal testing.

## Managed step name

```text
prepare_nca_art_workspace
```

## Target role

Primary target:

```text
researchscientist
```

Secondary target later:

```text
aiengineer
```

Research Scientist owns the scientific project workspace. AI Engineer may later own platform/runtime wrappers, APIs, Agentfield services, or Paperclip integration.

## Proposed workspace root

Use a configurable root, but default to:

```text
/workspace/repos/nca-art-grn
```

Fallback when `/workspace` is unavailable:

```text
/home/researchscientist/research/nca-art-grn
```

The step should report which root it used.

## Realistic folder structure

```text
nca-art-grn/
├── README.md
├── pyproject.toml
├── requirements/
│   ├── base.txt
│   ├── research.txt
│   ├── gpu.txt
│   ├── notebooks.txt
│   └── dev.txt
│
├── configs/
│   ├── project.yaml
│   ├── paths.yaml
│   ├── logging.yaml
│   ├── runpod.yaml
│   ├── experiments/
│   │   ├── smoke_test.yaml
│   │   ├── grn_5node_baseline.yaml
│   │   ├── nca_surrogate_baseline.yaml
│   │   └── art_discovery_baseline.yaml
│   ├── search/
│   │   ├── random_grid.yaml
│   │   ├── latin_hypercube.yaml
│   │   ├── evolutionary.yaml
│   │   └── bayesian.yaml
│   └── validation/
│       ├── turing_checks.yaml
│       ├── robustness.yaml
│       └── resimulation.yaml
│
├── src/
│   └── nca_art_grn/
│       ├── __init__.py
│       │
│       ├── dsl/
│       │   ├── __init__.py
│       │   ├── grammar.py
│       │   ├── schema.py
│       │   ├── constraints.py
│       │   ├── matrices.py
│       │   ├── motifs.py
│       │   ├── compose.py
│       │   ├── export.py
│       │   └── examples.py
│       │
│       ├── motifs/
│       │   ├── __init__.py
│       │   ├── library.py
│       │   ├── known_2node.py
│       │   ├── known_3node.py
│       │   ├── known_4node.py
│       │   ├── embed_5node.py
│       │   └── biological_filters.py
│       │
│       ├── candidates/
│       │   ├── __init__.py
│       │   ├── generator.py
│       │   ├── sampler.py
│       │   ├── mutation.py
│       │   ├── priors.py
│       │   └── registry.py
│       │
│       ├── simulator/
│       │   ├── __init__.py
│       │   ├── pde_ode.py
│       │   ├── reaction_diffusion.py
│       │   ├── grn_ode.py
│       │   ├── integrators.py
│       │   ├── boundary_conditions.py
│       │   ├── initial_conditions.py
│       │   ├── perturbations.py
│       │   └── observables.py
│       │
│       ├── capture/
│       │   ├── __init__.py
│       │   ├── snapshots.py
│       │   ├── trajectories.py
│       │   ├── metadata.py
│       │   └── dataset_writer.py
│       │
│       ├── nca/
│       │   ├── __init__.py
│       │   ├── model.py
│       │   ├── cells.py
│       │   ├── neighborhoods.py
│       │   ├── train.py
│       │   ├── losses.py
│       │   ├── rollout.py
│       │   └── validate_against_simulator.py
│       │
│       ├── art/
│       │   ├── __init__.py
│       │   ├── fuzzy_art.py
│       │   ├── topo_art.py
│       │   ├── dual_vigilance.py
│       │   ├── artmap.py
│       │   ├── prototypes.py
│       │   ├── transition_graph.py
│       │   └── novelty.py
│       │
│       ├── mapping/
│       │   ├── __init__.py
│       │   ├── prototype_to_dsl.py
│       │   ├── inverse_fit.py
│       │   ├── sparse_regression.py
│       │   ├── sign_constraints.py
│       │   ├── motif_reduction.py
│       │   └── sbml_export.py
│       │
│       ├── analysis/
│       │   ├── __init__.py
│       │   ├── turing.py
│       │   ├── stability.py
│       │   ├── dispersion.py
│       │   ├── robustness.py
│       │   ├── scoring.py
│       │   └── ranking.py
│       │
│       ├── search/
│       │   ├── __init__.py
│       │   ├── random_grid.py
│       │   ├── lhs.py
│       │   ├── evolutionary.py
│       │   ├── bayesian.py
│       │   ├── active_sampling.py
│       │   └── compare_methods.py
│       │
│       ├── runs/
│       │   ├── __init__.py
│       │   ├── runner.py
│       │   ├── campaign.py
│       │   ├── checkpointing.py
│       │   └── resume.py
│       │
│       ├── viz/
│       │   ├── __init__.py
│       │   ├── heatmaps.py
│       │   ├── prototype_overlay.py
│       │   ├── transition_graphs.py
│       │   ├── parameter_maps.py
│       │   └── paper_figures.py
│       │
│       └── cli/
│           ├── __init__.py
│           ├── main.py
│           ├── simulate.py
│           ├── discover.py
│           ├── train_nca.py
│           ├── map_dsl.py
│           ├── verify.py
│           └── compare_search.py
│
├── data/
│   ├── README.md
│   ├── motifs/
│   │   ├── known_2node/
│   │   ├── known_3node/
│   │   ├── known_4node/
│   │   └── composed_5node/
│   ├── candidates/
│   ├── synthetic/
│   ├── snapshots/
│   ├── trajectories/
│   └── external/
│
├── artifacts/
│   ├── prototypes/
│   ├── transition_graphs/
│   ├── dsl_candidates/
│   ├── sbml/
│   ├── figures/
│   ├── reports/
│   └── exports/
│
├── runs/
│   ├── smoke/
│   ├── local/
│   ├── runpod/
│   └── archived/
│
├── notebooks/
│   ├── 00_project_map.ipynb
│   ├── 01_motif_library.ipynb
│   ├── 02_pde_ode_smoke_test.ipynb
│   ├── 03_art_prototype_discovery.ipynb
│   ├── 04_nca_surrogate_training.ipynb
│   ├── 05_prototype_to_dsl.ipynb
│   ├── 06_parameter_search_comparison.ipynb
│   └── 07_paper_figures.ipynb
│
├── scripts/
│   ├── smoke_test.sh
│   ├── run_local_smoke.sh
│   ├── run_parameter_search.sh
│   ├── run_nca_training.sh
│   ├── export_figures.sh
│   └── clean_run_outputs.sh
│
├── tests/
│   ├── test_dsl_schema.py
│   ├── test_motif_library.py
│   ├── test_candidate_generation.py
│   ├── test_simulator_smoke.py
│   ├── test_snapshot_schema.py
│   ├── test_art_prototypes.py
│   ├── test_transition_graph.py
│   ├── test_prototype_to_dsl.py
│   └── test_turing_checks.py
│
└── docs_internal/
    ├── architecture_notes.md
    ├── data_contracts.md
    ├── dsl_notes.md
    ├── experiment_lifecycle.md
    └── safety_boundary.md
```

## Why these folders exist

`dsl/` is needed because ART does not replace symbolic reasoning. The DSL represents GRN topology, interaction signs, strengths, constraints, and export formats. It is where candidate GRNs become human-readable and mathematically checkable.

`motifs/` is needed because known 2-, 3-, and 4-node GRNs should seed the 5-node search. They reduce waste, improve biological plausibility, and help interpret discovered 5-node candidates.

`simulator/` is needed because the PDE/ODE reaction-diffusion simulator remains the authoritative forward model. It generates the synthetic cell-state trajectories used by ART and NCA.

`nca/` is needed because the NCA may be trained as a surrogate for the simulator or used as an alternate local cell-update rule. It is conceptually applied inside every cell, but implemented centrally over the grid.

`art/` is needed because ART discovers recurring local state vectors, prototypes, prototype assignments, topology, and transition graphs from simulator or NCA outputs.

`mapping/` is needed because prototypes do not automatically become GRNs. They need inverse fitting, sparse/sign-constrained mapping, motif reduction, and export into DSL or SBML-style artifacts.

`analysis/` and `search/` are needed because candidates must be tested by Turing/stability analysis, parameter sweeps, Bayesian/ABC-style methods, robustness checks, and re-simulation.

`artifacts/` is needed because the system must preserve the outputs that make the research inspectable: prototypes, transition graphs, DSL candidates, figures, reports, and exports.

## Minimal files created by the step

The first implementation of `prepare_nca_art_workspace` should create only skeleton files, not working scientific code:

```text
README.md
pyproject.toml
requirements/base.txt
requirements/research.txt
requirements/gpu.txt
requirements/notebooks.txt
requirements/dev.txt
configs/project.yaml
configs/paths.yaml
configs/experiments/smoke_test.yaml
src/nca_art_grn/__init__.py
src/nca_art_grn/dsl/__init__.py
src/nca_art_grn/motifs/__init__.py
src/nca_art_grn/simulator/__init__.py
src/nca_art_grn/capture/__init__.py
src/nca_art_grn/nca/__init__.py
src/nca_art_grn/art/__init__.py
src/nca_art_grn/mapping/__init__.py
src/nca_art_grn/analysis/__init__.py
src/nca_art_grn/search/__init__.py
src/nca_art_grn/runs/__init__.py
src/nca_art_grn/viz/__init__.py
src/nca_art_grn/cli/__init__.py
data/README.md
scripts/smoke_test.sh
tests/test_project_import.py
docs_internal/architecture_notes.md
docs_internal/data_contracts.md
docs_internal/dsl_notes.md
docs_internal/experiment_lifecycle.md
docs_internal/safety_boundary.md
```

## Config-tool behavior

The managed step should:

```text
1. Resolve TARGET_USER and TARGET_HOME.
2. Resolve workspace root from policy if present.
3. Fall back to /workspace/repos/nca-art-grn if /workspace exists.
4. Fall back to /home/researchscientist/research/nca-art-grn.
5. Create the folder tree as TARGET_USER.
6. Write placeholder files only if missing.
7. Never overwrite existing research code.
8. Print the selected workspace root.
9. Print next manual commands.
```

## Suggested output after running

```text
[DONE] prepare_nca_art_workspace

Workspace:
/workspace/repos/nca-art-grn

Created:
project skeleton
config folders
src package folders
data/artifact/run folders
notebook placeholders
internal notes

Next:
su - researchscientist
cd /workspace/repos/nca-art-grn
lv conda researchscientist
python -m pytest tests/test_project_import.py
```

## Acceptance criteria

```text
sudo config --target researchscientist bootstrap step prepare_nca_art_workspace
```

must:

```text
create the workspace tree
run as the target user where files are target-owned
not install packages
not run simulations
not train NCA models
not run ART discovery
not start Runpod jobs
not overwrite existing project files
```

Validation:

```text
test -d /workspace/repos/nca-art-grn || test -d /home/researchscientist/research/nca-art-grn
test -d <root>/src/nca_art_grn/dsl
test -d <root>/src/nca_art_grn/simulator
test -d <root>/src/nca_art_grn/nca
test -d <root>/src/nca_art_grn/art
test -d <root>/src/nca_art_grn/mapping
test -d <root>/src/nca_art_grn/analysis
test -d <root>/src/nca_art_grn/search
test -f <root>/configs/experiments/smoke_test.yaml
test -f <root>/docs_internal/dsl_notes.md
```

## Product meaning

This step creates the first serious project container for the MRes/research platform. It does not answer the scientific question yet. It makes the question buildable: PDE/ODE simulator, NCA surrogate, ART discovery, symbolic DSL, candidate search, and verification all get a place in the same coherent project instead of becoming disconnected notebooks.
