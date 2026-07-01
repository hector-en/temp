# AN2-00D — Codex Run Instructions

Use this file as the short instruction file you give to Codex.

Pair it with:

```text
AN2_00D_smb_credentials_mount_gap_closure_SPEC.md
```

Codex should read the spec file for implementation details, but each run should execute only one small task.

## Codex prompt and cache discipline

Use this milestone with a stable context pack so repeated Codex runs can reuse context and avoid re-reading the whole project.

Do not leave placeholders in the Codex prompt. Copy the full stable context below exactly, then add one of the ready-to-use tasks under `Task:`.

### Copy-ready Codex prompt template

```text
You are working in this repository under the following stable project instructions.

Stable context pack:

Project model:
- /home/vmuser/.local/bin/config.sh is the command, state, target, account-profile, and policy engine.
- /home/vmuser/.local/bin/mounts.sh is the current trusted CIFS mount implementation.
- /home/vmuser/.local/bin/create-cifs-credentials-files.sh is the SMB secret-file creator.
- /home/vmuser/.local/lib/config-sh/installers.sh contains trusted installer functions.
- /home/vmuser/.local/etc/config-sh/accounts/profiles.tsv is the account profile source of truth.
- /home/vmuser/.local/etc/config-sh/accounts/smb-profiles.tsv is the SMB identity/profile source of truth.
- /home/vmuser/.local/etc/config-sh/accounts/mount-profiles.tsv is the mount-selection profile source of truth.
- /home/vmuser/.local/etc/config-sh/targets/USER.env is generated or reconciled per-target policy.
- /home/USER/.local/state/config-sh is runtime state/history and should not be manually edited unless the task is specifically about runtime state.
- Passwords belong only in /home/USER/.local/share/wsl-mounts/*.credentials.
- Do not store secrets in config.env, targets/*.env, accounts/*.tsv, mounts.env, bootstrap profiles, or help text.
- Prefer the workflow: inspect -> dry-run -> narrow execution.
- Do not run broad bootstrap/install/mount/pull/push unless explicitly instructed.
- Do not print full file contents.
- Make the smallest safe change.
- Do not inspect unrelated directories.
- Stop and ask before touching or printing SMB passwords, credential files, raw research data, unpublished datasets, private PKM/vault content, or unpublished manuscript text.

Current intended behavior:
- Operator uses account profile DefaultOperator.
- Operator default SMB profile is operator.
- Operator default mount profile is all.
- Operator may mount distrohome, scripting, ingress, egress, research, and publish.
- Generic targets use account profile DefaultTarget.
- Generic targets default to ingress and egress only.
- Generic targets must not mount distrohome or scripting by default.
- AIEngineer uses a role-specific account profile and may use research-oriented mounts.
- ResearchScientist uses a role-specific account profile and may use research-oriented mounts.
- Publisher uses a role-specific account profile and may use publish-oriented mounts.
- Research Scientist role group must be resolved safely:
  - inspect getent group researchscientist
  - inspect getent group researchassistent
  - if only one exists, use the existing one
  - if both exist, interactive mode must ask the operator
  - if neither exists, default to researchscientist unless the operator explicitly chooses otherwise

Known current gap for this milestone:
- mounts.sh already supports research and publish mount behavior.
- create-cifs-credentials-files.sh must be extended so per-share mode can create research.credentials and publish.credentials.
- Help/profile output should make the link clear:
  account profile -> SMB profile -> mount profile -> target env -> credentials -> mount execution.

Output rules:
- Do not print full file contents.
- Do not run recursive broad searches over unrelated directories.
- Use targeted inspection only, such as grep -n, sed -n with small ranges, and bash -n.
- At the end, summarize only changed files and tests run.

Expected final answer format:
Changed files:
- path/to/file

Tests run:
- command

Notes:
- one or two short bullets

Task:
```

After `Task:`, paste one small task-specific request from below, or write an equally small request.

### Ready-to-use small Codex tasks

Use one task at a time.

#### Task 1 — Extend credential creator for research and publish

