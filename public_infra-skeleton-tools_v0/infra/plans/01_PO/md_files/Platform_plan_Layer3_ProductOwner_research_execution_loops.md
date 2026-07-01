# Layer 3 — Research Execution Loops

**Product-owner view**

**Product goal:** turn the prepared research workstation into real scientific execution loops.

Layer 1 prepared the runtime.

Layer 2 prepared the role workstations.

Layer 3 prepares the actual research machinery:

- simulate
- discover
- train or test surrogate
- map to symbolic DSL
- search parameters
- verify
- run locally or on Runpod

This layer is where your actual MRes/research work starts becoming executable.

## Layer 3 bundles

### Bundle 3 — NCA-ART research stack

Prepare the actual simulator/NCA/ART/DSL research execution loop.

### Bundle 4 — Parameter search comparison tools

Prepare random/grid, Latin hypercube, evolutionary, Bayesian, and robustness workflows.

### Bundle 5 — Runpod training/inference loop

Prepare the remote compute workflow for candidate batches, training, inference, checkpoints, and result.

## Correct scientific direction

The research loop should follow this architecture:

1. **Symbolic DSL / motif library**
   - Generate biologically constrained candidate GRNs.

2. **PDE/ODE simulator**
   - Run reaction-diffusion simulations for 5-node GRNs.

3. **Data capture**
   - Store per-cell state vectors, neighborhoods, timepoints, parameters, and metadata.

4. **ART / ARTMAP discovery**
   - Cluster recurring local states into prototypes.
   - Build transition graphs.
   - Optionally learn neighborhood -> next-state mappings.

5. **NCA**
   - Either train a fast surrogate from simulator trajectories,
   - or test local update rules derived from ART transitions.

6. **Prototype-to-DSL mapping**
   - Fit symbolic GRN parameters/topologies from promising prototypes and transitions.

7. **Verification**
   - Run Turing/stability checks, parameter sweeps, robustness tests, and resimulation.

That matches the uploaded ART/NCA notes: the PDE/ODE simulator is the authoritative forward model; ART ingests simulator or NCA state vectors and produces prototypes and transition graphs; ARTMAP can help with input-to-next-state mappings; NCA can be a surrogate or alternate local update model; and DSL mapping turns prototypes into human-readable GRN candidates with constraints and verification.

## What Layer 3 must not do yet

- not build the Agentfield controller
- not build the Paperclip adapter
- not create dashboards
- not automate full campaigns yet
- not hide the scientific steps behind agents

Layer 3 should make the research loop work manually and reproducibly first.

## Layer 3 success condition

After Layer 3, you should be able to run a small local smoke experiment:

- generate candidate 5-node GRNs
- run a tiny PDE/ODE simulation
- capture state snapshots
- cluster with ART
- produce a prototype/transition artifact
- optionally train or test a tiny NCA surrogate
- attempt prototype-to-DSL mapping
- run one basic verification check
- write outputs to `/workspace/runs/nca-art-grn`

Then Bundle 5 can move that same loop to Runpod.
