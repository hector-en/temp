# AN2-00D — Close SMB Credential, Mount Profile, and Help Consistency Gaps

Use with: `AN2_00D_CODEX_RUN_INSTRUCTIONS.md`

Codex-only interim implementation brief.

## Goal

Bring the current `config` / `mounts` / credential workflow into a consistent state before adding more role-managed installers.



## Evidence from current codebase

The latest codebase already exposes account, SMB, and mount profile files in config help, and describes them as creation templates that generate/reconcile target env files:

```text
/home/vmuser/.local/etc/config-sh/accounts/profiles.tsv
/home/vmuser/.local/etc/config-sh/accounts/smb-profiles.tsv
/home/vmuser/.local/etc/config-sh/accounts/mount-profiles.tsv
```

It also exposes `config profiles`, `--create-operator`, and `--create-target` in the command menu.

The generated default target configs already include:

```bash
SMB_USER_RESEARCH_DEFAULT="..."
SMB_USER_PUBLISH_DEFAULT="..."
MOUNT_RESEARCH="0|1"
MOUNT_PUBLISH="0|1"
```

The current mount helper already mounts:

```text
/mnt/research
/mnt/publish
```

using:

```text
SMB_USER_RESEARCH
SMB_USER_PUBLISH
research.credentials
publish.credentials
```

However, the current credential helper still only creates:

```text
cifs.credentials
distrohome.credentials
scripting.credentials
ingress.credentials
egress.credentials
```

and must be extended so the secret-file workflow matches the mount workflow.

## Scope

This milestone is not for adding new AI/Research/Publisher installers.

This milestone only closes the account/profile/SMB/mount workflow gaps in the system as it exists now.

## Required changes

### 1. Extend `create-cifs-credentials-files.sh` for research and publish

File:

```text
/home/vmuser/.local/bin/create-cifs-credentials-files.sh
```

Add variables:

```bash
RESEARCH_USER="${RESEARCH_USER:-${SMB_USER_RESEARCH_DEFAULT:-${SMB_USER_DEFAULT:-Researcher}}}"
PUBLISH_USER="${PUBLISH_USER:-${SMB_USER_PUBLISH_DEFAULT:-${SMB_USER_DEFAULT:-labuser}}}"
```

or equivalent.

Update `create_per_share()` so it writes:

```text
~/.local/share/wsl-mounts/distrohome.credentials
~/.local/share/wsl-mounts/scripting.credentials
~/.local/share/wsl-mounts/ingress.credentials
~/.local/share/wsl-mounts/egress.credentials
~/.local/share/wsl-mounts/research.credentials
~/.local/share/wsl-mounts/publish.credentials
```

Update help text:

```text
per-share  Create distrohome/scripting/ingress/egress/research/publish credentials files
```

Update “Files created” and “Defaults in this script”.

Do not store passwords in any env or profile file.

Keep:

```text
credentials dir mode: 700
credential file mode: 600
```

### 2. Add a profile-aware credential command path

Add one of these, whichever fits current code style best:

Option A, preferred:

```bash
config credentials [all|shared|per-share|help]
config --target USER credentials per-share
```

Option B, acceptable interim:

```bash
config secrets [all|shared|per-share|help]
config --target USER secrets per-share
```

Option C, minimal:

Keep direct `create-cifs-credentials-files.sh`, but update `config help mount`, `config help profiles`, and companion help to tell the operator exactly how to run it per target.

Preferred behavior for `config --target USER credentials per-share`:

```text
- load target policy first
- export SMB_USER_DEFAULT
- export SMB_USER_INGRESS_DEFAULT
- export SMB_USER_EGRESS_DEFAULT
- export SMB_USER_RESEARCH_DEFAULT
- export SMB_USER_PUBLISH_DEFAULT
- run the credential creator as TARGET_USER with HOME=TARGET_HOME
- never print passwords
```

Example:

```bash
sudo config --target ResearchScientist credentials per-share
```

should create:

```text
/home/ResearchScientist/.local/share/wsl-mounts/research.credentials
/home/ResearchScientist/.local/share/wsl-mounts/ingress.credentials
/home/ResearchScientist/.local/share/wsl-mounts/egress.credentials
```

