from pathlib import Path


def evidence_dir(project, batch):
    root = Path(project["root"]) / project["project"].get("paths", {}).get(
        "evidence_snapshots_root", "sources/evidence_snapshots"
    )
    return root / batch.get("track", "skeleton") / batch.get("slug")


def normalized_evidence_contract(batch):
    contract = batch.get(
        "evidence_contract", ["POSTCHECK.md", "INTEGRATION_REQUEST.md", "SMOKE_REPORT.md"]
    )
    if isinstance(contract, dict):
        required = list(contract.get("required", []))
        conditional = list(contract.get("conditional", []))
    else:
        required = list(contract)
        conditional = []
    return required, conditional


def check_evidence(project, batch):
    directory = evidence_dir(project, batch)
    required, conditional = normalized_evidence_contract(batch)
    rows = []
    for name in required:
        path = directory / name
        rows.append({"name": name, "path": path, "exists": path.exists(), "required": True})
    for name in conditional:
        path = directory / name
        rows.append({"name": name, "path": path, "exists": path.exists(), "required": False})
    return rows


def missing_required_evidence(project, batch):
    return [row for row in check_evidence(project, batch) if row["required"] and not row["exists"]]
