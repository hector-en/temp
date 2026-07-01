
PROFILES = {
 "webchat-sandbox": {"writes_workspace": False, "runs_smoke": False, "runs_codex": False, "default_out": "/mnt/data/generated"},
 "cli-dry-run": {"writes_workspace": False, "runs_smoke": False, "runs_codex": False, "default_out": "generated"},
 "codex-pack": {"writes_workspace": False, "runs_smoke": False, "runs_codex": False, "default_out": "generated"},
 "workspace": {"writes_workspace": False, "runs_smoke": False, "runs_codex": False, "default_out": "generated"},
}
def validate_profile(name):
    if name not in PROFILES:
        raise SystemExit(f"Unknown profile {name!r}. Valid: {', '.join(PROFILES)}")
    return PROFILES[name]