and, if current implementation still prompts for all per-share credentials, also creates distrohome/scripting/publish. Later refinement may allow filtering.

### 3. Align mount profile names and booleans

Current config-init examples include mount profiles such as:

```text
all
target
research
publish
none
```

Verify they are consistent across:

```text
accounts/profiles.tsv
accounts/mount-profiles.tsv
targets/vmuser.env
targets/labuser.env
config help profiles
config-show
mounts.sh
```

Required intended behavior:

```text
DefaultOperator:
  SMB profile: operator
  mount profile: all
  MOUNT_DISTROHOME=1
  MOUNT_SCRIPTING=1
  MOUNT_INGRESS=1
  MOUNT_EGRESS=1
  MOUNT_RESEARCH=1
  MOUNT_PUBLISH=1

DefaultTarget:
  SMB profile: target
  mount profile: target
  MOUNT_DISTROHOME=0
  MOUNT_SCRIPTING=0
  MOUNT_INGRESS=1
  MOUNT_EGRESS=1
  MOUNT_RESEARCH=0
  MOUNT_PUBLISH=0

AIEngineer:
  SMB profile: aiengineer
  mount profile: research
  MOUNT_DISTROHOME=0
  MOUNT_SCRIPTING=0
  MOUNT_INGRESS=1
  MOUNT_EGRESS=1
  MOUNT_RESEARCH=1
  MOUNT_PUBLISH=0

ResearchScientist:
  SMB profile: researchscientist
  mount profile: research
  MOUNT_DISTROHOME=0
  MOUNT_SCRIPTING=0
  MOUNT_INGRESS=1
  MOUNT_EGRESS=1
  MOUNT_RESEARCH=1
  MOUNT_PUBLISH=0

Publisher:
  SMB profile: publisher
  mount profile: publish
  MOUNT_DISTROHOME=0
  MOUNT_SCRIPTING=0
  MOUNT_INGRESS=1
  MOUNT_EGRESS=1
  MOUNT_RESEARCH=0
  MOUNT_PUBLISH=1
```

Research Scientist role group note:

```text
Preferred role group default: researchscientist
Compatibility candidate: researchassistent
Codex must inspect both before applying real changes.
```

Important: target profiles should not mount distrohome by default.

### 4. Resolve Research Scientist role group safely

Do not assume the Research Scientist role group name without inspecting the real system.

Current generated profile examples in the codebase use:

```text
researchscientist
```

Earlier planning notes mentioned:

```text
researchassistent
```

Because the operator is not sure which one is authoritative, Codex must implement a safe resolution rule instead of hard-coding the uncertain value.

Preferred default when neither group exists:

```text
researchscientist
```

Required inspection:

```bash
getent group researchscientist
getent group researchassistent
```

Resolution rule:

```text
If only researchscientist exists:
  use researchscientist.

If only researchassistent exists:
  use researchassistent and preserve compatibility with the existing system.

If both exist:
  interactive mode must ask the operator which group is authoritative.
  non-interactive mode must fail unless --role-group is provided.

If neither exists:
  non-interactive mode defaults to researchscientist.
  interactive mode should present both choices and explain that researchscientist is the preferred default.
```

Update these places to use the resolved value, not a hard-coded uncertain spelling:

```text
accounts/profiles.tsv example generation
interactive display
dry-run plans
create-target logic
help text
postcheck docs
```

This does not force the Linux username to match the role group.

The target account can still be:

```text
ResearchScientist
```

or a lowercase equivalent if chosen.

The role group is separate from:

```text
TARGET_ROLE="research-scientist"
TARGET_ROLE_LABEL="Research Scientist"
BOOTSTRAP_PROFILE="research-scientist"
SMB_PROFILE="researchscientist"
```

### 5. Make `config profiles` show mount/SMB meaning clearly

Current `config profiles` lists account/SMB/mount profiles. Enhance output so it includes the practical effect:

For account profiles, show at least:

```text
profile name
account kind
default username
role group
target role label
SMB profile
mount profile
sync system items
description
```

For SMB profiles, show:

```text
profile
default/ingress/egress/research/publish SMB usernames
```

