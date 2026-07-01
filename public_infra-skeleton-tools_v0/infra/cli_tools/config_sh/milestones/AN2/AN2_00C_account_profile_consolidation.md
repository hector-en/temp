# AN2-00C — Consolidated Account Creation Profiles and SMB/Mount Defaults

Codex-only implementation brief.

## Goal

Refactor the account creation workflow so operator and target creation are driven by reusable account/profile specifications instead of duplicated defaults spread across flags, help text, env files, mount files, and code branches.

This milestone extends the `--create-operator` and `--create-target` work.

It should create one source of truth for:

```text
DefaultOperator
DefaultTarget
AIEngineer
ResearchScientist
Publisher
```

The profile should describe:

```text
- Linux user defaults
- group defaults
- home mode defaults
- target role and label
- bootstrap profile
- SMB profile
- mount defaults
- sync policy
- managed env/policy keys
- whether Linux user creation is allowed/required
- interactive choices shown to the user
```

Do not include project-sequencing text in the implementation file. Codex will receive the current codebase and this milestone directly.

## Current codebase context to respect

The labuser analysis shows the legacy target state has all current bootstrap steps skipped in the target plan, and legacy labuser shell files contain alias-driven environment helpers and installers. The new workflow must keep those as migration inputs, not as the long-term primary interface. fileciteturn9file0

The companion guide explains the intended operator workflow: inspect config, inspect steps, inspect state, then unskip and run a single managed step. It also uses the boundary between `bin/config.sh`, `lib/config-sh/installers.sh`, `etc/config-sh`, and `state/config-sh`. fileciteturn9file1

## Why this milestone exists

The account-creation commands need defaults, but hard-coding defaults in multiple places will quickly create drift.

For example, these must not be defined independently in multiple places:

```text
operator SMB behavior
target SMB behavior
home mode
primary group rule
role group rule
bootstrap profile name
target role label
mount set
sync system policy
whether distrohome is mounted
```

Create consolidated profile specs and make both commands read from those specs.

## Required profile names

Implement at least these profile names:

```text
DefaultOperator
DefaultTarget
AIEngineer
ResearchScientist
Publisher
```

Compatibility mapping:

```text
vmuser -> DefaultOperator
labuser -> DefaultTarget
AIEngineer -> AIEngineer
ResearchScientist -> ResearchScientist
Publisher -> Publisher
```

If actual Linux accounts are lowercase, profile names can remain human/logical while usernames are lowercase.

## Single source of truth location

Create a declarative profile file or files under:

```text
/home/vmuser/.local/etc/config-sh/accounts/
```

Recommended file:

```text
/home/vmuser/.local/etc/config-sh/accounts/profiles.tsv
```

Recommended columns:

```text
profile_name
account_kind
default_username
primary_group
role_group
home_mode
target_role
target_role_label
bootstrap_profile
smb_profile
mount_profile
sync_system_items
create_linux_user
add_operator_to_role_group
description
```

Use tab separation.

Example rows:

```text
DefaultOperator	operator	vmuser	vmuser	operator	770	operator	Operator	operator	operator	all	1	1	1	Operator account with full mount/sync policy
DefaultTarget	target	labuser	labuser	labuser	770	target	Target	default-target	target	ingress-egress	0	1	1	Generic target with ingress/egress only
AIEngineer	target	AIEngineer	AIEngineer	aiengineer	770	ai-engineer	AI Engineer	ai-engineer	airesearcher	ingress-egress	0	1	1	AI research assistant and MLOps role
ResearchScientist	target	ResearchScientist	ResearchScientist	researchassistent	770	research-scientist	Research Scientist	research-scientist	researchscientist	ingress-egress	0	1	1	GRN and Turing-pattern research role
Publisher	target	Publisher	Publisher	publisher	770	publisher	Publisher	publisher	publisher	ingress-egress	0	1	1	Obsidian/PKM to manuscript role
```

If tab parsing is already used elsewhere, reuse the same safe parsing patterns.

Do not use arbitrary shell execution in profile files.

## SMB profile source of truth

Create a declarative SMB profile file under:

```text
/home/vmuser/.local/etc/config-sh/accounts/smb-profiles.tsv
```

Recommended columns:

```text
smb_profile
smb_user_default
smb_user_ingress
smb_user_egress
mount_distrohome
mount_scripting
mount_ingress
mount_egress
description
```

Required profiles:

```text
operator
target
airesearcher
researchscientist
publisher
```

Suggested rows:

```text
operator	hector	hector	hector	1	1	1	1	Operator SMB profile; mount all supported shares
target	labuser	labuser	labuser	0	0	1	1	Generic target SMB profile; ingress and egress only
airesearcher	airesearcher	airesearcher	airesearcher	0	0	1	1	AI Engineer target SMB profile; ingress and egress only
researchscientist	researchscientist	researchscientist	researchscientist	0	0	1	1	Research Scientist target SMB profile; ingress and egress only
publisher	publisher	publisher	publisher	0	0	1	1	Publisher target SMB profile; ingress and egress only
```

Policy:

```text
Operator default:
  smb_profile=operator
  all mounts enabled:
    distrohome
    scripting
    ingress
    egress

Target default:
  smb_profile=target or a role-specific existing profile
  only ingress and egress mounted
  no distrohome by default
  no scripting by default
```

If the user chooses a target profile interactively, show available SMB profiles and explain the effect before applying.

## Mount profile source of truth

Create a declarative mount profile file under:

```text
/home/vmuser/.local/etc/config-sh/accounts/mount-profiles.tsv
```

Recommended columns:

```text
mount_profile
mount_distrohome
mount_scripting
mount_ingress
mount_egress
description
```

Required profiles:

```text
all
ingress-egress
none
```

Suggested rows:

```text
all	1	1	1	1	Mount all configured shares
ingress-egress	0	0	1	1	Mount only ingress and egress shares
none	0	0	0	0	Do not mount shares automatically
```

Account profiles should reference a mount profile instead of repeating mount booleans everywhere.

## Refactor rules to avoid duplicated defaults

Search current `config.sh`, `mounts.sh`, and config templates for duplicate defaults such as:

```text
vmuser -> hector
labuser -> labuser
SMB_USER_DEFAULT
SMB_USER_INGRESS_DEFAULT
SMB_USER_EGRESS_DEFAULT
SYNC_SYSTEM_ITEMS
BOOTSTRAP_PROFILE
home mode 770
operator/aiengineer/researchassistent/publisher group defaults
```

Refactor so account creation uses these profile readers:

```bash
config_account_profiles_file
config_smb_profiles_file
config_mount_profiles_file
config_account_profile_rows
config_smb_profile_rows
config_mount_profile_rows
config_find_account_profile
config_find_smb_profile
config_find_mount_profile
config_resolve_account_profile
config_account_profile_to_target_env
```

Existing target/mount loading may still support old env files, but the account creation command should generate them from the consolidated profile.

Do not remove existing backward compatibility yet.

## Relationship to target env files

Account profiles are templates/source of truth for creation.

Target env files are generated or reconciled per target:

```text
/home/vmuser/.local/etc/config-sh/targets/vmuser.env
/home/vmuser/.local/etc/config-sh/targets/labuser.env
/home/vmuser/.local/etc/config-sh/targets/AIEngineer.env
/home/vmuser/.local/etc/config-sh/targets/ResearchScientist.env
/home/vmuser/.local/etc/config-sh/targets/Publisher.env
```

Generated managed keys should include:

```bash
TARGET_ROLE="..."
TARGET_ROLE_LABEL="..."
BOOTSTRAP_PROFILE="..."
SYNC_SYSTEM_ITEMS="..."
SMB_PROFILE="..."
SMB_USER_DEFAULT="..."
SMB_USER_INGRESS_DEFAULT="..."
SMB_USER_EGRESS_DEFAULT="..."
MOUNT_PROFILE="..."
MOUNT_DISTROHOME="0|1"
MOUNT_SCRIPTING="0|1"
MOUNT_INGRESS="0|1"
MOUNT_EGRESS="0|1"
```

Preserve unknown keys and comments where practical.

## User creation support

The profile must describe whether Linux user creation is allowed/required:

```text
create_linux_user=1
```

The account creation command must support:

```text
- create user if missing
- create same-name primary group if missing
- create role group if missing
- set home owner user:user
- set home mode 770
- add Operator (vmuser) to role group when configured
```

Dry-run must show the exact user/group/home changes it would perform.

## Interactive mode requirements

Interactive mode must not assume the user already knows the right answer.

When running:

```bash
sudo config --create-target --interactive
sudo config --create-operator --interactive
```

The command should inspect and display real system state:

```bash
getent passwd
getent group operator
getent group aiengineer
getent group researchassistent
getent group publisher
ls -1 /home/vmuser/.local/etc/config-sh/accounts/
```

It should then show available choices from actual profile files:

