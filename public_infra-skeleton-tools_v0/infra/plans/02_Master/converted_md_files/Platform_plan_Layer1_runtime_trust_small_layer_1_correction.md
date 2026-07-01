# Platform plan - Layer 1 runtime trust small layer 1 correction

23.06.26, 19:27  
vmuser - Milestone Creation for Codex

Layer 1 is basically okay. I would only make **two small corrections** before moving on.

## Small Layer 1 corrections

### 1. `prepare_runpod_workspace` should know about project namespaces

Layer 1 should not create research code, but it should prepare storage roots that later bundles can use consistently:

```text
/workspace/repos/
/workspace/data/
/workspace/runs/
/workspace/artifacts/
/workspace/models/
/workspace/checkpoints/
```

Then later bundles create project-specific paths under those roots:

```text
/workspace/repos/nca-art-grn
/workspace/data/nca-art-grn
/workspace/runs/nca-art-grn
/workspace/artifacts/nca-art-grn
```

So Layer 1 remains generic. Layer 2/3 create the research-specific subfolders.

### 2. Remote model endpoint belongs in Layer 1, but only as a thin contract

The remote model loop should stay minimal:

```text
local code -> remote model -> response
```

No Agentfield, no Paperclip, no OpenClaw logic yet. The uploaded remote-model plan explicitly says the starting point is one reliable loop, where Runpod serves the model and local code talks to it through a standard chat API.

So Layer 1 is good if we keep it as:

```text
machine/runtime paths
GPU/CUDA checks
Docker/runtime policy
remote model client contract
```

Nothing else needs changing

---

Source footer:  
https://chatgpt.com/g/g-p-6a075280f07c8191991e270b7e4a17e0/c/6a0c46d1-c268-832d-81c2-17196c756a31