```text
Extend /home/vmuser/.local/bin/create-cifs-credentials-files.sh so per-share mode also creates research.credentials and publish.credentials.

Requirements:
- Add RESEARCH_USER and PUBLISH_USER defaults from SMB_USER_RESEARCH_DEFAULT and SMB_USER_PUBLISH_DEFAULT.
- Update create_per_share to write research.credentials and publish.credentials.
- Update help text so all, shared, and per-share behavior is accurate.
- Keep credential directory mode 700 and file mode 600.
- Do not read or print existing credential files.
- Run bash --noprofile --norc -n /home/vmuser/.local/bin/create-cifs-credentials-files.sh.
```

#### Task 2 — Add profile-aware credentials command

```text
Add a profile-aware credentials command to /home/vmuser/.local/bin/config.sh.

Desired command:
  config credentials [all|shared|per-share|help]
  config --target USER credentials per-share

Requirements:
- Load target policy before running the credential creator.
- Run the credential creator as TARGET_USER with HOME=TARGET_HOME.
- Export SMB_USER_DEFAULT, SMB_USER_INGRESS_DEFAULT, SMB_USER_EGRESS_DEFAULT, SMB_USER_RESEARCH_DEFAULT, and SMB_USER_PUBLISH_DEFAULT from the resolved runtime values.
- Do not print passwords.
- Do not read existing credential files.
- Update help text minimally.
- Run bash --noprofile --norc -n /home/vmuser/.local/bin/config.sh.
```

#### Task 3 — Improve config profiles output

```text
Improve the output of config profiles in /home/vmuser/.local/bin/config.sh.

Requirements:
- For account profiles, show profile name, account kind, default username, role group, target role label, SMB profile, mount profile, sync system items, and description.
- For SMB profiles, show default, ingress, egress, research, and publish SMB usernames.
- For mount profiles, show distrohome, scripting, ingress, egress, research, publish, and description.
- Keep output compact and terminal-readable.
- Do not change account creation behavior.
- Run bash --noprofile --norc -n /home/vmuser/.local/bin/config.sh.
```

#### Task 4 — Update mount help for research/publish workflow

```text
Update mount help text in /home/vmuser/.local/bin/mounts.sh and any config help wrapper that displays mount help.

Requirements:
- Document --research, --publish, --no-research, and --no-publish.
- Explain that operator profile mounts all supported shares by default.
- Explain that target profile mounts ingress and egress only by default unless a role profile enables research or publish.
- Add a short profile-aware workflow:
  config --target USER config-show
  sudo config --target USER credentials per-share
  sudo config --target USER mount
- Do not change mount execution behavior.
- Run bash --noprofile --norc -n /home/vmuser/.local/bin/mounts.sh.
```

#### Task 5 — Resolve Research Scientist role group safely

```text
Update account-profile resolution in /home/vmuser/.local/bin/config.sh so Research Scientist role group selection is safe.

Requirements:
- Inspect both researchscientist and researchassistent with getent group.
- If only one exists, use the existing group.
- If both exist, interactive mode must ask the operator which group is authoritative.
- If both exist in non-interactive mode and --role-group is not provided, fail with a clear message.
- If neither exists, default to researchscientist unless the operator explicitly chooses another group.
- Do not rename existing groups.
- Do not delete groups.
- Run bash --noprofile --norc -n /home/vmuser/.local/bin/config.sh.
```

### Cache-friendly implementation rule

Prefer targeted inspection commands:

```bash
grep -n "pattern" file
sed -n '120,180p' file
bash --noprofile --norc -n file
```

Avoid:

```bash
cat large-file
find / -...
grep -R ... /
printing full config.sh
printing full codebase analysis
```

### Sensitive-data stop rule

Codex must stop and ask before touching or printing:

```text
- SMB passwords
- credential files
- raw research data
- unpublished datasets
- private PKM/vault content
- unpublished manuscript text
```

It may modify code that creates or references credential files, but it must not read or print real credential contents.

## How to use these two files

For each Codex run, say:

```text
Read AN2_00D_CODEX_RUN_INSTRUCTIONS.md and AN2_00D_smb_credentials_mount_gap_closure_SPEC.md.

Follow the stable context and output rules from AN2_00D_CODEX_RUN_INSTRUCTIONS.md.

Execute only Task N from the ready-to-use task list.

Do not execute other tasks from the spec.
```

Recommended order:

```text
Task 1: Extend credential creator for research and publish.
Task 2: Add profile-aware credentials command.
Task 3: Improve config profiles output.
Task 4: Update mount help for research/publish workflow.
Task 5: Resolve Research Scientist role group safely.
```