For mount profiles, show:

```text
distrohome
scripting
ingress
egress
research
publish
description
```

Keep output readable in a terminal.

### 6. Update mount help to match actual research/publish support

Verify `config help mount` / `mounts_usage` includes:

```text
--research
--publish
--no-research
--no-publish
--all mounts scripting, ingress, egress, research, and publish
```

Also add a short profile-aware workflow:

```text
Profile-aware workflow:
  config --target USER config-show
  sudo config --target USER credentials per-share
  sudo config --target USER mount
```

If `credentials` command is not added in this milestone, show:

```text
sudo -u USER -H create-cifs-credentials-files.sh per-share
```

### 7. Ensure target env reconciliation writes research/publish SMB and mount values

Verify generated/reconciled target env files include:

```bash
SMB_USER_RESEARCH_DEFAULT="..."
SMB_USER_PUBLISH_DEFAULT="..."
MOUNT_RESEARCH="0|1"
MOUNT_PUBLISH="0|1"
```

and that `config_show` displays the effective values:

```text
SMB_USER_RESEARCH
SMB_USER_PUBLISH
MOUNT_RESEARCH
MOUNT_PUBLISH
```

If it currently only displays defaults, adjust output to show runtime effective values as well.

### 8. Add safe validation workflow

Use only safe checks unless explicitly allowed.

Run:

```bash
bash --noprofile --norc -n /home/vmuser/.local/bin/config.sh
bash --noprofile --norc -n /home/vmuser/.local/bin/mounts.sh
bash --noprofile --norc -n /home/vmuser/.local/bin/create-cifs-credentials-files.sh

config config-init
config profiles
config help profiles
config help mount

config --target vmuser config-show
config --target labuser config-show

sudo config --create-operator --profile DefaultOperator --name vmuser --dry-run
sudo config --create-target --profile DefaultTarget --name labuser --dry-run
sudo config --create-target --profile AIEngineer --name AIEngineer --dry-run
sudo config --create-target --profile ResearchScientist --name ResearchScientist --dry-run
sudo config --create-target --profile Publisher --name Publisher --dry-run
```

If a `credentials` command is added, also safe-help check:

```bash
config credentials help
config --target labuser credentials help
```

Do not run real mount commands in the postcheck unless explicitly allowed.

Do not create or overwrite real secret files unless explicitly allowed.

## Non-goals

Do not implement the future AI/Research/Publisher installer stacks here.

Do not refactor mounts into fully declarative share definitions yet unless it is a very small and safe change.

Do not remove backward compatibility for current direct use of:

```bash
create-cifs-credentials-files.sh all
create-cifs-credentials-files.sh per-share
```

Do not store secrets in:

```text
config.env
targets/*.env
accounts/*.tsv
mounts.env
```

## Acceptance criteria

- `create-cifs-credentials-files.sh help` documents research and publish credentials.
- `create-cifs-credentials-files.sh per-share` can create:
  - `research.credentials`
  - `publish.credentials`
- Credential files are written under the executing user’s:
  - `~/.local/share/wsl-mounts`
- Credential files are mode `600`.
- Credential directory is mode `700`.
- `config help mount` documents research/publish flags and the profile-aware credential workflow.
- `config profiles` shows enough detail for the operator to choose account, SMB, and mount profiles.
- `config-show` shows effective research/publish SMB users and mount enable flags.
- DefaultOperator / DefaultTarget / AIEngineer / ResearchScientist / Publisher profile examples remain consistent.
- Research Scientist role group is resolved safely: prefer `researchscientist`, use existing `researchassistent` only when it is the actual existing/selected group, and require an explicit choice if both exist.
- DefaultTarget does not mount distrohome or scripting by default.
- Operator mounts all supported shares by default.
- No passwords are stored in env/profile files.
- No broad bootstrap/install/mount/pull/push is run during postcheck.
- Codex prompt guidance favors stable context plus small task-specific requests.
- Codex output is constrained: no full file dumps, only changed files and tests.
- Codex is told to avoid unrelated directory inspection.
- Codex must stop before touching secrets, raw research data, unpublished datasets, private vault content, or unpublished manuscript text.
- Existing commands remain compatible:
  - `create-cifs-credentials-files.sh all`
  - `create-cifs-credentials-files.sh per-share`
  - `sudo config --target USER mount`