```text
Available account profiles:
  1) DefaultOperator — Operator account with full mount/sync policy
  2) DefaultTarget   — Generic target with ingress/egress only
  3) AIEngineer      — AI research assistant and MLOps role
  4) ResearchScientist — GRN and Turing-pattern research role
  5) Publisher       — Obsidian/PKM to manuscript role

Available SMB profiles:
  1) operator — all mounts enabled
  2) target — ingress/egress only
  3) airesearcher — ingress/egress only
  4) researchscientist — ingress/egress only
  5) publisher — ingress/egress only

Available mount profiles:
  1) all — distrohome, scripting, ingress, egress
  2) ingress-egress — ingress and egress only
  3) none — no automatic mounts
```

For each selected option, print what it means before asking for confirmation:

```text
You selected AIEngineer:
  Linux user: AIEngineer
  primary group: AIEngineer
  role group: aiengineer
  home mode: 770
  target role: ai-engineer
  label: AI Engineer
  bootstrap profile: ai-engineer
  SMB profile: airesearcher
  mount profile: ingress-egress
  mounts: ingress=1, egress=1, distrohome=0, scripting=0
  sync system items: 0
  create linux user: yes
  add Operator (vmuser) to role group: yes
```

Then ask:

```text
Apply this account plan? [y/N]
```

Unless `--yes` is used.

## Non-interactive mode requirements

Non-interactive mode should accept a profile and derive defaults:

```bash
sudo config --create-operator --profile DefaultOperator --name vmuser --non-interactive
sudo config --create-target --profile AIEngineer --name AIEngineer --non-interactive
sudo config --create-target --profile ResearchScientist --name ResearchScientist --non-interactive
sudo config --create-target --profile Publisher --name Publisher --non-interactive
```

If no profile is given:

```text
--create-operator defaults to DefaultOperator
--create-target defaults to DefaultTarget unless --name maps to a known profile
```

Known name mapping:

```text
vmuser -> DefaultOperator
labuser -> DefaultTarget
AIEngineer -> AIEngineer
ResearchScientist -> ResearchScientist
Publisher -> Publisher
```

## Config-init integration

Update `config config-init` so it creates missing examples/templates for:

```text
etc/config-sh/accounts/profiles.tsv
etc/config-sh/accounts/smb-profiles.tsv
etc/config-sh/accounts/mount-profiles.tsv
```

Normal behavior must remain create-if-missing and non-destructive.

## Help text

Add/update help:

```bash
config help account
config help create-operator
config help create-target
config help profiles
```

Help should explain:

```text
- account profiles are creation templates
- target env files are generated/reconciled per target
- SMB profiles choose SMB usernames and mount defaults
- mount profiles choose which shares are enabled
- operator defaults to all mounts
- target defaults to ingress/egress only
- interactive mode lists real available profiles before prompting
```

## Safe postcheck commands

Run only safe commands unless explicitly allowed:

```bash
bash --noprofile --norc -n /home/vmuser/.local/bin/config.sh

config config-init

config help profiles
config help create-operator
config help create-target

sudo config --create-operator --profile DefaultOperator --name vmuser --dry-run
sudo config --create-target --profile DefaultTarget --name labuser --dry-run
sudo config --create-target --profile AIEngineer --name AIEngineer --dry-run
sudo config --create-target --profile ResearchScientist --name ResearchScientist --dry-run
sudo config --create-target --profile Publisher --name Publisher --dry-run
```

Do not run real account creation unless explicitly allowed.

Do not run broad bootstrap/install/mount/pull/push.

## Acceptance criteria

- Account profile source files exist and are created by `config config-init` if missing.
- DefaultOperator, DefaultTarget, AIEngineer, ResearchScientist, and Publisher are represented.
- Operator defaults use SMB profile `operator` and mount profile `all`.
- Target defaults use SMB profile `target` or role-specific profile and mount profile `ingress-egress`.
- Target default does not mount distrohome.
- Target default does not mount scripting.
- Interactive mode lists real available account, SMB, and mount profiles.
- Interactive mode explains selected choices before confirmation.
- Non-interactive mode derives deterministic defaults from profile.
- Account creation code no longer duplicates SMB/mount/profile defaults in several places.
- Target env file generation includes managed keys for SMB and mount policy.
- Existing target env unknown keys are preserved.
- Existing backward compatibility remains.
- No destructive changes are made in dry-run.
- No broad execution is run in postcheck.

## Postcheck log

Create:

```text
/home/vmuser/.local/patches/AN2_00C_account_profile_consolidation_postcheck.log
```

Include:

```text
- created/updated account profile files
- profile rows parsed
- SMB profile rows parsed
- mount profile rows parsed
- dry-run output for DefaultOperator
- dry-run output for DefaultTarget
- dry-run output for AIEngineer
- dry-run output for ResearchScientist
- dry-run output for Publisher
- help output checks
- confirmation no broad execution ran
```
