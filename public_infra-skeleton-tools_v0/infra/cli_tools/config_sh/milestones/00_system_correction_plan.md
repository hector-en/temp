# VMUser System Correction Plan

Source package: `code_full_text.txt`

This plan breaks the refactor into small, paste-ready correction briefs. Each correction is intended to fit roughly one focused 30-minute implementation session. The correction briefs are designed to be pasted into a fresh chat together with `code_full_text.txt`, so each brief includes its own scope, constraints, and Definition of Done.

## Primary goals

1. Make shell startup fast, quiet, and safe for VSCodium Remote.
2. Split helper functions, mount automation, and system bootstrap into separate files.
3. Remove unintended side effects from sourced scripts.
4. Make install and mount workflows non-interactive unless explicitly requested.
5. Harden quoting, idempotency, credentials handling, and retry behavior.
6. Add smoke tests and a final runbook so changes can be verified and rolled back.

## Working assumptions

- `code_full_text.txt` contains the currently exported system files and logs.
- The main implementation target is `/home/vmuser/.local/bin/config.sh`.
- The high-priority operational symptom is VSCodium repeatedly failing to resolve the shell environment within a reasonable time.
- Each correction brief should produce either a minimal patch or a narrow set of replacement file contents.
- The new chat receiving each brief should not attempt the whole refactor at once.

## Backlog of correction briefs

| ID | Planned brief file | Story Points | Target duration | Correction |
|---:|---|---:|---:|---|
| 01 | `01_fix_shell_startup_no_side_effects.md` | 1 | ~30 min | Stop shell startup noise and sourced-script side effects. |
| 02 | `02_add_explicit_config_modes.md` | 1 | ~30 min | Add explicit `config.sh` modes such as `help`, `bootstrap`, `mounts`, and `status`. |
| 03 | `03_extract_lv_dashboard_to_lv_sh.md` | 1 | ~30 min | Move `lv` dashboard/helpers out of `config.sh` into `lv.sh`. |
| 04 | `04_create_lightweight_shell_loader.md` | 1 | ~30 min | Create a small loader that sources aliases and `lv.sh` without installers or mounts. |
| 05 | `05_make_update_alias_safe.md` | 1 | ~30 min | Replace the broad `update` alias with explicit safe aliases. |
| 06 | `06_extract_mount_workflow_to_mounts_sh.md` | 1 | ~30 min | Move fstab rendering and SMB mount functions into `mounts.sh`. |
| 07 | `07_make_mounts_non_interactive.md` | 1 | ~30 min | Replace mount prompts with flags/environment variables. |
| 08 | `08_add_smb_credentials_file_support.md` | 1 | ~30 min | Add safe CIFS credential-file support and avoid credentials in command history. |
| 09 | `09_harden_run_as_target_and_append_helpers.md` | 1 | ~30 min | Replace fragile `bash -lc` string interpolation with safer helper patterns. |
| 10 | `10_make_run_once_atomic_and_target_scoped.md` | 1 | ~30 min | Make state markers atomic, user-scoped, and only written after full success. |
| 11 | `11_split_install_dev_env_substeps.md` | 1 | ~30 min | Break `InstallDevEnv` into smaller idempotent install functions. |
| 12 | `12_add_preflight_checks.md` | 1 | ~30 min | Add preflight checks for OS version, sudo, network, DNS, and required commands. |
| 13 | `13_add_download_retry_helpers.md` | 1 | ~30 min | Add bounded retry helpers for curl/wget/apt repository downloads. |
| 14 | `14_fix_kubernetes_installer.md` | 1 | ~30 min | Rename `install-kubernets`, make Kubernetes version configurable, and validate repo setup. |
| 15 | `15_fix_alias_creation_quoting.md` | 1 | ~30 min | Fix alias creation/update quoting, escaping, and duplicate behavior. |
| 16 | `16_idempotent_shell_includes.md` | 1 | ~30 min | Normalize `.bashrc`, `.profile`, and alias include blocks with markers. |
| 17 | `17_add_status_and_dry_run.md` | 1 | ~30 min | Add `status` and `dry-run` commands for bootstrap and mount workflows. |
| 18 | `18_add_logging_and_log_rotation.md` | 1 | ~30 min | Capture bootstrap logs and rotate old logs under `.local/state`. |
| 19 | `19_add_shellcheck_and_syntax_smoke_tests.md` | 1 | ~30 min | Add local syntax checks and ShellCheck-oriented cleanup notes. |
| 20 | `20_add_vscodium_remote_health_checks.md` | 1 | ~30 min | Add checks for VSCodium shell timeout and workspace permission errors. |
| 21 | `21_final_integration_runbook.md` | 1 | ~30 min | Create final verification, rollback, and operational runbook. |

## Recommended execution order

Complete the corrections in order. The order intentionally fixes user-facing startup stability first, then separates responsibilities, then hardens internals.

1. **Stabilize shell startup:** corrections 01-05.
2. **Separate mount/bootstrap workflows:** corrections 06-08.
3. **Harden primitives and state:** corrections 09-10.
4. **Make installs safer:** corrections 11-14.
5. **Clean shell integration:** corrections 15-16.
6. **Add observability and verification:** corrections 17-21.

## Definition of Done for the full plan

The full plan is complete when all of these are true:

- Starting an interactive shell produces no unexpected output from helper scripts.
- Sourcing helper files does not run apt, mounts, network operations, sudo, prompts, or filesystem writes except unavoidable shell definitions.
- `lv` works after being sourced from a lightweight loader.
- Bootstrap and mount workflows run only through explicit commands.
- All prompts have a non-interactive equivalent.
- CIFS credentials are not placed directly in shell history or long-running command lines.
- Re-running bootstrap after success is safe.
- Re-running after partial failure gives a clear status and retry path.
- The Kubernetes installer uses a correctly named function and configurable version.
- The repository has a clear status command, dry-run command, and final verification runbook.

## How to use each correction brief

For each correction file:

1. Start a new chat.
2. Upload or paste `code_full_text.txt`.
3. Paste the correction brief.
4. Ask for a minimal patch only for that correction.
5. Apply and test the patch before moving to the next correction.

