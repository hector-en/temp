# Windows Server Disk Configuration

PowerShell automation for preparing an on-prem Windows Server VM that acts as a
local domain server.

## What This Is

This repo is a staged rewrite of a server-configuration script.
Its purpose is to make disk and storage setup:

- repeatable
- testable
- easier to operate safely

The intended end state is one script that can:

1. detect and prepare attached data disks
2. map those disks to their intended roles
3. enable dedup where needed
4. apply the right NTFS permissions
5. create the right SMB shares

## What It Is Good For

Use this repo if you want a more professional way to manage Windows Server VM
storage setup than a one-off script.

It is especially useful when you need:

- safer reruns
- test coverage around infrastructure logic
- clear operator output during execution
- incremental development instead of one risky rewrite

## Quick Use

### If You Just Want To Understand It Fast

- The script configures storage for a Windows Server VM.
- The host prepares metadata.
- The guest runs the real activation/configuration steps.
- The repo also contains the test and workflow system used to build that script safely.

### Fastest Correct Usage

Host:
```powershell
cd C:\Users\hector\Documents\Scripting\tools
Invoke-Pester -Script .\app\tests\configure_hq.Tests.ps1 -PassThru
```

## Requirements

- PowerShell 5.1 or PowerShell 7 on the host and guest
- Hyper-V available on the host for VM metadata discovery
- Administrator privileges for real guest execution
- `app/HqDiskMetadata.psm1` available on the guest before running `-RunActivation`

How the module is created:

- run `.\app\configure_hq.ps1` on the Hyper-V host
- select the VM you want to prepare
- the script writes `app/HqDiskMetadata.psm1`
- copy or sync that module with the guest before running activation there

Host metadata step:
```powershell
.\app\configure_hq.ps1
.\app\configure_hq.ps1 -VmName <ExactHyperVVmName>
```

Guest execution:
```powershell
.\app\configure_hq.ps1 -RunActivation
.\app\configure_hq.ps1 -RunActivation -TargetDiskNumbers 1,2,3
```

## Current Status

Current direction:

- disk discovery and activation are implemented
- role mapping and host metadata flow are being developed incrementally
- dedup, ACLs, and SMB are still later increments

So this repo is production-oriented, but not yet the full end-state server automation.

## Main Files

- `app/configure_hq.ps1`: active script
- `app/HqDiskMetadata.psm1`: host-generated metadata module
- `app/tests/configure_hq.Tests.ps1`: unit tests
- `docs/`: increment and domain notes
- `workflow/`: shared status and agent workflow artifacts

## Development

There are two normal ways to work in this repo.

### Normal Development

Use this when the next change is already clear.

1. update a small test
2. patch the script
3. run Pester
4. only run real infrastructure actions on the guest VM

### Pair-Coded Development

Use this when you want help designing the next slice.

Start with:

```text
Init the agent system, then use $powershell-pair-coder in comments-first mode.
```

Important defaults:

- `comments-first` is the standard mode
- the workflow should start with one top comment in the real file
- that top comment should say what problem the section solves and set up the smaller comments below it
- that top comment should remain its own block above the wider section it governs
- each meaningful code subsection should then get its own separate local comment above its own code
- the real code should then be written directly under the relevant local comment
- comments should use plain language and avoid workflow jargon
- if you save and resume later, run init again before continuing

Available pair-coder modes:

- `comments-first`: default mode, write the top comment first, then local comments, then code under those comments after approval
- `checkpointed`: same collaborative flow, with explicit checkpoints and red phase only on request
- `full-pairing`: same collaborative flow, but run the red phase before patching
- `direct-patch`: patch directly and verify with minimal ceremony

Comment structure standard:

- `top comment`: a short plain-language note that says what problem the section solves
- `local comment`: a short plain-language note above one meaningful code block
- the top comment may use two short lines when needed
- local comments should stay to one line when possible
- the top comment must precede its relevant code block and all other comments in that section
- the top comment should stay separate from the later local comment blocks; do not stack all comments together at the top
- local comments should precede the exact code they describe
- comments should move with the code they explain so the bigger reason and the local purpose do not drift apart

## Agent Workflow

The agent system is there to keep the work consistent across sessions.

Available roles:

- `powershell-pair-coder`: implementation help, pairing, and test-first slices
- `companion-guide-writer`: plain-language companion docs that explain the big picture before the code details
- `qa-state-analyst`: quality reading, risk commentary, and next-step guidance
- `scrum-stash-master`: checkpoint, stash, and resume-flow management
- `scrum-product-owner`: increment scope, acceptance criteria, and direction
- `workflow-drift-guard`: workflow-compliance checks for init, mode, and comment-first drift
- `scrum-solution-architect`: design boundaries, structure, and technical shape
- `scrum-powershell-tdd`: PowerShell-specific TDD support and test shaping

The shared startup procedure is in:

- `AGENTS.md`

The live status artifacts are in:

- `workflow/authoritative-status.md`
- `workflow/stash-memory.yaml`

## Public Repo Notes

This repo is meant to be readable by someone who needs to understand:

- what the automation is for
- what is already working
- how to run it safely
- how development is being managed

If you are new here, start with this order:

1. this README
2. `workflow/authoritative-status.md`
3. the active script
4. the tests
