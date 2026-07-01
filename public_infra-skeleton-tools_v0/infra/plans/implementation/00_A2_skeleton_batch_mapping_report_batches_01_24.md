Corrected Smoke.d Batch Mapping Report — Skeleton Batches 01–24
Ground rules for the corrected report

The earlier report was structurally right in one important way: do not create one smoke module per batch. Smoke modules should still be domain-owned: core layout, evidence, infra tools, GRN contracts, RunPod dry-runs, PKM/OpenClaw, LaTeX/publisher, Agentfield, Paperclip adapter, and campaigns. The existing report also correctly stated the dynamic smoke model: runner discovers tests/smoke.d/*.smoke.sh, writes reports under runs/smoke, and should not deploy, mutate infra, install packages, print credentials, launch RunPod, or call live model/provider APIs.

The important corrections are:

Area	Correction
Batch 02	Do not use prepare_grn_workspace; the master explicitly says that is not a step. Use prepare_nca_art_workspace and prepare_experiment_output_layout.
Batch 01	It is runtime substrate plus thin remote-model dummy contract. After GREEN, the research-assistant contract deserves its own dynamic module, 90-research-assistant.smoke.sh, while core roots stay in 10-core-layout.
Layer PDFs	They are background semantics, not batch slices. The batch plan remains the 01–24 slicing authority.
Platform semantics	The stack is config → research engine / PKM / OpenClaw → Agentfield → Paperclip adapter → Paperclip, not disconnected setup scripts.
Smoke goal	Smoke proves file/contract/readiness shape, not scientific truth, live orchestration, or live infrastructure.
Corrected domain module model
Smoke domain	Module status	Owns
Core runtime/layout	existing 10-core-layout.smoke.sh	/workspace roots, generic runtime layout, basic runner/report roots
Python package/import	existing 20-python-package.smoke.sh	package markers/import/syntax where relevant
Skeleton evidence	existing 30-skeleton-evidence.smoke.sh	POSTCHECK.md, INTEGRATION_REQUEST.md
Config boundary	existing 50-config-boundary.smoke.sh	confirms project batches did not edit config internals
Infra tools	existing 60-infra-tools.smoke.sh	safe command presence only: docker, terraform, kubectl, runpod, GPU
GRN/NCA/ART contracts	existing 70-grn-contract.smoke.sh, later may split	DSL, dummy science outputs, mechanism reports, search outputs
Research assistant	existing/new 90-research-assistant.smoke.sh	Batch 01 dummy answer path / remote-model contract
RunPod dry-run	future 75-runpod-dryrun.smoke.sh	manifests, job templates, no live RunPod
PKM/OpenClaw	future 80-openclaw-pkm.smoke.sh	indexes, bridges, reasoner profiles, no vault write
Publisher/LaTeX	future 82-publisher-latex.smoke.sh	paper skeleton, TeX structure, no PDF build by default
Agentfield	future 85-agentfield.smoke.sh	POC schemas, controller, reasoners, fixtures, dryrun only
Paperclip adapter	future 86-paperclip-adapter.smoke.sh	adapter schema/mappers/dryrun card, no live Paperclip
Campaign orchestration	future 88-agentfield-campaign.smoke.sh	campaign schemas, state, review payload, human gate
Batch 01 — Runtime substrate
Field	Correct mapping
Slug	01-runtime-substrate
Scope	Layer 1 / Bundle 1 + Bundle 7
Branch	skeleton/01-runtime-substrate
Steps smoked	prepare_runpod_workspace, prepare_runpod_volume_layout, check_runpod_workspace, check_gpu_runtime, check_cuda_torch_runtime, prepare_docker_runtime_policy, check_docker_gpu_access, prepare_remote_compute_profile, prepare_terraform_runtime_policy, check_kubernetes_context, prepare_remote_model_client, check_runpod_brain_endpoint, prepare_brain_router_project, check_opencode_remote_model_config
Smoke modules	10-core-layout.smoke.sh, 60-infra-tools.smoke.sh, 90-research-assistant.smoke.sh
Smoke verifies	generic /workspace roots, /workspace/runtime, /workspace/scripts/runtime_checks, /workspace/repos/research-assistant, Python compile, dummy answer path, evidence files
Must not do	create nca-art-grn, launch RunPod, run containers, call model APIs, run Terraform/Kubernetes mutation

Correction: The previous report was right that Batch 01 starts with 10-core-layout, but after Batch 01 GREEN it is no longer sufficient to leave the remote-model dummy client as “maybe exists.” The Layer 1 PDF says this batch prepares runtime roots, readiness checks, and a thin remote-model client contract, while not creating research code, simulations, Agentfield, Paperclip, PKM, or LaTeX. The generated Batch 01 index confirms the expected roots and step range, and lists the preferred smoke domains as core layout plus infra-tools where explicit tool checks exist. The corrected dynamic behavior is: core layout checks roots; 90-research-assistant checks the dummy answer path.

Batch 02 — Research workspace
Field	Correct mapping
Slug	02-research-workspace
Scope	Layer 2 / Bundle 2
Branch	skeleton/02-research-workspace
Steps smoked	install_grn_core_research_stack, install_nca_art_research_stack, install_parameter_search_comparison_stack, prepare_nca_art_workspace, prepare_experiment_output_layout, check_research_env_ready, prepare_dummy_science_cli
Smoke modules	20-python-package.smoke.sh, 70-grn-contract.smoke.sh, 30-skeleton-evidence.smoke.sh
Smoke verifies	/workspace/repos/nca-art-grn, /workspace/data/nca-art-grn, /workspace/runs/nca-art-grn, /workspace/artifacts/nca-art-grn, package-policy files, dummy CLI, dummy artifact filenames
Must not do	run research experiments, train models, build Agentfield, build Paperclip

Correction: The old report used prepare_grn_workspace; that is wrong. The master explicitly removes that duplicate and names prepare_nca_art_workspace plus prepare_experiment_output_layout. The Layer 2 PDF also says project source belongs under /workspace/repos/<project>, data under /workspace/data/<project>, runs under /workspace/runs/<project>, and artifacts under /workspace/artifacts/<project>.

Batch 03 — AI Engineer workspaces
Field	Correct mapping
Slug	03-ai-engineer-workspaces
Scope	Layer 2 / Bundle 6
Branch	skeleton/03-ai-engineer-workspaces
Steps smoked	install_ai_platform_stack, install_local_model_client_stack, install_agent_dev_stack, prepare_agentfield_dev_workspace, prepare_openclaw_dev_workspace, check_ai_engineer_env_ready
Smoke modules	20-python-package.smoke.sh, future 85-agentfield.smoke.sh, future 80-openclaw-pkm.smoke.sh, 30-skeleton-evidence.smoke.sh
Smoke verifies	/workspace/repos/agentfield, /workspace/repos/openclaw-workspace, package-policy markers, AI Engineer readiness report
Must not do	start Agentfield, call models, run OpenClaw jobs, build Paperclip adapter

Correction: This batch is workspace/package-policy preparation only. It can create dev roots, but it must not turn into Agentfield runtime work yet.

Batch 04 — PKM skeleton
Field	Correct mapping
Slug	04-pkm-skeleton
Scope	Layer 2 / Bundle 9
Branch	skeleton/04-pkm-skeleton
Steps smoked	prepare_obsidian_vault_access, prepare_obsidian_vault_mount, check_obsidian_vault_access, prepare_atomic_zettelkasten_structure, prepare_source_note_templates, prepare_atom_note_templates, prepare_molecule_note_templates, prepare_topic_question_templates, prepare_alloy_publish_note_templates, prepare_latex_section_note_templates, prepare_figure_export_paths, prepare_latex_template_binding, prepare_paper_note_structure, prepare_literature_note_structure
Smoke modules	future 80-openclaw-pkm.smoke.sh, possibly future 81-zettelkasten.smoke.sh if split
Smoke verifies	/workspace/pkm/zettelkasten, expected folders, templates, bridge paths, no-overwrite sentinel
Must not do	print note bodies, index whole vault, rewrite notes, auto-promote notes

Correction: Batch 04 is PKM structure, not OpenClaw reasoning yet. The Bundle 9 PDF says this is a structured atomic Zettelkasten for research, AI engineering, experiment planning, and future paper writing, and that it should not build the paper.

Batch 05 — Publisher LaTeX
Field	Correct mapping
Slug	05-publisher-latex
Scope	Layer 2 / Bundle 10
Branch	skeleton/05-publisher-latex
Steps smoked	install_publisher_latex_stack, install_publisher_notebook_export_stack, prepare_scientific_report_template, prepare_grn_paper_latex_project, prepare_labreport_class_assets, prepare_article_style_profile, prepare_latex_section_files, prepare_bibliography_pipeline, prepare_zettelkasten_to_manuscript_bridge, prepare_notebook_to_latex_export, prepare_manuscript_export_pipeline, prepare_final_draft_build, check_latex_build_tools, check_publisher_env_ready
Smoke modules	future 82-publisher-latex.smoke.sh
Smoke verifies	/workspace/artifacts/papers/grn-paper, grn-paper.tex, cls/, styles/, bib/, files/grn/, fig/grn/, tables/grn/, build/, zettelkasten_bridge/
Must not do	install TeX unless explicit, build PDF by default, overwrite manuscript text, consume all Obsidian notes, run simulations, call models

Correction: The Bundle 10 PDF explicitly adds publisher install steps before project/template steps and says the paper project must preserve a labreport/IBA-style modular architecture. It also lists acceptance tests for the GRN paper project and says not to build the PDF unless explicitly requested.

Batch 06 — NCA-ART-GRN base
Field	Correct mapping
Slug	06-nca-art-base
Scope	Layer 3 / Bundle 3A
Branch	skeleton/06-nca-art-base
Steps smoked	prepare_dsl_candidate_runtime, prepare_mechanism_hypothesis_runtime
Smoke modules	70-grn-contract.smoke.sh
Smoke verifies	DSL schema/modules/configs, mechanism hypothesis schema/configs, fake 5-node candidate, package import/syntax
Must not do	run simulation, train NCA, run ART2/ARTMAP, claim discovery

Correction: Batch 06 is schema/base contract, not execution. The Bundle 3 PDF says the DSL must encode topology, signs, interaction matrix, reaction/diffusion parameters, constraints, observables, and perturbables, and mechanism hypotheses must include predicted tests rather than only pattern images.

Batch 07 — Dummy science organs
Field	Correct mapping
Slug	07-dummy-science-organs
Scope	Layer 3 / Bundle 3B
Branch	skeleton/07-dummy-science-organs
Steps smoked	prepare_pde_ode_simulation_runtime, prepare_nca_cell_runtime, prepare_pde_ode_to_nca_dataset, prepare_art2_discovery_runtime, prepare_artmap_transition_runtime, prepare_pattern_dynamics_metrics, prepare_interaction_function_inference_runtime, prepare_perturbation_design_runtime
Smoke modules	70-grn-contract.smoke.sh
Smoke verifies	dummy simulator/NCA/ART2/ARTMAP/perturbation outputs, expected JSON shapes
Must not do	large simulations, real NCA training, RunPod, parameter campaigns, real biological claims

Correction: This batch is broader than the old “dummy PDE/ODE, NCA, ART2, ARTMAP” shorthand. The corrected PDF adds mechanism-discrimination and dynamics/perturbation-oriented checks as part of the research core.

Batch 08 — Mechanism reporting
Field	Correct mapping
Slug	08-mechanism-reporting
Scope	Layer 3 / Bundle 3C
Branch	skeleton/08-mechanism-reporting
Steps smoked	prepare_prototype_store, prepare_transition_graph_store, prepare_prototype_to_dsl_runtime, prepare_mechanism_discrimination_report
Smoke modules	70-grn-contract.smoke.sh
Smoke verifies	prototype store, transition graph store, prototype-to-DSL stubs, mechanism report with guardrail headings
Must not do	infer real biology, overwrite reports, treat final pattern as proof

Correction: The smoke must check that mechanism reports include discrimination/falsification framing. The Bundle 3 PDF explicitly says the system must move beyond visually matching patterns and instead produce symbolic models, NCA rules, ART/ARTMAP evidence, and mathematical experimental designs.

Batch 09 — Local science smoke
Field	Correct mapping
Slug	09-local-smoke
Scope	Layer 3 / Bundle 3D
Branch	skeleton/09-local-smoke
Steps smoked	prepare_nca_art_smoke_configs, check_nca_art_pipeline_inputs, run_nca_art_local_smoke
Smoke modules	70-grn-contract.smoke.sh
Smoke verifies	tiny local smoke config and output folder containing metadata.json, candidate.dsl.json, simulator_summary.json, nca_summary.json, art2_prototypes.json, artmap_transitions.json, pattern_dynamics.json, perturbation_summary.json, mechanism_report.md
Must not do	large simulations, full NCA training, RunPod, parameter campaigns, claim discovery

The Bundle 3 PDF lists exactly this local smoke output contract and says the smoke must be tiny, labelled as smoke, and must record mechanism hypothesis, dynamics, perturbation metadata, ART2/ARTMAP settings, and an inspectable mechanism report.

Batch 10 — Search templates
Field	Correct mapping
Slug	10-search-templates
Scope	Layer 3 / Bundle 4A
Branch	skeleton/10-search-templates
Steps smoked	prepare_search_parameter_space, prepare_random_grid_baselines, prepare_lhs_search_template, prepare_evolutionary_search_template, prepare_bayesian_search_template, prepare_active_learning_search_template
Smoke modules	70-grn-contract.smoke.sh, future 72-search-contract.smoke.sh if split
Smoke verifies	search configs, parameter-space schema, baseline/search method templates
Must not do	run real search, launch campaigns, use distributed compute

The Bundle 4 PDF says search must compare methods by mechanism evidence, dynamics, perturbation response, DSL recoverability, and experimental-design value, not just final pattern score.

Batch 11 — Search scoring
Field	Correct mapping
Slug	11-search-scoring
Scope	Layer 3 / Bundle 4B
Branch	skeleton/11-search-scoring
Steps smoked	prepare_mechanism_scoring_runtime, prepare_search_result_comparison_schema, prepare_candidate_ranking_runtime, prepare_robustness_sweep_template, prepare_perturbation_search_template, prepare_search_report_runtime
Smoke modules	70-grn-contract.smoke.sh, future 72-search-contract.smoke.sh
Smoke verifies	scoring schema, shared result schema, ranking config, robustness/perturbation templates, search report template
Must not do	expensive sweeps, real campaigns, model training

Correction: Batch 11 is not just “search scoring.” It is where the search becomes scientifically comparable through mechanism/discrimination fields.

Batch 12 — Search smoke
Field	Correct mapping
Slug	12-search-smoke
Scope	Layer 3 / Bundle 4C
Branch	skeleton/12-search-smoke
Steps smoked	prepare_search_smoke_configs, check_parameter_search_inputs, run_parameter_search_local_smoke
Smoke modules	70-grn-contract.smoke.sh, future 72-search-contract.smoke.sh
Smoke verifies	tiny dummy search run writes results, ranking, and report
Must not do	real candidate campaigns, RunPod, full NCA training

Correction: This batch may run, but only a tiny local dummy search smoke.

Batch 13 — RunPod dry-run
Field	Correct mapping
Slug	13-runpod-dryrun
Scope	Layer 3 / Bundle 5
Branch	skeleton/13-runpod-dryrun
Steps smoked	prepare_runpod_training_workspace, prepare_runpod_inference_workspace, prepare_candidate_batch_layout, prepare_training_run_layout, prepare_checkpoint_policy, prepare_result_return_policy, prepare_remote_run_manifest_schema, prepare_runpod_job_templates, prepare_runpod_nca_training_configs, prepare_runpod_art_discovery_configs, prepare_runpod_search_campaign_configs, prepare_runpod_mechanism_report_configs, check_runpod_training_ready, run_runpod_local_dryrun_smoke
Smoke modules	future 75-runpod-dryrun.smoke.sh, 60-infra-tools.smoke.sh only for optional command presence
Smoke verifies	local manifests, workspace layout, job templates, dryrun report/status
Must not do	create RunPod pod, spend credits, call RunPod API, start containers

The Bundle 5 PDF makes clear this bundle prepares the remote execution layer, but the skeleton pass is a safe local dry-run foundation; remote success later means returned mechanism evidence, not a nice image.

Batch 14 — OpenClaw indexes
Field	Correct mapping
Slug	14-openclaw-indexes
Scope	Layer 4 / Bundle 8A
Branch	skeleton/14-openclaw-indexes
Steps smoked	prepare_openclaw_pkm_workspace, check_openclaw_workspace, prepare_pkm_context_index, prepare_research_artifact_context_index, prepare_mechanism_report_ingest, prepare_search_report_ingest, prepare_zettelkasten_reasoning_bridge
Smoke modules	future 80-openclaw-pkm.smoke.sh
Smoke verifies	OpenClaw workspace, context indexes, artifact indexes, bridge configs
Must not do	index whole vault, print note bodies, call models, run experiments

The Layer 4/Product Owner PDF says Layer 4 adds reasoning access but does not reorganize or overwrite the Zettelkasten; it should prepare PKM context indexes, OpenClaw workspace, safe model configs, and query smoke tests.

Batch 15 — OpenClaw reasoners
Field	Correct mapping
Slug	15-openclaw-reasoners
Scope	Layer 4 / Bundle 8B
Branch	skeleton/15-openclaw-reasoners
Steps smoked	prepare_local_model_reasoner_config, prepare_remote_model_reasoner_config, prepare_reasoning_profile_templates, prepare_pkm_query_smoke_test, prepare_next_experiment_question_generator, prepare_mechanism_report_to_alloy_note_bridge, check_pkm_reasoning_ready, run_pkm_reasoning_local_smoke, plus later wrappers run_openclaw_reasoning_job, run_mechanism_review_reasoner, run_failure_triage_reasoner, run_paper_outline_reasoner
Smoke modules	future 80-openclaw-pkm.smoke.sh
Smoke verifies	reasoner configs, profile templates, query smoke, mocked/local reasoning report
Must not do	call paid models by default, write notes into vault, launch experiments, build paper output

The Bundle 8 PDF says the local smoke should be a tiny query over selected context, write to OpenClaw runs, and must not overwrite the vault or call paid remote models unless explicitly configured.

Batch 16 — Agentfield POC core
Field	Correct mapping
Slug	16-agentfield-poc
Scope	Layer 5 / Bundle 11A
Branch	skeleton/16-agentfield-poc
Steps smoked	prepare_agentfield_runtime_workspace, prepare_agentfield_sdk_environment, prepare_grn_experiment_poc_import, prepare_grn_experiment_spec_schema, prepare_grn_experiment_status_schema, prepare_experiment_aware_controller_entrypoint
Smoke modules	future 85-agentfield.smoke.sh
Smoke verifies	Agentfield repo structure, POC import, spec/status schemas, controller entrypoint
Must not do	start live server by default, call OpenRouter, print keys, claim full discovery platform

The Bundle 11 PDF corrects this bundle from a generic CRD/operator idea to an Agentfield-native experiment-aware controller POC, not a full Kubernetes controller, Paperclip adapter, RunPod scheduler, or complete science engine.

Batch 17 — Agentfield reasoners
Field	Correct mapping
Slug	17-agentfield-reasoners
Scope	Layer 5 / Bundle 11B
Branch	skeleton/17-agentfield-reasoners
Steps smoked	prepare_agent_registry_runtime, prepare_reasoner_invoker_runtime, prepare_grn_exploration_reasoners, prepare_grn_experiment_execute_fixtures, prepare_agentfield_server_smoke_docs, check_agentfield_runtime_ready, run_agentfield_grn_poc_local_smoke
Smoke modules	future 85-agentfield.smoke.sh
Smoke verifies	registry YAML, invoker, dummy reasoners, fixture JSON, dryrun resolved stages/status
Must not do	live model calls unless explicit, start server by default, treat POC as real discovery

Correction: This batch is still POC/dummy reasoners. Real NCA-ART evidence comes later through bridge/stub hardening.

Batch 18 — Agentfield hardening stubs
Field	Correct mapping
Slug	18-agentfield-hardening-stubs
Scope	Layer 5 / Bundle 11C
Branch	skeleton/18-agentfield-hardening-stubs
Steps smoked	prepare_grn_experiment_repo_split, prepare_agentfield_nca_art_bridge, prepare_agentfield_artifact_status_mapping, prepare_agentfield_mechanism_report_status, prepare_agentfield_runpod_target_stub
Smoke modules	future 85-agentfield.smoke.sh
Smoke verifies	bridge stubs, artifact/status mapping, mechanism report status, RunPod target stub defaulting to non-live
Must not do	run nca-art-grn, launch RunPod, call real services

Correction: The master explicitly includes these hardening stubs as part of Bundle 11.

Batch 19 — Paperclip adapter core
Field	Correct mapping
Slug	19-paperclip-adapter-core
Scope	Layer 5 / Bundle 12A
Branch	skeleton/19-paperclip-adapter-core
Steps smoked	prepare_paperclip_agentfield_adapter_workspace, prepare_paperclip_job_schema, prepare_agentfield_execute_client, prepare_agentfield_request_mapper, prepare_agentfield_status_mapper
Smoke modules	future 86-paperclip-adapter.smoke.sh
Smoke verifies	adapter workspace, paperclip job schema, Agentfield endpoints config, request/status mappers
Must not do	call live Agentfield, write Paperclip DB, call Paperclip API

The Bundle 12 PDF says this is not Paperclip itself and not Agentfield itself; it is the translation layer between Paperclip jobs/actions and Agentfield requests/status.

Batch 20 — Paperclip review dry-run
Field	Correct mapping
Slug	20-paperclip-review-dryrun
Scope	Layer 5 / Bundle 12B
Branch	skeleton/20-paperclip-review-dryrun
Steps smoked	prepare_artifact_link_mapper, prepare_review_action_mapper, prepare_adapter_config_profiles, prepare_adapter_smoke_fixtures, prepare_adapter_cli_smoke_commands, check_paperclip_agentfield_adapter_ready, run_paperclip_agentfield_adapter_dryrun_smoke, optional run_paperclip_agentfield_adapter_live_smoke
Smoke modules	future 86-paperclip-adapter.smoke.sh
Smoke verifies	fixture Paperclip job maps to Agentfield request; mock response maps to Paperclip card/status/review actions
Must not do	call live Agentfield by default, submit real Paperclip job, auto-approve actions

Correction: The smoke invariant is human review and mock/dryrun mapping, not dashboard functionality.

Batch 21 — Campaign core
Field	Correct mapping
Slug	21-campaign-core
Scope	Layer 5 / Bundle 13A
Branch	skeleton/21-campaign-core
Steps smoked	prepare_grn_discovery_campaign_schema, prepare_campaign_status_schema, prepare_campaign_state_store, prepare_campaign_stage_registry
Smoke modules	future 88-agentfield-campaign.smoke.sh
Smoke verifies	campaign schema, campaign status schema, state-store directories, stage registry
Must not do	run campaign, evaluate candidates, launch RunPod

Correction: This is schema/state readiness only.

Batch 22 — Campaign agents
Field	Correct mapping
Slug	22-campaign-agents
Scope	Layer 5 / Bundle 13B
Branch	skeleton/22-campaign-agents
Steps smoked	prepare_candidate_generation_agent, prepare_mechanism_evaluation_agent, prepare_search_strategy_agent, prepare_perturbation_design_agent, prepare_evidence_review_agent, prepare_next_experiment_agent
Smoke modules	future 88-agentfield-campaign.smoke.sh
Smoke verifies	agent stubs/configs, evidence/review/next-experiment fields, mechanism guardrails
Must not do	generate real candidates, declare discovery, run science

The Bundle 13 PDF says the platform is not searching for pretty final patterns; it must preserve mechanism evidence, perturbation response, NCA/ART evidence, DSL recoverability, falsification criteria, and next-experiment value.

Batch 23 — Campaign review smoke
Field	Correct mapping
Slug	23-campaign-review-smoke
Scope	Layer 5 / Bundle 13C
Branch	skeleton/23-campaign-review-smoke
Steps smoked	prepare_human_review_gate, prepare_campaign_artifact_collector, prepare_campaign_paperclip_payload_mapper, prepare_grn_discovery_campaign_smoke_fixtures, check_grn_discovery_platform_ready, run_grn_discovery_campaign_local_smoke
Smoke modules	future 88-agentfield-campaign.smoke.sh, future 86-paperclip-adapter.smoke.sh for payload shape
Smoke verifies	local fixture campaign writes campaign status, stage results, candidate rankings, artifact refs, next-experiment suggestions, Paperclip review payload
Must not do	auto-approve, launch next campaign, treat mock result as science

Correction: This is the first integrated campaign smoke, but success means platform flow works and human review is required, not scientific truth.

Batch 24 — Campaign guarded stubs
Field	Correct mapping
Slug	24-campaign-guarded-stubs
Scope	Layer 5 / Bundle 13D
Branch	skeleton/24-campaign-guarded-stubs
Steps smoked	prepare_runpod_campaign_executor, prepare_async_campaign_resume, prepare_campaign_retry_policy, prepare_multi_campaign_comparison, prepare_paperclip_campaign_live_submit
Smoke modules	future 88-agentfield-campaign.smoke.sh, future 75-runpod-dryrun.smoke.sh
Smoke verifies	live-capability stubs exist but default to dryrun/guarded; retry/resume/comparison/live-submit are not active by default
Must not do	submit live job, launch RunPod, write Paperclip live data, retry real jobs

Correction: This is the final skeleton safety boundary. The smoke should block if live behavior is accidentally the default.

Summary of key corrections to the previous report
Previous report issue	Corrected report
Batch 02 used prepare_grn_workspace	Use prepare_nca_art_workspace; prepare_grn_workspace is explicitly not a step.
Batch 01 treated remote-model helper as optional under core-layout only	Batch 01 now maps runtime roots to 10-core-layout, tool checks to 60-infra-tools, and dummy answer path to 90-research-assistant.
PKM and OpenClaw risked being merged	Batch 04 is PKM structure; Batch 14/15 are OpenClaw reasoning/access.
Publisher smoke was too generic	Batch 05 needs a dedicated publisher/LaTeX smoke domain because it has its own project structure and “do not build PDF by default” guardrail.
GRN smoke was too broad	Batch 06–09 should distinguish schema/base, dummy organs, reporting, and local smoke.
Search smoke was too vague	Batch 10–12 should distinguish templates, scoring/reporting, and local search smoke.
Agentfield was framed too generally	Batch 16–18 are POC core, reasoners, and hardening stubs, not full orchestration.
Paperclip adapter was too close to Paperclip app	Batch 19–20 are adapter mapping/dryrun only, no live Paperclip.
Campaign batches needed clearer safety gates	Batch 21–24 separate schema core, agents, review smoke, and guarded future live stubs.