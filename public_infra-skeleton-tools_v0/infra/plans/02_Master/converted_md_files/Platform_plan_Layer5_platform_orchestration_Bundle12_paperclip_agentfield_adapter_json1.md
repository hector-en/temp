# Platform Plan — Layer 5 Platform Orchestration — Bundle 12 Paperclip-Agentfield Adapter JSON 1

**Date:** 23.06.26, 22:10  
**Author/context:** vmuser - Milestone Creation for Codex

## Agentfield Execute Request

```http
POST /api/v1/execute/grn-experiment.run_experiment
```

```json
{
  "input": {
    "name": "GRN Discovery in Human Cortex",
    "description": "Identify key transcription factor regulatory networks in human cortical development using scRNA-seq data",
    "dataset_ref": "GSE123456_cortex_scrna",
    "organism": "human",
    "method_flags": ["pca", "correlation", "perturbation"]
  }
}
```

## Source Link

```text
https://chatgpt.com/g/g-p-6a075280f07c8191991e270b7e4a17e0/c/6a0c46d1-c268-832d-81c2-17196c756a31
```