## Suggested implementation notes

### Credential helper

Possible updated variable block:

```bash
DISTROHOME_USER="${DISTROHOME_USER:-${SMB_USER_DEFAULT:-hector}}"
SCRIPTING_USER="${SCRIPTING_USER:-${SMB_USER_DEFAULT:-hector}}"
INGRESS_USER="${INGRESS_USER:-${SMB_USER_INGRESS_DEFAULT:-labuser}}"
EGRESS_USER="${EGRESS_USER:-${SMB_USER_EGRESS_DEFAULT:-labuser}}"
RESEARCH_USER="${RESEARCH_USER:-${SMB_USER_RESEARCH_DEFAULT:-${SMB_USER_DEFAULT:-Researcher}}}"
PUBLISH_USER="${PUBLISH_USER:-${SMB_USER_PUBLISH_DEFAULT:-${SMB_USER_DEFAULT:-labuser}}}"
```

Possible updated `create_per_share`:

```bash
create_per_share() {
  write_credentials_file "$CREDENTIALS_DIR/distrohome.credentials" "$DISTROHOME_USER" "distrohome ($DISTROHOME_USER)"
  write_credentials_file "$CREDENTIALS_DIR/scripting.credentials" "$SCRIPTING_USER" "scripting ($SCRIPTING_USER)"
  write_credentials_file "$CREDENTIALS_DIR/ingress.credentials" "$INGRESS_USER" "ingress ($INGRESS_USER)"
  write_credentials_file "$CREDENTIALS_DIR/egress.credentials" "$EGRESS_USER" "egress ($EGRESS_USER)"
  write_credentials_file "$CREDENTIALS_DIR/research.credentials" "$RESEARCH_USER" "research ($RESEARCH_USER)"
  write_credentials_file "$CREDENTIALS_DIR/publish.credentials" "$PUBLISH_USER" "publish ($PUBLISH_USER)"
}
```

### Config wrapper command

Possible dispatcher additions:

```bash
credentials|secrets)
  config_run_credentials "$@"
  ;;
```

Possible runner:

```bash
config_run_credentials() {
  local subcmd="${1:-help}"
  case "$subcmd" in
    help|-h|--help)
      create-cifs-credentials-files.sh help
      ;;
    all|shared|per-share)
      config_refresh_session_context
      target_sudo env \
        SMB_USER_DEFAULT="$SMB_USER" \
        SMB_USER_INGRESS_DEFAULT="$SMB_USER_INGRESS" \
        SMB_USER_EGRESS_DEFAULT="$SMB_USER_EGRESS" \
        SMB_USER_RESEARCH_DEFAULT="$SMB_USER_RESEARCH" \
        SMB_USER_PUBLISH_DEFAULT="$SMB_USER_PUBLISH" \
        create-cifs-credentials-files.sh "$subcmd"
      ;;
    *)
      echo "[ERROR] Unknown credentials command: $subcmd" >&2
      return 2
      ;;
  esac
}
```

Adjust to exact path handling if `create-cifs-credentials-files.sh` is not on the target user PATH.

## Postcheck log

Create:

```text
/home/vmuser/.local/patches/AN2_00D_smb_credentials_mount_gap_closure_postcheck.log
```

Include:

```text
- syntax check results
- list of changed files
- whether config credentials command was added
- credential helper help output summary
- config profiles output summary
- config help mount output summary
- config-show output for vmuser and labuser
- dry-run output summaries for DefaultOperator and DefaultTarget
- dry-run output summaries for AIEngineer, ResearchScientist, Publisher
- group inspection output for `getent group researchscientist` and `getent group researchassistent`
- confirmation that no real mount command was run
- confirmation that no real secret files were created unless explicitly allowed
- confirmation that no broad bootstrap/install/pull/push command was run
- confirmation that no full large-file contents were printed
- confirmation that inspection was limited to task-relevant files
- confirmation that no secrets, raw research data, unpublished datasets, private vault content, or unpublished manuscript text were read or printed
```
